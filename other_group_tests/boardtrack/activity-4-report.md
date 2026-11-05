# Activity 4 — Access control

**Status: Passed with issues**  
**Date:** 2026-11-05 (Asia/Manila, UTC+08:00)  
**Scope:** Reviewed BoardTrack's documented application/database role model and exercised login, page permissions, denied writes, tenant row filtering, and the PostgreSQL superuser connection against fresh local disposable test databases. The superuser write probe was rolled back; no persistent records were changed. No production database was accessed.

## Results

| Check | Result |
|---|---|
| Admin application role | Login succeeded; all six data pages and the property creation form returned 200. |
| Staff role | Read access to properties and rooms, room edit and tenant/lease/payment/bill creation forms allowed; property create/edit and room create denied with 403. A property-create POST was denied with 403 before a write. |
| Tenant role | Own leases, payments, and bills returned 200; properties, rooms, and tenants returned 403. A payment-create POST was denied with 403 before a write. |
| Tenant row scope | Lease, payment, and bill pages contained Juan's sample rows and excluded Maria's rows. |
| Authentication | Unauthenticated protected-page access redirected to login (302); invalid credentials redirected back to login (302). |
| Application's database connection | Retested with the app configured as `postgres`. `pg_stat_activity` confirmed the app connection used that account. |
| Database superuser | `session_user=current_user=postgres`; `rolsuper`, `rolcreatedb`, `rolcreaterole`, `rolreplication`, and `rolbypassrls` were all true. The superuser could SELECT, INSERT, UPDATE, and DELETE every public table. |
| Superuser access probe | In a transaction on the disposable database, inserted, updated, and deleted a temporary property, then rolled back. Follow-up count was zero. |
| Database tenant isolation | The superuser could read all 4 seeded tenant rows. No public table had row-level security enabled. |
| App-layer tenant filter with superuser DB connection | Tenant login still returned only Juan's lease data and excluded Maria's; anonymous access still redirected to login. |

Application-level permissions behaved as documented for the tested requests, including when the app used the superuser connection. However, the app's role restrictions are enforced by its application code: the database superuser itself has unrestricted access and bypasses row-level security. BoardTrack's documentation describes `boardtrack_owner`, `app_runtime_grp`, `app_readonly_grp`, and `boardtrack_app` as a planned setup, not an executed Activity 3 configuration; no restricted runtime DB login or DB-level row filtering was tested. The superuser result reflects this isolated run's setup and is not evidence that production is configured the same way.

## Issues and limitations

- **High-priority least-privilege gap:** the tested app connection was PostgreSQL `postgres` with superuser, role-management, replication, database-creation, and RLS-bypass attributes. If application DB credentials were exposed or the app were compromised, application-level roles would not constrain direct database access. Configure and verify a dedicated restricted runtime login before treating DB-level access control as complete.
- **Database row isolation is absent:** no public table had RLS enabled; tenant isolation was observed only in the application queries. Verify database-level policy separately if it is required by the approved design.
- Admin write forms were checked, but no allowed create/update/delete operation was performed to avoid unnecessary data changes. Denied operations were verified without writes.
- Application role checks do not prove direct database-role isolation or production enforcement.

## Evidence

- [Access-control results](evidence/activity-4/access-control-results.md)
- [Superuser-connection retest](evidence/activity-4/superuser-connection-retest.md)
- Role definitions and permission table: [user-roles.md](../../../../CrucilloTest/BoardTrack-main/docs/user-roles.md) and [auth.js](../../../../CrucilloTest/BoardTrack-main/src/auth.js)
