# Activity 4 evidence — access control

All requests targeted `http://127.0.0.1:3000` and the local disposable seed database. No successful write was submitted.

| Role | Request/check | Expected | Observed |
|---|---|---:|---:|
| Admin | Login; GET `/properties`, `/rooms`, `/tenants`, `/leases`, `/payments`, `/bills`, `/properties/new` | 302 login; then 200 | All matched |
| Staff | GET `/properties`, `/rooms`, `/rooms/1/edit`, `/tenants/new`, `/leases/new`, `/payments/new`, `/bills/new` | 200 | All matched |
| Staff | GET `/properties/new`, `/properties/1/edit`, `/rooms/new`; POST `/properties` | 403 | All matched |
| Tenant | GET `/leases`, `/payments`, `/bills` | 200; own rows only | All matched; Juan present, Maria absent on each page |
| Tenant | GET `/properties`, `/rooms`, `/tenants`; POST `/payments` | 403 | All matched |
| Anonymous | GET `/properties` | 302 to login | Matched |
| Invalid credentials | POST `/login` | Redirect back to login | 302 to `/login` |

## Superuser-connection retest

The app was restarted against a new disposable database with `DATABASE_URL` configured for the local `postgres` login. PostgreSQL `pg_stat_activity` confirmed an app session with `usename=postgres`.

- Role inspection: `session_user=current_user=postgres`; `rolsuper`, `rolcreatedb`, `rolcreaterole`, `rolreplication`, and `rolbypassrls` were all true.
- Effective privilege checks returned SELECT/INSERT/UPDATE/DELETE = true for all 8 public tables.
- A disposable CRUD probe inserted, updated, and deleted a temporary property inside one transaction, then issued `ROLLBACK`; the follow-up count for the test marker was zero.
- The database superuser could read all 4 seeded tenant rows. No public table had row-level security enabled.
- Through the same app/superuser DB connection, the tenant UI continued to show Juan's rows and exclude Maria's rows; anonymous `/properties` access remained redirected to login.

**Interpretation:** app-level authorization and tenant filtering worked for the exercised HTTP requests, but they do not restrict the PostgreSQL superuser. A compromised app or leaked DB credential could bypass those checks, read other tenants' rows, and modify database contents. BoardTrack's role documentation labels restricted DB roles as a future setup plan; no dedicated runtime/read-only DB roles were provisioned or tested. This is a least-privilege gap in this test configuration, not evidence about another deployment.
