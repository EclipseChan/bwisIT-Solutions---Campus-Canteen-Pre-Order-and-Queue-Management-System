# Activity 5 — Maintenance and Monitoring

**Status: Passed with issues**  
**Run date:** 2026-11-05  
**Test scope:** Collect database health/activity/log evidence, review maintenance need, run safe maintenance, and inspect an application-shaped query plan.

## Results

Checks ran against the same disposable PostgreSQL 18.6 database used for Activity 4, not a production database.

- Health checks succeeded as both `rors_maint` and `rors_report`. The database had eight tables, 19 indexes, four views, and seven sequences. Both restricted-role health outputs reported **zero sequences**, which is an inaccurate count: a comparison showed `information_schema.sequences` returns zero for `rors_maint` while the PostgreSQL catalog reports seven. The health template should count sequence objects from a catalog view that does not require sequence access, or clearly label the count as role-visible sequences.
- The maintenance review and the project's `ANALYZE` plus standalone `VACUUM (VERBOSE, ANALYZE)` commands succeeded as `rors_maint`. No `VACUUM FULL` was run. After maintenance, all eight tables reported zero dead tuples.
- An `EXPLAIN` and `EXPLAIN (ANALYZE, BUFFERS)` were run as `rors_report` on a safe SELECT matching the order-list query in the application. For seeded customer ID 15, the estimate and actual result both returned five rows; execution took 0.100 ms with six shared-buffer hits. Sequential scans are reasonable for this small seeded database and are not a production performance benchmark.
- The temporary server used `stderr` logging with `logging_collector=off`; `log_min_duration_statement` was `-1`, so statement-duration logging was disabled. The stderr scan found two permission-denied entries from the deliberate negative access tests and one `FATAL: role "Marcos" does not exist` during temporary-cluster startup. The source of that startup entry was not conclusively established. It was not attributed to the application, which was not running.

The project health/review/maintenance SQL templates were executed with `psql` as `rors_maint` or `rors_report` against `grp_binarysisters_projectdb` on `127.0.0.1:59959`; each command exited 0. The actual query-plan command and output are recorded in the evidence file.

## Issues and limitations

- **Health-check accuracy:** the sequence count is role-visibility-dependent and misleading for the maintenance/report roles. Use a catalog-based object count or report the visibility limitation.
- The dead-tuple, query-plan, and log findings describe only the seeded disposable database. No production workload, production log source, retention policy, or monitoring thresholds were assessed.

## Evidence

- [Health checks as maintenance role](activity5-evidence/health-maintenance.txt)
- [Health checks as read-only role](activity5-evidence/health-readonly.txt)
- [Sequence visibility comparison](activity5-evidence/sequence-visibility.txt)
- [Maintenance review](activity5-evidence/maintenance-review.txt)
- [ANALYZE/VACUUM output](activity5-evidence/maintenance-run.txt)
- [Application-shaped query plan](activity5-evidence/query-plan.txt)
- [Temporary server log scan](activity5-evidence/server-log-scan.txt)
