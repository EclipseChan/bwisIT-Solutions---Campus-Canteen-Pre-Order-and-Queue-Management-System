# Database user and role setup

No passwords appear in this file or anywhere in the repository.

## Activity 3 (current)

The API connects as `canteen_admin`, the database owner, created by `database/setup.*` with
the password from `.env`. This is simple but gives the application more power than it needs.

## Intended setup for Activity 4

Not created yet. Names are fixed here so the application roles in
[user-roles.md](user-roles.md) map to them consistently.

| Application role | Database role | Type | Intended privileges |
|---|---|---|---|
| Application runtime (all API traffic) | `canteen_app` | LOGIN, member of `canteen_app_grp` | Through the group role below |
| (privileges of the runtime) | `canteen_app_grp` | NOLOGIN group | SELECT, INSERT, UPDATE on all 7 tables; DELETE on `menu_item` only; USAGE on all sequences |
| Administrator reports (optional separate login) | `canteen_readonly_grp` | NOLOGIN group | SELECT on all tables |
| Schema owner and migrations | `canteen_admin` | LOGIN, owner | Owns the database and tables; used only for setup, not by the running API |

Why these privileges: the API deletes rows only in `menu_item` (when an item has no past
orders). Everything else is inserts and updates. It also calls `pg_advisory_xact_lock`
when assigning queue numbers, which needs no special grant.

Student, Vendor and Administrator users are rows in `student` and `vendor`, not database
logins. The API checks their role itself and connects as `canteen_app`.

## Sketch for Activity 4 (not executed in Activity 3)

```sql
CREATE ROLE canteen_app_grp NOLOGIN;
CREATE ROLE canteen_readonly_grp NOLOGIN;
CREATE ROLE canteen_app LOGIN PASSWORD '<set outside Git>' IN ROLE canteen_app_grp;

GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO canteen_app_grp;
GRANT DELETE ON menu_item TO canteen_app_grp;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO canteen_app_grp;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO canteen_readonly_grp;
```
