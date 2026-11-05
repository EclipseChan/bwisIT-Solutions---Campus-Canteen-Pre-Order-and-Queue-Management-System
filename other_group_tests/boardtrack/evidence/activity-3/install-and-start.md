# Activity 3 evidence — install and startup

- Source: user-supplied BoardTrack folder; run from a separate temporary copy under the Windows temp directory.
- `npm ci --no-audit --no-fund`: exit code 0; installed 94 packages.
- PostgreSQL service: `postgresql-x64-18`, Running; PostgreSQL 18.6; TCP `127.0.0.1:5432` reachable.
- Created disposable database `boardtrack_test_20261105_2254`; startup output:

  ```text
  migrated 001_schema.sql
  seeded   001_sample_data.sql
  BoardTrack running at http://localhost:3000
  ```

- `GET /login`: HTTP 200; login form and BoardTrack title present.
- Unauthenticated `GET /`: HTTP 302 to login.
- Screenshot: [login.png](login.png), captured from the running local app.
- No `.env` or credential was added to the application or reports. The local PostgreSQL passfile was used without printing its password.
- The supplied project has no `test` script; this evidence covers installation/startup and HTTP readiness.
