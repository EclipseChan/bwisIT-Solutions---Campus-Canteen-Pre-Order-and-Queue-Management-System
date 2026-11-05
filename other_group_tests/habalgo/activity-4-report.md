Status: **Passed with issues**
Date: 2026-11-05 (Asia/Manila, UTC+08:00)
Test scope: Review of the supplied HabalGo API, database schema, and role/privilege script, followed by isolated role-enforcement checks in the user's disposable local PostgreSQL database.

## Checks and outcomes

- Reviewed the HabalGo schema and API operations to identify database access needs. The API reads driver, location, booking, customer, vehicle, payment, and rating data; it also writes relevant customer, vehicle, booking, payment, rating, location, and driver-vehicle records.
- Reviewed `database/03_roles_and_privileges.sql`: it defines a runtime group with SELECT/INSERT/UPDATE/DELETE on every schema table and sequence usage, plus a read-only group with SELECT on all schema tables.
- Temporary roles using the checked-in script's intended grant pattern were created for the test. A PostgreSQL session operating as the read-only role could SELECT but was denied INSERT, UPDATE, and DELETE. A session operating as the runtime role completed a synthetic customer INSERT, UPDATE, and DELETE inside a rolled-back transaction.
- Runtime permissions for schema usage, CRUD on the customer table, and sequence usage were present; read-only permissions were limited to schema usage and SELECT.
- The synthetic row was rolled back and verified absent. Temporary roles and grants were removed; a follow-up check found no test roles or probe rows remaining.
- Following the user's driver seed load, the read-only role successfully read all 10 driver records and remained unable to INSERT, UPDATE, or DELETE in `habalgo.driver`. The runtime role completed a synthetic driver INSERT, UPDATE, and DELETE inside a rolled-back transaction; the seed rows were preserved.
- Role privileges were tested with `SET ROLE` in an authenticated administrator session; direct login/password authentication for the temporary accounts was not tested.
- The inspected API/UI source did not show an application login or per-user authorization check; this retest covers database roles, not application-level authorization.

## Issues and blockers

- The checked-in role script was not executed: it grants CONNECT on `grp00_habalgodb`, whereas the disposable test database is `habalgo_test_20261105`. It also contains fixed login password literals; do not use it as-is in a shared or production environment.
- The runtime grants are broader than the inspected API's observed needs; for example, the runtime group grants writes to the driver table although the inspected API only reads drivers.
- Group number, owner requirements, and approved role mapping were not supplied. Findings about least privilege are based only on the checked-in API and SQL, not owner-approved requirements.
- No production verification was performed.

## Evidence

- [Schema review and live role checks](./activity-4/evidence/source-review.txt)
