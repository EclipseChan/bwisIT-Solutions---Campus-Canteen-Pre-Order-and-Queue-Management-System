# Activity 5 — Park-It maintenance and monitoring report

**Run date:** 2026-11-05  
**Environment:** Same disposable PostgreSQL 18.6 cluster and `park_it_a4a6_test` database as [Activity 4](../activity4-park-it/activity-4-report.md). Results describe a one-row seeded test database, not a production workload.

## Results

| Check | Result |
|---|---|
| Health | PASS — PostgreSQL 18.6; 5 public tables, 5 sequences; database size 8,254 kB; one session in the inspected snapshot. |
| Activity and roles | PASS — session state and the six test roles were returned. All login roles remained non-superuser and without `CREATEDB`/`CREATEROLE`. |
| Logs | PARTIAL — `log_destination=stderr`, `logging_collector=off`; the temporary server's stderr was captured by `pg_ctl` in the test log. Expected permission-denied and unrelated-database CONNECT denials were recorded. No production log source or log-retention behavior was assessed. |
| Maintenance | PASS — `ANALYZE` and standalone `VACUUM (ANALYZE)` completed for `public.parking_zone`; the final estimate was 1 live row and 0 dead rows. `VACUUM FULL` was not run. |
| Query plan | PASS — a read-only `EXPLAIN (ANALYZE, BUFFERS)` query completed. With only one row, PostgreSQL used a sequential scan and sort; planning time was 1.694 ms and execution time was 0.119 ms. These timings are not representative performance results. |

## Evidence and scripts

- [Health, session, role, statistics, and logging queries](health-activity-checks.sql)
- [Query-plan query](query-plan.sql)
- [Health and activity output](activity5-health-and-activity.txt)
- [Query-plan output](activity5-query-plan.txt)
- [Maintenance output](activity5-maintenance.txt)
- [Captured server-log summary](activity5-server-log-summary.txt)

**Limitations:** No Park-It maintenance window, authorized production maintenance account, monitoring threshold, log access policy, or workload baseline was supplied. These operations exercised only the disposable local database.
