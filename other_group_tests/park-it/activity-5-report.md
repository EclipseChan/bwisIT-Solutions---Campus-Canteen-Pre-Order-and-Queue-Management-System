**Status: Passed with issues** | **Date:** 2026-11-05 | **Test scope:** Health, session, logging-configuration, maintenance-statistics, and read-only query-plan checks against the disposable database `parkit_test_20261105_1429`.

# Activity 5 — Maintenance and monitoring

## Checks and outcomes

- Windows service `postgresql-x64-18` was running. `pg_isready -h 127.0.0.1 -p 5432` reported that the server accepts connections.
- The local listener is bound to `0.0.0.0:5432` and `[::]:5432`. Firewall rules and external reachability were not tested.
- The initial health check reported PostgreSQL 18.6, database size `8246 kB`, and empty application tables. The subsequent Activity 3 rerun initialized two staff accounts and used an existing test parking-zone marker; its health check reported size `8294 kB`, one zone row, two staff rows, and zero rows in payment, transaction, and vehicle.
- `ANALYZE VERBOSE` completed on all five application tables; the rerun found one live parking-zone row and two staff rows, with no dead tuples.
- The session snapshot showed the current `postgres` session as active in the test database.
- Logging settings were `log_destination=stderr`, `logging_collector=on`, and `log_min_duration_statement=-1`. The log-directory query listed five filenames, sizes, and modification times. Log contents were not reviewed; duration-based statement logging is disabled by the reported `-1` setting.
- `VACUUM (ANALYZE, VERBOSE)` completed for `parking_zone`, reporting one live tuple and no dead tuples.
- The read-only `EXPLAIN (ANALYZE, BUFFERS)` query returned one grouped zone row and no active transactions; it used a hash aggregate and nested-loop left join. Planning time was 4.276 ms and execution time was 0.104 ms. One zone is not a representative performance workload.

## Issues and limitations

The database contains only the seed users and one test zone, so its plan and timings are not representative of a real workload. Log metadata was listed but the actual log contents were not reviewed. No production monitoring or maintenance was performed.

**Evidence:** [Service readiness](evidence/activity-5/postgres-readiness.md), [initial maintenance and monitoring results](evidence/activity-5/maintenance-monitoring-results.md), [Activities 3–5 rerun results](evidence/activity-3-5-rerun-results.md)  
**Environment:** Disposable local database only; no production database was accessed.
