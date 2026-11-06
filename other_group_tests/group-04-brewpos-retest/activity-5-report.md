# Activity 5 — Maintenance and monitoring

**Status: Passed with issues**  
**Run date:** 2026-11-05  
**Scope:** Safe health, size, activity, table-statistics, and log checks against the disposable retest database; `ANALYZE`/`VACUUM` only on that database; the documented daily-sales query and its plan. Production monitoring, alerting, retention, and scheduling are explicitly out of scope.  
**Environment:** PostgreSQL 18.6, isolated cluster `127.0.0.1:55457`, database `grp_brewposdb`, uptime ≈ 9 minutes at capture, 2 staff / 4 categories / 12 items / 7 orders / 12 lines.

## Results

| Check | Observed |
|---|---|
| Server version | PostgreSQL 18.6, x86_64-windows, 64-bit |
| Postmaster start / uptime | `2026-11-05 10:49:52 +08` / `00:09:03` |
| Database size | `8406 kB` (`8,607,423` bytes) |
| Connections | 11 backends: 10 app pool connections (`PostgreSQL JDBC Driver`, idle) + 1 `psql`; `max_connections=100` |
| Transaction counters | 296 commits, 22 rollbacks; 9 disk block reads, 26,025 buffer hits |
| Temp files / deadlocks / conflicts | 0 / 0 / 0 |
| Transaction-ID age | 84 (no wraparound pressure) |
| Autovacuum | on (`naptime=60`, thresholds 50) |
| Archiving | `archive_mode=off`; `wal_level=replica` |
| Extensions | `plpgsql 1.0` only |
| Logging | `log_connections=on`, `log_disconnections=on`, stderr; `log_min_duration_statement=-1`, `log_statement=none` |
| `ANALYZE` + `VACUUM (VERBOSE, ANALYZE)` | Completed on the disposable DB; dead tuples dropped to 0 on all five application tables |
| Daily-sales query | `net_sales = 1371.00`, `completed_orders = 5` — matches the Activity 3 UI total |
| Query plan | Sequential scans of `order_ticket` and `order_line_item`, hash join, sort; planning `0.107 ms`, execution `0.038 ms` |

### Table statistics before / after maintenance

The pre-maintenance counters were visibly stale (`n_live_tup` 7/23/21/12/4 vs. actual 4/12/12/7/2, with dead tuples present). After `VACUUM (VERBOSE, ANALYZE)` all five tables reported `n_dead_tup=0`, refreshed live estimates, and fresh `last_vacuum`/`last_analyze` timestamps. This is expected for a short-lived test database that had just received UI traffic.

### Daily-sales plan (abridged)

```
Aggregate
  -> Sort (order_id)
       -> Hash Join (l.order_id = t.order_id)
            -> Seq Scan on order_line_item l (12 rows)
            -> Hash
                 -> Seq Scan on order_ticket t (5 rows)
                      Filter: order_timestamp >= CURRENT_DATE
                              AND order_timestamp < CURRENT_DATE + 1
Execution Time: 0.038 ms
```

`EXPLAIN ANALYZE` executes the query. It is read-only here, so running it did not change data. At this data volume the planner correctly prefers sequential scans; the plan says nothing about behaviour at production scale.

### Log evidence

The isolated cluster log shows connection authorization, SCRAM authentication for `brewpos_app`, application queries, expected `permission denied` errors from the Activity 4 denial tests, and normal disconnections. Logging is stderr-only with the collector off, so there is no rotation/retention configuration to assess.

## Issues and limitations

1. **These are local checks, not production monitoring.** No Prometheus/Grafana export, alert thresholds, on-call routing, retention policy, or scheduled maintenance was supplied or can be inferred from this cluster. Health was sampled once, not trended.
2. **No WAL archiving / PITR.** `archive_mode=off`; backups must be handled by `pg_dump`/filesystem methods. Activity 6 covers a logical dump only.
3. **No slow-query or per-statement telemetry.** `log_min_duration_statement=-1` and `log_statement=none`; `pg_stat_statements` is not installed. Workload analysis at production scale is not possible from this setup.
4. **Statistics were stale before maintenance.** This is normal for a fresh test DB, but it shows why scheduled `ANALYZE`/autovacuum matters after bulk changes.
5. **Small-data plan.** Sequential scans are appropriate for 7 orders / 12 lines. No index recommendation should be inferred without production volumes.
6. **`VACUUM` is not a substitute for backups** and does not reclaim files to the OS without `VACUUM FULL` (not run; unnecessary here). Maintenance ran only on the disposable retest database.

## Verdict

The disposable database was healthy, maintenance completed cleanly, the documented sales query returned the expected total, and the plan was inspected safely. Because monitoring, alerting, retention, and scheduling cannot be verified from this local setup, the activity is **Passed with issues**.

## Evidence

- Condensed health report: [`evidence/activity5-health-summary.log`](evidence/activity5-health-summary.log)
- Full health/maintenance/plan output: [`evidence/activity5-health.log`](evidence/activity5-health.log)
- SQL used: [`evidence/activity5-health.sql`](evidence/activity5-health.sql)
- Server log excerpt: [`evidence/activity5-server-log-excerpt.log`](evidence/activity5-server-log-excerpt.log)
