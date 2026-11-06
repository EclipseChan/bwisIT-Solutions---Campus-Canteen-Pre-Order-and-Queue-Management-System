# Restaurant Online Ordering & Table Reservation System — Test Summary

**Run date:** 2026-11-05  
**Project:** Binary Sisters, COMP 018 — PHP 8.1+ and PostgreSQL 18  
**Scope:** Activities 3–6, following `REUSABLE-GROUP-TESTING-PROMPT.md`. Activity 3 and the Activity 4 role/CRUD checks were retested from the supplied ZIP using an isolated disposable PostgreSQL 18.6 cluster.

| Activity | Status | Summary |
|---|---|---|
| [Activity 3 — Installation](activity-3-report.md) | **Passed with issues** | PHP 8.2.12 started the app and `/health` passed when PostgreSQL extensions were enabled for the test process; they remain disabled in `php.ini`. |
| [Activity 4 — Access control](activity-4-report.md) | **Passed with issues** | Retest: 26/26 role-matrix checks and 25/25 CRUD/integrity checks passed; password setup/authentication remains unverified. |
| [Activity 5 — Maintenance and monitoring](activity-5-report.md) | **Passed with issues** | Health, ANALYZE/VACUUM, and query-plan checks ran; the health template under-reports sequence count for the maintenance role. |
| [Activity 6 — Backup and recovery](activity-6-report.md) | **Passed with issues** | Backup restored and all eight table row counts matched; restore defaults widened database CONNECT access. |

## Cross-activity findings

- PHP is installed at `C:\xampp2\php\php.exe`, but the current shell does not resolve `php` from PATH, and `pdo_pgsql`/`pgsql` are disabled in the active `php.ini`. The retest enabled them only for the test process; no application source files were changed.
- The archive's `database/setup.ps1 -WithRoles` path calls `database/roles/03_set_passwords.psql`, but that file is absent. The script does not check the call's exit code before proceeding, so it may print a ready message without setting the documented role passwords.
- The database setup and retested role/CRUD checks ran only in a new loopback-only temporary PostgreSQL cluster. The existing PostgreSQL service was not used. The temporary server, cluster, and extracted ZIP copy were removed after testing.
- The Activity 5 health query reports zero sequences for restricted roles even though the database has seven. The cause is the query's use of `information_schema.sequences`, which hides sequences the current role cannot access.
- The restored database has a default database ACL (`datacl IS NULL`). A temporary login role denied CONNECT on the source could connect to the restored database. Reapply the intended database-level grants before using a restored database.
- The custom-format backup was stored outside the repository, verified, and deleted. The temporary cluster and extracted inspection copy were removed after testing. No credentials or backup data are included here.

## Evidence

Each activity report links to its evidence files under the corresponding `activity*-evidence/` folder. Results are limited to this local disposable test environment; no production database, production log source, or real user credentials were tested.
