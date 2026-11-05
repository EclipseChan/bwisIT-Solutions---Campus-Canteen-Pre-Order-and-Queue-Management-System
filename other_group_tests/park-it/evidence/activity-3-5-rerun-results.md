# Activities 3–5 rerun evidence — 2026-11-05

**Source:** Output pasted by the user after running `evidence\activity-3\rerun-activities-3-5.ps1`. The password was not included in the output.

## Activity 3 — Temporary installation and startup

- PHP lint: 17 files, 0 failures.
- Loopback HTTP status: 200; login page rendered.
- Disposable database initialization reported success.
- Admin and Staff login both reached the dashboard.
- Both authenticated roles could open the vehicle module.
- Anonymous monitoring API request returned HTTP 401.
- The test database already contained one `parking_zone` row: the recovery marker inserted after the earlier backup. Consequently, the idempotent seed script reported success but did not create its usual default `Main Parking Lot`. The test copy used the existing disposable data; no original application files were changed.

## Activity 4 — Database and application access

- Connection target: `parkit_test_20261105_1429`, user `postgres`.
- The server reported `rolsuper=t`, `rolcreatedb=t`, and `rolcreaterole=t`.
- Tables present: `parking_zone`, `payment`, `staff_user`, `transaction`, and `vehicle`.
- Application users present: `admin`/`Admin` and `staff`/`Staff`.
- Both authenticated roles reached the dashboard and opened the vehicle module. The anonymous monitoring endpoint returned HTTP 401.
- No non-superuser PostgreSQL role, database-level allowed/denied operation, or least-privilege test was run. The successful DB connection used a superuser.

## Activity 5 — Monitoring and maintenance

- PostgreSQL 18.6; disposable test database size reported as `8294 kB`.
- Estimated live/dead rows: `parking_zone` 1/0, `staff_user` 2/0, and 0/0 for `payment`, `transaction`, and `vehicle`.
- The session query returned the current `postgres` session as active.
- Logging settings: `stderr`, collector enabled, `log_min_duration_statement=-1`.
- The server's log-directory listing returned five log-file names, sizes, and modification timestamps. Log file contents were not read or reviewed.
- `ANALYZE VERBOSE` completed on all five application tables. `VACUUM (ANALYZE, VERBOSE)` completed on `parking_zone`; it reported one live tuple and no dead tuples.
- Read-only `EXPLAIN (ANALYZE, BUFFERS)` returned one grouped zone row and zero active transactions. The plan used `HashAggregate` over a `Nested Loop Left Join`; planning time was `4.276 ms`, execution time `0.104 ms`. These timings on one test zone are not a representative workload benchmark.
