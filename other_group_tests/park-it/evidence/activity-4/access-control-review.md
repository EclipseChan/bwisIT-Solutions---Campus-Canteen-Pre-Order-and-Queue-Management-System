# Activity 4 evidence — 2026-11-05

Static review covered the target's `schema.sql`, `config\database.php`, `auth\login.php`, `includes\functions.php`, and reviewed route handlers.

- The schema defines `parking_zone`, `payment`, `staff_user`, `transaction`, and `vehicle`, with related sequences.
- The schema assigns table/sequence ownership to `postgres`; no project `CREATE ROLE`, `GRANT`, or `REVOKE` statements were found.
- Application connection configuration names `postgres`; no separate runtime or read-only database account is configured.
- The `staff_user.role` values are read into the session. `requireLogin()` checks login state; `isAdmin()` checks the Admin value. No role-specific caller of `isAdmin()` was found in the reviewed source.
- No Admin/Staff privilege matrix or owner-approved database-role requirements were supplied.
- Read-only queries against the newly created disposable database `parkit_test_20261105_1429` confirmed the five expected tables.
- The authenticated account was `postgres`; PostgreSQL reported `rolsuper=t`, `rolcreatedb=t`, and `rolcreaterole=t`. The displayed table-privilege output showed privileges for `postgres`; the `postgres` superuser is not evidence that an application account has least privilege. The output was paged and the user stopped at `-- More --`.
- No non-superuser role/membership test or allowed/denied operation test ran.
- On the repeat application run, both `Admin` and `Staff` successfully logged in and opened the vehicle module. An unauthenticated monitoring API request returned HTTP 401. No database operations as a non-superuser role were tested.

The source observations are static; the live observations are read-only and apply only to the disposable test database. Neither establishes least-privilege application behavior.

For detailed rerun observations, see [Activities 3–5 rerun results](../activity-3-5-rerun-results.md).
