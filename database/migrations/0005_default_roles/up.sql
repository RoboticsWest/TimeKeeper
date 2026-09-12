-- Built-in login roles, restoring what the pre-rebuild version enforced.
--
-- IMPORTANT: these are roles for *users* - login accounts for operating TimeKeeper. They are
-- not team membership. A student or mentor on the team is a `team_members` row with a
-- `member_type`; they have no username, no password and cannot sign in. The old Role enum did
-- list STUDENT and MENTOR, but nothing ever checked them - every guard in the old server was
-- either Role::Admin (37 call sites) or Role::Kiosk (1, on check-in/out). So there are exactly
-- two useful roles, and adding more here would just re-conflate accounts with team members.
--
-- The rebuild kept the roles/permissions tables and the `require_permission` guards but never
-- created any role except `admin`, so every user made through the UI had no permissions at all.

INSERT INTO roles (name, description, is_super) VALUES
    ('admin', 'Full access to everything.', true),
    ('kiosk', 'Unattended check-in station. Can record check-ins and nothing else.', false)
ON CONFLICT (name) DO NOTHING;

-- Kiosk: identify a member by card and record a check-in/out. Read-only everywhere else, and
-- no access at all to users or statistics.
INSERT INTO role_permissions (role_id, resource_slug, level)
SELECT r.id, v.slug, v.lvl::permission_level
FROM roles r
CROSS JOIN (VALUES
    ('team_members',         'read'),
    ('sessions',             'read'),
    ('locations',            'read'),
    ('rfid_tags',            'read'),
    ('settings',             'read'),
    ('team_member_sessions', 'write')
) AS v(slug, lvl)
WHERE r.name = 'kiosk'
ON CONFLICT (role_id, resource_slug) DO NOTHING;
