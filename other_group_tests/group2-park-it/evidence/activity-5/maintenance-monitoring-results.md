# Activity 5 database evidence — 2026-11-05

**Target:** `parkit_test_20261105_1429` on local PostgreSQL 18.6. Test database only; no production database was accessed.

- Database size: `8246 kB`.
- The five expected application tables were present. `pg_stat_user_tables` reported 0 estimated live rows and 0 dead rows for each. No prior `last_analyze` or `last_autoanalyze` was recorded.
- `ANALYZE VERBOSE` succeeded for `parking_zone`, `payment`, `staff_user`, `transaction`, and `vehicle`; each table was empty (0 pages, 0 live rows, 0 dead rows).
- The activity snapshot returned the current `postgres` connection as `active` in the test database.
- PostgreSQL settings: `log_destination=stderr`, `logging_collector=on`, `log_min_duration_statement=-1`. This checks configuration only. No server log content was read; duration-based statement logging is disabled with the reported value `-1`.
- `EXPLAIN (ANALYZE, BUFFERS)` was run on a read-only `SELECT` left-joining parking zones to active transactions. It returned zero rows. The plan used `HashAggregate` over a `Nested Loop Left Join`; `planning time=0.846 ms`, `execution time=0.092 ms`. Because both tables were empty, these figures are not a performance baseline.
- `VACUUM` was not run, and no application data was inserted or changed during these checks.

## Rerun — 2026-11-05

The Activity 3–5 rerun initialized two staff accounts and used the pre-existing recovery marker as the database's only parking-zone row.

- Database size: `8294 kB`. Estimated rows: one `parking_zone`, two `staff_user`, and zero each in `payment`, `transaction`, and `vehicle`; all reported zero dead rows.
- `ANALYZE VERBOSE` completed for all five tables. `VACUUM (ANALYZE, VERBOSE)` completed on `parking_zone`, reporting one live tuple and no dead tuples.
- Settings remained `stderr`, logging collector enabled, and `log_min_duration_statement=-1`. The PostgreSQL log-directory query listed five files with sizes/timestamps, but no log file contents were read.
- `EXPLAIN (ANALYZE, BUFFERS)` returned one zone group, zero transactions, with planning time `4.276 ms` and execution time `0.104 ms`; this is not representative workload evidence.
- See [combined Activities 3–5 rerun output](../activity-3-5-rerun-results.md).
