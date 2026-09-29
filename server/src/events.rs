use std::any::Any;
use std::future::Future;
use std::sync::Arc;

use dashmap::DashMap;
use once_cell::sync::OnceCell as SyncOnceCell;
use tokio::sync::OnceCell;
use tokio::sync::broadcast;
use tokio_postgres::NoTls;
use tokio_stream::{Stream, StreamExt};
use tokio_util::sync::CancellationToken;

#[derive(Clone, Copy, Debug, PartialEq, Eq, async_graphql::Enum)]
pub enum ChangeOperation {
  Insert,
  Update,
  Delete,
}

impl ChangeOperation {
  fn parse(op: &str) -> Option<Self> {
    match op {
      "INSERT" => Some(Self::Insert),
      "UPDATE" => Some(Self::Update),
      "DELETE" => Some(Self::Delete),
      _ => None,
    }
  }
}

/// The lazily-fetched row behind one change event, shared by every subscriber to it.
///
/// Type-erased because [`EventBus`] fans out every table through one channel type; the downcast in
/// [`resolve_once`] is sound because an event belongs to exactly one table and that table's
/// subscription resolver always asks for the same type.
type SharedRow = Arc<OnceCell<Option<Arc<dyn Any + Send + Sync>>>>;

/// A row changed in `table` - carries what Postgres' `NOTIFY` payload carries (op + id, no row
/// data, see `notify_table_change()` in `database/migrations/0001_init/up.sql`) plus a slot for the
/// row once somebody has looked it up.
///
/// The slot exists because the lookup used to happen once *per subscriber*: with three kiosks and
/// an admin connected, one check-in meant four identical `SELECT ... WHERE id = $1` round trips,
/// and a bulk operation multiplied that by every row it touched. Now the first subscriber to need
/// the row fetches it and the rest read the same value.
#[derive(Clone, Debug)]
pub struct TableChange {
  pub operation: ChangeOperation,
  pub id: String,
  row: SharedRow,
}

impl TableChange {
  pub fn new(operation: ChangeOperation, id: String) -> Self {
    Self { operation, id, row: Arc::new(OnceCell::new()) }
  }
}

/// Fetches the row for a change event at most once, however many subscribers ask for it.
///
/// [`fetch`] runs for the first caller only; concurrent callers wait on that same fetch and every
/// later one reads the cached result. A `Delete` carries no row, so callers skip this entirely.
pub async fn resolve_once<T, F, Fut>(change: &TableChange, fetch: F) -> Option<T>
where
  T: Clone + Send + Sync + 'static,
  F: FnOnce() -> Fut,
  Fut: Future<Output = Option<T>>,
{
  let cached =
    change.row.get_or_init(|| async { fetch().await.map(|row| Arc::new(row) as Arc<dyn Any + Send + Sync>) }).await;
  cached.as_ref()?.downcast_ref::<T>().cloned()
}

/// Fans out `TableChange` events per table name. Fed exclusively by the `pg_notify` listener task
/// started in `listen_for_changes` - nothing else publishes to this, so a change is only ever
/// missed if the DB trigger itself didn't fire, not because application code forgot to call
/// something.
pub struct EventBus {
  channels: DashMap<String, broadcast::Sender<TableChange>>,
  capacity: usize,
}

impl EventBus {
  fn new(capacity: usize) -> Self {
    Self { channels: DashMap::new(), capacity }
  }

  fn publish(&self, table: &str, change: TableChange) {
    log::debug!("Change event: table={table} op={:?} id={}", change.operation, change.id);
    if let Some(sender) = self.channels.get(table) {
      let _ = sender.send(change);
    }
  }

  pub fn subscribe(&self, table: &str) -> broadcast::Receiver<TableChange> {
    let sender = self.channels.entry(table.to_string()).or_insert_with(|| {
      let (tx, _rx) = broadcast::channel(self.capacity);
      tx
    });
    sender.subscribe()
  }
}

pub static EVENT_BUS: SyncOnceCell<EventBus> = SyncOnceCell::new();

pub fn init_event_bus(capacity: usize) -> anyhow::Result<()> {
  if EVENT_BUS.get().is_some() {
    log::warn!("Event Bus already initialized");
  } else {
    log::info!("Initializing Event Bus");
    EVENT_BUS.set(EventBus::new(capacity)).map_err(|_| anyhow::anyhow!("Failed to set Event Bus"))?;
  }
  Ok(())
}

#[derive(serde::Deserialize)]
struct NotifyPayload {
  table: String,
  op: String,
  id: String,
}

/// Opens a dedicated (unpooled) connection, `LISTEN`s on `db_changes`, and republishes every
/// notification onto `EVENT_BUS`. Runs for the process lifetime - stopped via `cancel`. Must never
/// share a connection with the diesel-async pool: `LISTEN` state lives on that one connection only.
pub async fn listen_for_changes(database_url: &str, cancel: CancellationToken) -> anyhow::Result<()> {
  use tokio_postgres::AsyncMessage;

  let (client, mut connection) = tokio_postgres::connect(database_url, NoTls).await?;

  // The `Connection` has to be polled continuously to drive its I/O at all - including for
  // `client` calls like `batch_execute` below to get a response - so it's driven in its own task,
  // forwarding notifications into a channel, rather than awaited inline.
  let (tx, mut rx) = tokio::sync::mpsc::unbounded_channel();
  let driver = tokio::spawn(async move {
    loop {
      match std::future::poll_fn(|cx| connection.poll_message(cx)).await {
        Some(Ok(AsyncMessage::Notification(notification))) => {
          if tx.send(notification).is_err() {
            break;
          }
        }
        Some(Ok(_)) => {}
        Some(Err(e)) => {
          log::error!("Postgres NOTIFY listener connection error: {e}");
          break;
        }
        None => break,
      }
    }
  });

  client.batch_execute("LISTEN db_changes;").await?;
  log::info!("Listening for Postgres db_changes notifications");

  loop {
    tokio::select! {
      notification = rx.recv() => {
        let Some(notification) = notification else { break };

        let Ok(payload) = serde_json::from_str::<NotifyPayload>(notification.payload()) else {
          log::warn!("Failed to parse db_changes payload: {}", notification.payload());
          continue;
        };
        let Some(operation) = ChangeOperation::parse(&payload.op) else {
          log::warn!("Unrecognized db_changes op: {}", payload.op);
          continue;
        };

        if let Some(bus) = EVENT_BUS.get() {
          bus.publish(&payload.table, TableChange::new(operation, payload.id));
        }
      }
      () = cancel.cancelled() => {
        log::info!("Stopping Postgres NOTIFY listener");
        break;
      }
    }
  }

  driver.abort();
  Ok(())
}

/// Wraps any stream and terminates it when `cancel` fires (server shutdown).
pub fn with_shutdown<S, T>(stream: S, cancel: CancellationToken) -> impl Stream<Item = T> + Send
where
  S: Stream<Item = T> + Send + 'static,
  T: Send + 'static,
{
  async_stream::stream! {
    tokio::pin!(stream);

    loop {
      tokio::select! {
        item = stream.next() => {
          match item {
            Some(value) => yield value,
            None => break,
          }
        }
        () = cancel.cancelled() => {
          break;
        }
      }
    }
  }
}

#[cfg(test)]
mod tests {
  use std::sync::atomic::{AtomicUsize, Ordering};

  use super::*;

  /// What this guards: one change event costs one row lookup, however many subscribers see it.
  ///
  /// Each subscription resolver used to call `logic.get(id)` itself, so a single check-in meant one
  /// `SELECT` per connected client and a bulk operation multiplied that by every row it touched.
  #[tokio::test]
  async fn a_row_is_fetched_once_however_many_subscribers_ask() {
    let change = TableChange::new(ChangeOperation::Update, "row-1".to_string());
    let fetches = AtomicUsize::new(0);

    let fetch = || async {
      fetches.fetch_add(1, Ordering::SeqCst);
      Some("the row".to_string())
    };

    // Three subscribers, as three kiosks watching the same table would.
    let a: Option<String> = resolve_once(&change, fetch).await;
    let b: Option<String> = resolve_once(&change, fetch).await;
    let cloned = change.clone();
    let c: Option<String> = resolve_once(&cloned, fetch).await;

    assert_eq!(a.as_deref(), Some("the row"));
    assert_eq!(b, a, "a later subscriber reads the same row");
    assert_eq!(c, a, "a clone of the event shares the slot, which is how it reaches subscribers");
    assert_eq!(fetches.load(Ordering::SeqCst), 1);
  }

  #[tokio::test]
  async fn concurrent_subscribers_still_only_fetch_once() {
    let change = TableChange::new(ChangeOperation::Insert, "row-1".to_string());
    let fetches = AtomicUsize::new(0);

    let fetch = || async {
      fetches.fetch_add(1, Ordering::SeqCst);
      // Yield so both callers are certainly inside the fetch window at the same time.
      tokio::task::yield_now().await;
      Some(7_u32)
    };

    let other = change.clone();
    let (a, b) = tokio::join!(resolve_once(&change, fetch), resolve_once(&other, fetch));

    assert_eq!(a, Some(7));
    assert_eq!(b, Some(7));
    assert_eq!(fetches.load(Ordering::SeqCst), 1);
  }

  #[tokio::test]
  async fn a_row_that_is_gone_is_not_retried_by_the_next_subscriber() {
    // A row deleted between the NOTIFY and the lookup: every subscriber agrees it is absent, and
    // nobody pays for a second query to find that out.
    let change = TableChange::new(ChangeOperation::Update, "row-1".to_string());
    let fetches = AtomicUsize::new(0);

    let fetch = || async {
      fetches.fetch_add(1, Ordering::SeqCst);
      None::<String>
    };

    assert_eq!(resolve_once(&change, fetch).await, None);
    assert_eq!(resolve_once(&change, fetch).await, None);
    assert_eq!(fetches.load(Ordering::SeqCst), 1);
  }
}
