# Activity 5 evidence — maintenance and monitoring

- PostgreSQL 18.6; disposable database size was approximately 9 MB.
- The database contained 8 public base tables. Seed counts: 2 properties, 6 rooms, 4 tenants, 4 leases, 6 payments, 4 utility bills, 3 app users.
- `pg_stat_activity` showed the app and test connections in the disposable database.
- `ANALYZE` completed successfully on the disposable database.
- Read-only plan check: `EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM v_lease_summary WHERE tenant_id = 1 ORDER BY lease_id;`
  - Returned 1 row; execution time 0.166 ms.
  - As requested, note that `EXPLAIN ANALYZE` executes the query; this query was a read-only `SELECT`.
- Room state check: 2 AVAILABLE, 1 MAINTENANCE, 3 OCCUPIED; active leases: 3.
- PostgreSQL logging configuration: `log_destination=stderr`, `logging_collector=on`; active log path reported as `log/postgresql-2026-11-04_000000.log`.
- Application startup log was captured in [Activity 3 evidence](../activity-3/install-and-start.md). Shared PostgreSQL log contents were not read.
- `VACUUM` was not run because the database was freshly seeded and too small to warrant it.

