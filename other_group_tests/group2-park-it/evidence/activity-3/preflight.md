# Activity 3 evidence — 2026-11-05

## Initial attempt

- Source reviewed: `Park it\park-it-database-final`; test ran against a temporary copy only.
- PHP CLI: 8.5.12. `pdo_pgsql` was present.
- XAMPP Apache executable: 2.4.58.
- PHP syntax: `php -l` passed for all 17 PHP files in the temporary copy.
- Server check: PHP built-in server started on `127.0.0.1`; one `GET /` returned HTTP 200. The response contained the application's database-connection error and did not render the login form.
- The temporary copy's database name was changed to a unique disposable-test name so it would not target `grp_parkitdb`. That database was not created.
- PostgreSQL service-level readiness passed, but a read-only `psql -X -w` connection probe failed with `fe_sendauth: no password supplied`. No password was requested or recorded.
- The server process was stopped after the request. No screenshot was taken because the application UI did not load.

## Rerun results — 2026-11-05

- Repeated the temporary-copy PHP lint check: all 17 PHP files passed.
- PHP 8.5.12 and `pdo_pgsql` remained available; XAMPP Apache reported 2.4.58.
- PostgreSQL service `postgresql-x64-18` was running and `pg_isready` accepted connections on loopback port 5432.
- The local app returned HTTP 200 and rendered the login page; database initialization reported success; Admin and Staff logins reached the dashboard; both opened the vehicle module; anonymous monitoring returned HTTP 401.
- The disposable test database already had a parking-zone recovery marker. The seed script saw that existing zone and did not create its default Main Parking Lot.
- For the full Activity 3–5 rerun output, see [rerun results](../activity-3-5-rerun-results.md). The [rerun script](rerun-activities-3-5.ps1) prompts locally for the database password without writing it into the script or evidence.
