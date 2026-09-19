DROP TRIGGER IF EXISTS logos_notify ON logos;
DROP TRIGGER IF EXISTS roles_notify ON roles;
DROP TRIGGER IF EXISTS role_permissions_notify ON role_permissions;
DROP TRIGGER IF EXISTS user_roles_notify ON user_roles;
DROP FUNCTION IF EXISTS notify_owner_change();
