# HANDOFF — TimeKeeper pagination work

**Trust git + `cargo build`, not this file.** Where this file and the compiler disagree, the
compiler wins.

---

## 1. Objective

Make paged list queries go through a single server-side GraphQL `*Page` return (items +
`total_count`), with the same narrowing applied to the count and the page, and wire the Flutter
client to consume those pages instead of pulling the whole table and filtering client-side.

**Attendance (`team_member_session`) is the reference implementation.**

---

## 2. Where things stand

Last commit on `main` when this pass started: `632956e Added pagination & deferred poison
detection` (pagination for attendance / session / team_member). Everything below is on top of
that and **uncommitted**.

### Server — all green

`cargo check`, `cargo clippy` and `cargo test` (38 tests) all pass; `cargo fmt` applied.

| Domain | Paged query | Filter fields |
|---|---|---|
| `team_member_session` | `attendance` | from, to, member/session/location ids, member types, checkedInOnly, search |
| `session` | `sessionPage` | (pre-existing) |
| `team_member` | `teamMemberPage` | search, memberTypes, hasDiscord, hasQuickPin |
| `location` | `locationsPage` | search |
| `user` | `usersPage` | search |
| `notification` | `notificationsPage` | sessionId, teamMemberId, notificationTypes, statuses, from, to, search |

Each follows the same repo → logic → gql shape: a `*Filter` struct plus a `filtered_*!` macro in
`repository.rs`, a `query_page` delegate in `logic.rs`, and a `*FilterInput` + resolver in
`gql.rs` using `page_bounds` + `Page::new`.

`gql_common.rs` declares the concrete generics (`LocationPage`, `UserPage`, `NotificationPage`,
…); all of them now have a resolver behind them.

### Client

Every list view is now wired to its server `*Page` query. `client_pagination.dart`
(`useClientPagination`) has no callers left in `lib/` — it is still exercised by
`test/paged_list_test.dart` and was left in place rather than deleted; drop both if you don't
want the helper around.

| View | Provider | Search covers |
|---|---|---|
| attendance | `attendance_page_provider` | member name + structured filters |
| sessions | `session_page_provider` | — |
| team | `team_member_page_provider` | first/last/display name |
| locations | `location_page_provider` | location name |
| users | `user_page_provider` | username **or role name** (EXISTS subquery) |
| notifications | `notification_page_provider` | location, member name, type, status |

---

## 3. Gotchas that already cost time

1. **`*FilterInput` lives in `gql.rs`**, the plain `*Filter` struct in `repository.rs`. Import
   only the latter from `super::repository`.
2. **Never `.clone()` a boxed diesel query.** A `BoxedSelectStatement` is not `Clone`; the
   `filtered_*!` macros exist so the query is *rebuilt* for the count and again for the page.
3. **Narrow in SQL, never after loading.** `users` excluded the built-in admin by filtering the
   loaded `Vec`. Doing that to a page would drop a row from the page while still counting it in
   the total, so the last page renders short and the pager promises a row that never appears.
   `filtered_users!` excludes the admin inside the query that also produces the count.
4. **`nulls_last` on nullable sort keys.** `notifications.scheduled_for` is nullable and Postgres
   sorts NULLs *first* under `DESC`, which would float the condition-driven kinds above every
   scheduled reminder.
5. **Order by a unique tiebreaker.** Without one, rows with equal sort keys can appear on two
   pages or none.
6. **The server pager must clamp its offset.** Rows get deleted, or a realtime delta refetches,
   and the current page falls off the end of the collection. The server answers honestly with an
   empty page, leaving a blank table under a "0-150 of 150" label. `PagedAsyncNotifier.load()`
   re-fetches at the last real page; `ClientPaginationState` already did this and the server-side
   pager did not. Covered by `test/paged_notifier_test.dart`.
7. **`locations` is deliberately unauthenticated**, like `sessions` and `teamMemberSessions`: the
   kiosk and calendar are public routes (`router.dart` — they sit outside `_protectedRoute`) and
   both need the location list to render. Adding a `require_permission` there breaks the kiosk.
   The guard belongs on `locationsPage`, not on `locations`.

---

## 4. Two search subtleties worth keeping

**Users — role names.** The view searches username *and* role name. Roles live in `user_roles`
+ `roles`, so `filtered_users!` matches them with an `EXISTS` subquery rather than a join: a user
holding two matching roles would otherwise be returned twice, inflating `total_count` and pushing
a row off the page.

**Notifications — rendered labels.** The list shows labels (`pending` renders as "Scheduled",
`session_start_reminder` as "Session Start Reminder") while the server matches raw column values.
`NotificationFilterState._serverSearchTerm()` swaps a typed label for its code, whole-string only
so it cannot hijack a search for a location or member with a similar name.

This *cannot* be done by also sending `statuses`/`notificationTypes`: the server ANDs those with
`search`, so it would narrow the result to nothing rather than widen it. The joins for location
and member name live in `filtered_notifications!` — note `team_members` must stay a **left** join,
since `team_member_id` is null for every session-wide reminder.

## 5. Formatting

Dart formats at **120 columns**, matching `rustfmt.toml`'s `max_width`. This is now enforced by
`client/analysis_options.yaml`:

```yaml
formatter:
  page_width: 120
```

Before that existed, a plain `dart format` silently reflowed files to the 80-column default —
which is what happened to four views in the previous pass. The whole of `client/lib` has now been
normalised to 120.

---

## 6. Verification

```bash
cd server && cargo check && cargo clippy && cargo test && cargo fmt
cd client && flutter analyze && flutter test && dart format lib test
```

All green: clippy clean, 38 server tests, 67 client tests.

### Live API smoke test (done, 2026-09-20)

Run against a throwaway database so real data is untouched — the embedded Postgres picks a random
port, read it from line 4 of `.pgdata/postmaster.pid`:

```bash
PGPORT=$(sed -n 4p .pgdata/postmaster.pid)
PGPASSWORD=postgres psql -h localhost -p $PGPORT -U postgres -c "CREATE DATABASE tk_smoketest;"
DATABASE_URL="postgres://postgres:postgres@localhost:$PGPORT/tk_smoketest" \
  ./target/debug/main --graphql-port 4002 --web-port 8082 --no-web
```

Confirmed against that instance:

- `locations` answers **unauthenticated** (the kiosk/calendar fix) while `locationsPage` returns
  "Authentication required".
- `totalCount` stays constant across pages and `hasMore` flips correctly on the last page.
- `usersPage` excludes the built-in admin — including when the search term is literally
  `"admin"`, which matches the *role* and returns only the role-holder.
- `usersPage` search matches role names as well as usernames.
- `notificationsPage` returns session-wide reminders (null `team_member_id`) — the left join does
  not drop them — and sorts a null `scheduled_for` **last**.
- `notificationsPage` search reaches the joined location name and member surname.

UI behaviour is left to manual testing.

---

## 7. Key files

| Responsibility | Path |
|---|---|
| Reference impl (attendance) | `server/src/domains/team_member_session/{repository,logic,gql}.rs` |
| `page_bounds` + `Page<T>` + concretes | `server/src/gql_common.rs` |
| Paging state mixin | `client/lib/providers/paged_notifier.dart` |
| Page fetch helper | `client/lib/providers/paged_query.dart` |
| Example wired view | `client/lib/views/locations/locations_view.dart` |
| Notification type/status labels | `client/lib/models/notification.dart` |
| Filter → server-variable tests | `client/test/page_filter_test.dart` |
| Pager edge cases | `client/test/paged_notifier_test.dart` |

---

## 8. For reference (original prompts that drove this work)

Kept verbatim as source-of-truth context. Later sections of this document summarise what was
done; where they disagree, these prompts are what was actually asked for.

### Prompt 1

Okay, main parts of this projects is client and server we need to make a few updates. It's brand new so there are some minor bugs. Most of which seem client related. You have access to marionette, and flutter marionette on the flutter project. So I expect a full run through of logic and testing. One major issue is that we need a global standard on time. THe db correctly stores everything as UTC as it should because the db could be on any server. The client however should parse that time in whatever the current locale is by detection. There is already some logic for timezone by the server specifically for notification settings so we know when to actually send notifications. But there are many places on the frontend for information being incorrect with the time. Likely because it's showing the raw UTC time, create a time utility under utils and whenever time is ever used, make it parse it, dart has decent methods for the equivalent of traits. So it should work well for DateTime conversions. Next is the realtime system, every single UI or page on the client is supposed to be hooked up with data that comes from a GraphQL subscription. So when the database is updated, that update is pushed to the UI. I was told by a different agent that all data in the db was setup correctly with a trigger, and all gql subscriptions were hooked up correctly. However that must not be correct, because for sessions page when a session is added the ui does not update, causing a bug. EVERYTHING needs to have that subscription link. There should already be providers for it, so per page we have a proper link setup for the query so when it's updated, we get info. As far as I understand each page does an initial grab of data, before waiting on the subscription to provide any updates. As should be the case similar to the older version of TimeKeeper v1.3.0 where it had it's subscription model setup https://github.com/RoboticsWest/TimeKeeper/tree/v1.3.0 have a look at server specifically for that type of initial provider. Double check every page and all data links to make sure it's properly realtime so we don't have this bug keep happening where the ui doesn't update after a successful addition or update to the db.

Next is how the core notification system works, there are two issues here. One is that we currently have it setup so it auto checks out users a couple hours before the next session. I want this to be switched around. So instead it's on the last session, so if 24 hours after the end of the last session has passed it will auto checkout users. Instead of currently where by default it waits 4 hours before the start of the next session to auto checkout users. I want it to be configurable where it's a default of 24 hours from the endtime of the last session to auto check people out. And then also at the start of the next session to auto check out people as well. This way we get it better. So basically, lamen terms, we're changing the auto checkout time from 4 hours to 0 hours (not configurable) for the upcoming/next session. But then we're also adding in a configurable value of 24 hours, so at the end of the last session if 24 hours have passed or if the next session has started, auto checkout anyone still lingering around.

After that is also the notification system, there are quite a few times when the admins forget to create a session a few days before. And do it instead a few hours before. And because by default the notification system is built in to send a message 24 hours before the start of the session. It sends a discord message to the server and it's rather confusing because of the wording. Two things to do here, one add another variable param to the message formats. (We currently have {date}. {time} etc...) I want another that is like {day} or {weekday} or something. That way the message can at least be somewhat managed to be correct. So instead of saying "Session on Tomorrow at 1pm" it goes "Session on Today at 1pm" or "Session on Wednesday at 1pm" The current ACTUAL message is @here Don't forget! Session on tomorrow from {start_time} to {end_time} @ **{location}** so we just need to add another param so that `tomorrow` is more configurable and cleaner. I also think that on session creates like this, we should have logic to stop an instant message going out. So a warning preferably to the user which maybe gets sent from the server if it sees it's going to do that. And then a yes or no confirm on if it should send out a reminder. Likewise the notification system in general is a bit odd, it relies on "sent" to be the method of will this be sent or not to the server. Which can be a bit of a problem, especially if they are deleted, then what? System goes through and sees we haven't sent a message when we should have. So it does it again. I don't know if it's already in there, but notifications should likely be linked to the sessions table. That way in the server it's easier to see how to send messages for a particular session. Maybe when a session is created, it creates all the notification types at once, with a isSent, whenTo send etc.../trigger status and so on. This way it's bound to sessions, which is easier for the server to check how to send notifications. But it's also easier to delete, and also see that when a session is created maybe 2 reminders are created like session start reminder, session end reminder. Etc... when they will be sent, and if they are sent. Of course there will also be the other reminders as well which get auto created like after 15 minutes at the end of the session. But this is probably a lot better in terms of organising. And stops cascading effects of deleting a reminder only for it to be sent again due to logic loops rather than logic checks against the session db. I think this is much cleaner. And also allows a user to remove those default messages which will likely be attached to the session as well like start/end so they don't get pesky messages if they don't want to.

Next is the statistics page statistics unsure if it's server side or client side where the main issue is. But the first few sets of widgets are incorrect. It seems to be measuring total hours from every user as a metric. Which is really dumb and should not be used at all. There is never a need to know the total combined hours of all team members. Only session hours. It was likely built like that by accident because of how the statistics are calculated. The members hours is correct because it's info per member. But the total hours, regular, overtime, overtime percent, activity over time and location by ranking. Are all displayed using total hours or calculated using total hours rather than session hours. If I have 2 sessions, each scheduled for 5 hours, with maybe an hour of overtime for each of them. Then the total amount of hours is 12 hours. regular 10 hours, overtime 2 hours. It should not be calculated by adding all people. So it's like 300 hours total.... This is just blatantly wrong. We should update the sessions in the db, so they have start time, end time (like they currently do) but then actual start time, and actual end time. Because we already calculate properly if a session is finished or not based on the last person who leaves. And technically that's when the session finishes. When people actually leave. Which is likely where the confusion came from on activity over time and total hours. This way we do it via sessions. Not via total people. Because while we use people to calculate it initially. We should be looking at sessions. Maybe some extra fields to handle that, like time first in, and time last out. Or something.... basically when it actually started and actually ended. That way we can check overtime based on the scheduled start/end times in the session. Which will be much easier to calculate.

Make a plan for all this and then execute it. This is production already, so we will need migrations for the changes in the db as needed.

### Prompt 2

continue. When finished auto format all code in dart and in rust.

also a side note. The discord bot does not display the leaderboard for mentors for some reason. It just says "no attendance data". Can you fix it up? (it may be because of leaderboard checkbox, for reference if it has "only show certain users" in leaderboard, it's only showing those. But specifically if a person goes out of their way to do !leaderboard students or !leaderboard mentors then it should show the leaderboard. That setting is just for the default leaderboard shown on the client and in discord) Also it would be nice to fixup the checked in as well. It's formatted really strangely, it would be better if it could be cleanup because it's hard to see. All messed up on the rows and columns. Make it similar to leaderboard. Also a separate note which will need a lot of thinking as well, updates. There is no way to really do OTA updates I think because of this flutter project. And it's deployed to github, best I can do it either show a popup to the user telling them this is an outdated version either from the server (probably the best solution) or from github. And basically every few hours the client just pops up a message with specifically a link to the latest version on github. Which should just be https://github.com/RoboticsWest/TimeKeeper/releases/latest or whatever.

But checking from github isn't too bad either. I'd like some way of doing OTA or doing an auto update, where the popup just says "auto update" and somehow it magically downloads the binary, decompresses it and replaces the current instance with the next. But it's not clean. Best to just have it link to the latest version on github and let the user handle it. I think only it should do a popup though if it's the major or minor version. Not the patch, because 1.2.3 changes to 1.2.4 because of a typo, but server works fine no need to deploy client or force them to update with an annoying message that pops up every hour or so.

Side side note, anything else we should chuck into the discord bot? It's fairly bland at the moment. Functionality wise there isn't much I want users to do, on purpose. But maybe more info or other options to see things maybe. It could be good, buttons, paginations. etc...

side side note, extra filters on certain pages would be good. Like attendance, team members and sessions. Along with pagination for them. So we can get a better understanding for attendance for the current day or last 100 etc... or for a person, or for mentors in general, or between certain times etc... Pagination might also need to be built into the api, because i can forsee over time we will accumulate hundreds of sessions, and tens of thousands of attendance records. Which wouldn't be efficient to pull all at once for the client. So best to think about it early.

Also add a 50 character limit for the quick pin, both db and ui entry.

Also delete claude from the contributor list on github. And make a note to never commit anything under claude again. (Fix prior commits and make sure nothing is ever under calude or shared with claude again).
