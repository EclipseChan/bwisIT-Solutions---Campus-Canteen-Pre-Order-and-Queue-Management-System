# Activity 4 evidence — superuser-connection retest

**Run date:** 2026-11-05 (Asia/Manila, UTC+08:00)  
**Environment:** Local PostgreSQL 18.6; fresh disposable database `boardtrack_activity4_superuser_20261105_2303`; temporary copy of BoardTrack. The database and app were removed/stopped after testing.

- The app started successfully with `DATABASE_URL` using the local `postgres` login.
- `pg_stat_activity` showed the application session connected as `postgres`.
- Role inspection: `session_user=current_user=postgres`; `rolsuper`, `rolcreatedb`, `rolcreaterole`, `rolreplication`, and `rolbypassrls` were true.
- Effective privilege inspection returned `can_select`, `can_insert`, `can_update`, and `can_delete` true for each of the 8 public tables.
- A `BEGIN` / `INSERT` / `UPDATE` / `DELETE` / `ROLLBACK` probe succeeded; a subsequent marker-row count was zero. No persistent data was changed.
- Superuser `SELECT` returned all 4 sample tenant rows; zero public tables had row-level security enabled.
- Over HTTP with the same app/database connection, tenant login redirected successfully, `/leases` returned 200 with Juan visible and Maria excluded, and anonymous `/properties` returned 302 to `/login`.

These are local disposable-environment observations, not production verification. Superuser privileges bypass application/database least-privilege boundaries for direct database access; observed tenant filtering was in the application query layer.
