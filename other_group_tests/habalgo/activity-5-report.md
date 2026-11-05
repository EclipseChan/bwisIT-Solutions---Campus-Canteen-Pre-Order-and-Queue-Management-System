Status: **Pass with limitation**
Date: 2026-11-05 (Asia/Manila, UTC+08:00)
Test scope: Read-only health, activity statistics, and logging-configuration checks for the local PHP application and disposable PostgreSQL database; no production monitoring.

## Checks and outcomes

- PostgreSQL `pg_isready` reported that `127.0.0.1:5432` was accepting connections.
- The dashboard and `options`, `customers`, `vehicles`, `bookings`, `payments`, and `ratings` API reads all returned HTTP 200. The `options` response included the 10 seeded drivers; the other entity tables remain empty.
- Read-only PostgreSQL checks returned server version, database transaction/buffer statistics, active connection counts, and logging settings.
- The logging collector was enabled and PostgreSQL reported an active log file. Log contents were not read.
- No maintenance SQL, `ANALYZE`, `VACUUM`, or `EXPLAIN ANALYZE` was run; no database settings or records were changed.

## Issues and blockers

- Maintenance-command execution and query-plan review remain unverified; no maintenance window was requested for the disposable database.
- Although logging was enabled and an active file was confirmed, log contents and retention were not reviewed.
- Evidence is limited to read-only local checks. No production monitoring was performed.

## Evidence

- [Local health and monitoring checks](./activity-5/evidence/local-health-log.txt)
