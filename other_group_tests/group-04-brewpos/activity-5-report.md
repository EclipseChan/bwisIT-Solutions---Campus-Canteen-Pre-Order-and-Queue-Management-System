# Activity 5 — BrewPOS monitoring and maintenance report

**Status: Passed with issues**  
**Run date:** 2026-11-05  
**Environment:** Disposable PostgreSQL 18.6 cluster; database `grp_brewposdb`.

## Results from earlier disposable-cluster checks

| Check | Result |
|---|---|
| Database health | PASS — PostgreSQL accepted connections; all 5 expected public tables were present. |
| Database size and activity | PASS — database size was approximately 8.3 MB; session and table statistics were queryable. |
| Maintenance | PASS — `ANALYZE VERBOSE` and `VACUUM (VERBOSE, ANALYZE)` completed. |
| Daily sales query | PASS — the query completed successfully using the guide's date-bounded order/line-item calculation. |
| Query plan | PASS — `EXPLAIN (ANALYZE, BUFFERS)` completed (about 0.15 ms on the small seed dataset). Sequential scans are expected at this test-data size. |
| PostgreSQL logs | PASS with limitation — local server log output was available and recorded the two expected permission-denial checks. Logging was configured to stderr with the collector off. |

**Issues and limitations:** This was a small, single-machine dataset. No production alerting, centralized log retention, capacity thresholds, scheduled maintenance, or long-running workload monitoring was configured or assessed. The denied-operation errors in the local log were intentional Activity 4 tests, not unexpected application errors.

## Independent verification on the working copy — 2026-11-05

Read-only checks on the running app's isolated PostgreSQL 18.6 cluster confirmed the following current-instance snapshot:

| Check | Result |
|---|---|
| Database size / connections | PASS — 8334 kB; 10 idle application sessions and one active check session; `max_connections=100`. |
| Activity counters | PASS — 436 commits, 1 rollback, 412 block reads, 26539 buffer hits, 0 temp files, and 0 deadlocks at capture time. |
| Server settings | PASS with limitation — autovacuum on; `archive_mode=off`; `log_min_duration_statement=-1`; `log_statement=none`. |
| Daily-sales query and plan | PASS — 1371.00 across 5 orders, matching the browser report; hash join and sequential scans took 0.093 ms execution time on this small dataset. |
| Table statistics | ISSUE — current estimates showed dead tuples on `menu_item`, `order_ticket`, and `order_line_item`; no manual VACUUM was run against the active app database. |

The report's earlier VACUUM/ANALYZE result came from a disposable test database. Maintenance was not repeated on this currently running instance to avoid changing its operational state. Production monitoring, alerting, log retention, backup scheduling, and long-term workload behavior remain unverified. Overall status remains **Passed with issues**.
