# Activity 5 evidence — 2026-11-05

- Windows service `postgresql-x64-18`: `Running`.
- `pg_isready -h 127.0.0.1 -p 5432 -t 3`: `127.0.0.1:5432 - accepting connections` (exit 0).
- Listener addresses observed: `0.0.0.0:5432` and `[::]:5432`. This does not establish firewall exposure or external reachability.
- A later interactive `psql -W` connection succeeded to the `postgres` database as `postgres` on port `5432`. No password was included in evidence.
- Activity 5 checks were subsequently run in the new disposable database `parkit_test_20261105_1429`; see [maintenance and monitoring results](maintenance-monitoring-results.md).
