-- Quick PIN sign-in: a third kiosk check-in method alongside RFID and name
-- search, for members who don't carry a card.
--
-- Stored in plaintext and readable by admins, by design: a PIN is a
-- convenience credential for an attendance kiosk, not a security boundary, and
-- admins need to be able to tell a member what theirs is. Any length is
-- allowed (four digits through a phone number).
--
-- Uniqueness is required, not cosmetic: a PIN typed at a kiosk carries no other
-- identifying information, so it has to resolve to exactly one member.
ALTER TABLE team_members ADD COLUMN quick_pin text;

CREATE UNIQUE INDEX team_members_quick_pin_key
    ON team_members (quick_pin)
    WHERE quick_pin IS NOT NULL;

ALTER TABLE settings ADD COLUMN quick_pin_enabled boolean NOT NULL DEFAULT false;
