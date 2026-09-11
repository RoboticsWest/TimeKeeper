use dashmap::DashMap;
use once_cell::sync::OnceCell;
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

/// A row changed in `table` - carries only what Postgres' `NOTIFY` payload carries (op + id, no
/// row data, see `notify_table_change()` in `database/migrations/0001_init/up.sql`). Subscribers
/// re-fetch the row themselves; this is just the "something happened, go look" signal.
#[derive(Clone, Debug)]
pub struct TableChange {
  pub operation: ChangeOperation,
  pub id: String,
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

pub static EVENT_BUS: OnceCell<EventBus> = OnceCell::new();

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
          bus.publish(&payload.table, TableChange { operation, id: payload.id });
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
