DELETE FROM role_permissions WHERE role_id IN (SELECT id FROM roles WHERE name = 'kiosk');
DELETE FROM roles WHERE name = 'kiosk';
