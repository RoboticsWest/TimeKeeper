-- The 0001_init triggers cover every subscribed table EXCEPT users and settings. Without a
-- trigger there is nothing feeding NOTIFY, so the `userChanges` GraphQL subscription (Users tab)
-- and the Discord bot's settings-change watcher could never fire.
CREATE TRIGGER users_notify AFTER INSERT OR UPDATE OR DELETE ON users
    FOR EACH ROW EXECUTE FUNCTION notify_table_change();
CREATE TRIGGER settings_notify AFTER INSERT OR UPDATE OR DELETE ON settings
    FOR EACH ROW EXECUTE FUNCTION notify_table_change();
