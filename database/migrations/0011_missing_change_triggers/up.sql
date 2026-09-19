-- Change notifications for the tables that were still missing them.
--
-- `notify_table_change()` (0001, amended in 0007) covers every table whose primary key is a
-- single `id` column. Three UI-visible tables were left out, and one of them could not use the
-- generic function at all:
--
--   * user_roles          - join table, no `id` column
--   * roles               - has `id`, simply never got a trigger
--   * logos               - has `id`, simply never got a trigger
--
-- Deliberately still excluded, because nothing reads them from the client:
--   * secrets                    - the JWT signing key
--   * resources                  - the static permission catalogue, seeded by migration
--   * session_rsvp_messages      - internal Discord message -> session mapping
--   * __diesel_schema_migrations - diesel's own bookkeeping


-- A change to a child row is a change to its parent -------------------------------------------
--
-- Assigning a user a role writes to `user_roles`, never to `users` - so `users_notify` does not
-- fire and a client holding `User.roles` never hears about it. Rather than inventing a
-- `user_roles` subscription that no client wants, the trigger reports the change *as* a change
-- to the owning row, which the existing `userChanges` subscription already handles: the server
-- re-fetches the user and the new roles come with it.
--
-- TG_ARGV[0] is the table name to report, TG_ARGV[1] the column holding the owner's id.
CREATE FUNCTION notify_owner_change() RETURNS trigger AS $$
DECLARE
    owner_table text := TG_ARGV[0];
    owner_col   text := TG_ARGV[1];
    owner_id    text;
    rec         record;
BEGIN
    -- NEW is unassigned on DELETE, so pick the row that actually exists.
    IF TG_OP = 'DELETE' THEN
        rec := OLD;
    ELSE
        rec := NEW;
    END IF;

    EXECUTE format('SELECT ($1).%I::text', owner_col) INTO owner_id USING rec;

    PERFORM pg_notify(
        'db_changes',
        json_build_object(
            'table', owner_table,
            -- Always an UPDATE from the owner's point of view: the user still exists, its roles
            -- changed. Reporting INSERT/DELETE here would tell a subscriber to add or drop the
            -- user itself.
            'op', 'UPDATE',
            'id', owner_id
        )::text
    );
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER user_roles_notify AFTER INSERT OR UPDATE OR DELETE ON user_roles
    FOR EACH ROW EXECUTE FUNCTION notify_owner_change('users', 'user_id');

CREATE TRIGGER role_permissions_notify AFTER INSERT OR UPDATE OR DELETE ON role_permissions
    FOR EACH ROW EXECUTE FUNCTION notify_owner_change('roles', 'role_id');


-- Tables that just never got the generic trigger ----------------------------------------------
CREATE TRIGGER roles_notify AFTER INSERT OR UPDATE OR DELETE ON roles
    FOR EACH ROW EXECUTE FUNCTION notify_table_change();

-- Single-row table keyed on a boolean, like `settings`; 0007 already casts the id to text so the
-- payload is a JSON string rather than `true`.
CREATE TRIGGER logos_notify AFTER INSERT OR UPDATE OR DELETE ON logos
    FOR EACH ROW EXECUTE FUNCTION notify_table_change();
