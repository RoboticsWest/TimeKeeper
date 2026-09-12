-- Every subscribed table except `settings` uses a uuid PK, which json_build_object
-- serializes as a JSON string. `settings.id` is boolean (single-row table, see 0001_init),
-- so its NOTIFY payload became `"id": true` and `events.rs::NotifyPayload(id: String)`
-- failed to parse it, silently dropping every settings change (e.g. the Discord bot's
-- settings-change watcher never waking). Cast the id to text so the payload is always a JSON
-- string.
CREATE OR REPLACE FUNCTION notify_table_change() RETURNS trigger AS $$
BEGIN
    PERFORM pg_notify(
        'db_changes',
        json_build_object(
            'table', TG_TABLE_NAME,
            'op', TG_OP,
            'id', (COALESCE(NEW.id, OLD.id))::text
        )::text
    );
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
