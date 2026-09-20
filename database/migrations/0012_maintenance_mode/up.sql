-- Maintenance mode.
--
-- A single operator-controlled flag, used while a deploy is half-finished and the server, client
-- and bot are not necessarily in agreement yet. The client shows a dismissable banner; the
-- Discord bot refuses every command outright, since a half-updated bot acting on a command is
-- worse than not answering.
--
-- The flag lives on `settings` rather than in a config file so that flipping it takes effect
-- immediately for every connected client through the existing `settings_notify` trigger (0011),
-- with no restart and no deploy.
ALTER TABLE settings
    ADD COLUMN maintenance_mode boolean NOT NULL DEFAULT false;

-- Operator-supplied reason, shown verbatim in the banner and the bot's reply. Empty means "use
-- the built-in wording" rather than "show an empty banner", so turning maintenance on without
-- writing a message still reads sensibly.
ALTER TABLE settings
    ADD COLUMN maintenance_message text NOT NULL DEFAULT '';
