**Status: Passed with issues** | **Date:** 2026-11-05 | **Test scope:** Static application/schema review and role/login checks against the disposable PostgreSQL database `parkit_test_20261105_1429`.

# Activity 4 — Access control

## Checks and outcomes

- The schema defines five application tables and their sequences. It assigns objects to `postgres`, but contains no project-specific `CREATE ROLE`, `GRANT`, or `REVOKE` setup.
- The disposable database contains the expected five tables: `parking_zone`, `payment`, `staff_user`, `transaction`, and `vehicle`.
- The authenticated account is `postgres`; PostgreSQL reports it as a superuser with `CREATEDB` and `CREATEROLE`. The information-schema listing showed table privileges for `postgres`; it did not establish least-privilege behavior for an application login.
- The PHP database configuration is set to connect as `postgres`. This is not a demonstrated least-privilege application account.
- Application identities have `Admin` and `Staff` values in `staff_user`. Login verifies the stored password hash. Reviewed route guards require a logged-in user; an `isAdmin()` helper exists, but no role-specific use was found in the reviewed source.
- The project does not define an owner-approved privilege matrix for Admin versus Staff. Therefore no role-specific access expectation was assumed.
- Rerun: both Admin and Staff logins reached the dashboard and could open the vehicle module; the unauthenticated monitoring API request returned HTTP 401.
- No non-superuser PostgreSQL role, database-level allowed/denied operation, membership, or least-privilege test was performed.

## Issues and limitations

The `postgres` application connection and absence of schema role/grant setup warrant owner review. Whether Admin and Staff should have different application permissions remains unspecified; both roles were permitted to open the tested vehicle module. The live database check used a superuser, so database-account least privilege remains unverified.

**Evidence:** [Schema and application access-control review](evidence/activity-4/access-control-review.md), [Activities 3–5 rerun results](evidence/activity-3-5-rerun-results.md)  
**Environment:** Database reads, application seed/login checks, and maintenance were limited to the explicitly authorized disposable test database and temporary application copy. The existing `grp_parkitdb` and production were not accessed.
