# Users, Roles & Permissions

Login accounts (users) are how *people operate TimeKeeper*. They are separate
from team members (see [Overview](../app/overview.md#accounts-vs-team-members)).

## The Users view

Admin-only table of `Username + Roles` (chips), searchable by username or role.
The default `admin` user is **hidden** from the list.

Creating / editing a user:

- **Username**
- **Password** — on edit, *"Password (leave blank to keep)"*
- **Roles** — a checkbox list of available roles, each with its description.

  > "This is not team membership — students and mentors live under Team and have
  > no login. Without a role a user can sign in but do nothing else."

![Users view](../assets/screenshots/users.svg)

<!-- CAPTURE: users — Users table with role chips -->

## The two built-in roles

Built by migration `0005_default_roles`:

| Role | `is_super` | Effective access |
|------|------------|------------------|
| **admin** | yes | Everything, on every resource — super roles bypass per-resource checks entirely. |
| **kiosk** | no | Unattended check-in station: **read** `team_members`, `sessions`, `locations`, `rfid_tags`, `settings`; **write** `team_member_sessions` (check-in/out). Nothing else — users and statistics are unreachable. |

More roles can be created; each is either *super* or carries explicit grants.

## Resources

Permissions are attached to **resources**. TimeKeeper's registry
(`0001_init/up.sql`):

`locations` · `notifications` · `rfid_tags` · `sessions` · `session_rsvps` ·
`settings` · `statistics` · `team_members` · `team_member_sessions` · `users`

## Permission levels

Levels are **ceiling-ordered**:

```
read < write < delete
```

A `write` grant satisfies a `read` requirement; `delete` satisfies both. The
effective level on a resource is the **max** across all of a user's roles
(`user_permissions` view), and a user with no roles has no permissions.

## How enforcement works

1. At **login**, the server resolves the user's effective permissions and bakes
   them into the **JWT** as `"resource:level"` claims.
2. Every mutation **re-checks the claim server-side**. Client-side gating (the
   rail, buttons) is convenience, not a security boundary.
3. Because the snapshot is taken at sign-in, **a role change takes effect on the
   user's next login** — a freshly demoted admin stays admin until they
   re-sign-in.

Tokens expire after **7 days**; sessions survive until then.

## Access sanity rules

- **Admin rail** = `settings: write` (what `isAdmin` means on the client).
- **RFID scanning UI** = any permission at all (logged-in non-admin kiosk
  operator).
- **Quick PIN** is server-authoritative: resolving a PIN requires the
  `quick_pin_enabled` setting plus a login — the client never compares PINs.
