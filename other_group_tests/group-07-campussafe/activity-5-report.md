# Activity 5 — CampusSafe maintenance and monitoring report

**Status: Passed with issues**  
**Run date:** 2026-11-05  
**Environment:** Disposable PostgreSQL 18.6 cluster; seeded CampusSafe database.

## Results

| Check | Result |
|---|---|
| Health and capacity snapshot | PASS — PostgreSQL 18.6; database size 8,942 kB; all 9 application tables and database activity statistics were queryable. |
| Integrity checks | PASS — supplied verification queries found 0 unverified-report metadata violations, 0 missing resolved timestamps, and 0 orphaned assignments. |
| Maintenance | PASS — `ANALYZE VERBOSE` and `VACUUM (VERBOSE, ANALYZE)` completed for the documented operational tables. |
| Query plans | PASS — both documented `EXPLAIN (ANALYZE, BUFFERS)` queries completed (about 0.052 ms and 0.104 ms). PostgreSQL used sequential scans/hash joins, reasonable for the small seeded tables. |
| Server logs | PASS with limitation — local PostgreSQL log captured startup and expected permission-denial checks from Activity 4. |

**Issues and limitations:** This was a low-volume, single-device test. Production alerting, centralized log retention, capacity thresholds, scheduled maintenance, and sustained workload behavior were not configured or evaluated. The recorded permission errors were intentional negative access tests.
