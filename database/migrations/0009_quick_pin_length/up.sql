-- Bound the quick PIN's length.
--
-- 0004 deliberately allowed any length ("four digits through a phone number"), but unbounded
-- means a paste accident can store an arbitrarily large value in a column that is typed at a
-- kiosk keypad. 50 characters is far more than any real PIN and still a definite limit, so the
-- database agrees with the UI instead of trusting it.
--
-- Existing values are all far shorter than this; the constraint is validated against them on
-- creation, so a violation here would surface at migration time rather than silently.
ALTER TABLE team_members
    ADD CONSTRAINT team_members_quick_pin_length
    CHECK (quick_pin IS NULL OR char_length(quick_pin) <= 50);
