# Activity 4 — BrewPOS access-control report

**Status: Passed with issues**  
**Run date:** 2026-11-05  
**Environment:** Disposable PostgreSQL 18.6 cluster; database `grp_brewposdb`.

## Results from earlier disposable-cluster checks

| Check | Result |
|---|---|
| App role attributes | PASS — `brewpos_app` can log in, but is not a superuser and has no `CREATEDB`, `CREATEROLE`, replication, or inherited-role privileges. |
| Schema access | PASS — `public` schema USAGE is granted; CREATE is denied. |
| Runtime table grants | PASS — read access to staff; menu category/item CRUD; order and line-item SELECT/INSERT only. |
| Sequence access | PASS — required ID sequences have SELECT/USAGE. |
| Allowed operations | PASS — category, item, and order inserts succeeded inside a transaction that was rolled back. |
| Order immutability | PASS — UPDATE and DELETE against `order_ticket` were denied by PostgreSQL. |
| Unrelated database access | ISSUE — `brewpos_app` successfully connected to both `postgres` and `template1`. |
| Future objects | ISSUE — no explicit default privileges were configured for objects added later. |
| Password authentication | NOT TESTED — the isolated cluster used loopback `trust` authentication. |

The supplied app-role script provides effective access to current application tables and sequences. However, the role inherits PostgreSQL's default database CONNECT access, so it is not restricted to the application database. The absence of default privileges means later tables/sequences may not receive the current grants automatically. These are configuration gaps to review before production; no policy changes were made to the submitted project.

**Scope limitation:** Results reflect the supplied role script and this disposable cluster only, not a production server or an owner-approved privilege policy.

## Independent verification on the working copy — 2026-11-05

The attached working copy and the source tree used by the running app matched across 85 non-runtime files by SHA-256 (excluding local configuration, database files, build output, and logs). Read-only checks against its isolated PostgreSQL 18.6 cluster on port 5433 confirmed:

| Check | Result |
|---|---|
| Role attributes and per-database settings | PASS — `brewpos_app` is a login role without superuser, database/role creation, replication, or `BYPASSRLS` privileges; `search_path=public`, `statement_timeout=30s`, and `lock_timeout=10s` were set. |
| Table privileges | PASS — category/item CRUD; SELECT/INSERT only on orders and line items; SELECT only on staff. |
| Sequence privileges | PASS — USAGE/SELECT granted, UPDATE denied, on all four application sequences. |
| Authentication | PASS — correct app credentials connected; an incorrect password was rejected; host authentication rules use SCRAM-SHA-256. |
| Historical and staff mutation | PASS — privilege introspection confirmed UPDATE/DELETE unavailable for order history and INSERT/UPDATE/DELETE unavailable for staff. |
| Unrelated database CONNECT | ISSUE — `brewpos_app` also connected to `postgres` and `template1`, consistent with PostgreSQL's default PUBLIC CONNECT privilege. |
| Default privileges | ISSUE — `pg_default_acl` had no entries. Future objects may need explicit grants. |

No grants or server configuration were changed in this verification. As in the original run, the current object privileges are appropriate for the application, while cross-database CONNECT and future-object grants remain deployment-hardening considerations. Overall status remains **Passed with issues**.
