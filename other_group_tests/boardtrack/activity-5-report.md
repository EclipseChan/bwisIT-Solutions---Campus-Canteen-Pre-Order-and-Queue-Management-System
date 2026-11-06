# Activity 5 — Maintenance and monitoring

**Status: Passed with issues**  
**Date:** 2026-11-05 (Asia/Manila, UTC+08:00)  
**Scope:** Collected PostgreSQL health/activity and application startup evidence, ran `ANALYZE` on the disposable database, and reviewed an executed read-only query plan. No production database or records were involved.

## Results

| Check | Result |
|---|---|
| Database health | PostgreSQL 18.6; disposable DB size approximately 9 MB; 8 public base tables with seeded sample data. |
| Activity | App and test sessions were visible in `pg_stat_activity`. |
| Maintenance | `ANALYZE` completed successfully. `VACUUM` was not run because this small, freshly seeded test database had no maintenance need. |
| Query plan | `EXPLAIN (ANALYZE, BUFFERS)` for the tenant-filtered lease summary completed in 0.166 ms and returned one row. This executed a read-only `SELECT`. |
| Logging | PostgreSQL logging collector was enabled with `stderr` destination; the server reported an active log file. The Node application startup message was captured. |

## Issues and limitations

- PostgreSQL log contents, retention, alerting, and review procedures were not assessed. The shared server log was not read.
- The tiny seed database is not representative of production scale; the query-plan timing is only a local observation.
- No monitoring dashboards or production alerts were verified.

## Evidence

- [Maintenance, health, and monitoring observations](evidence/activity-5/maintenance-monitoring.md)

