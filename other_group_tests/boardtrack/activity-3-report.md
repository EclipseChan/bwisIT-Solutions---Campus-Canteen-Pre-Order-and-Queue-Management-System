# Activity 3 — Installation

**Status: Pass**  
**Date:** 2026-11-05 (Asia/Manila, UTC+08:00)  
**Scope:** Installed a temporary copy of the user-supplied BoardTrack project, initialized a fresh local disposable PostgreSQL database, started the application, and verified its login page. BoardTrack's group number was not supplied. No production service was accessed.

## Results

| Check | Result |
|---|---|
| Dependency installation | `npm ci --no-audit --no-fund` completed successfully in the temporary copy (94 packages). |
| PostgreSQL | Local PostgreSQL 18.6 service was running and reachable on `127.0.0.1:5432`. |
| Database initialization | Created only `boardtrack_test_20261105_2254`; schema, extensions, and demo seed data initialized successfully. |
| Application startup | `node src/server.js` reported `BoardTrack running at http://localhost:3000`. |
| HTTP readiness | `GET /login` returned 200; unauthenticated `GET /` redirected to login (302). |
| GUI evidence | A fresh login-page screenshot was captured. |

The app's documented setup creates the schema and sample data automatically. PostgreSQL authentication succeeded using the local passfile over IPv4; an initial IPv6 `localhost` probe did not match that passfile and was retried against `127.0.0.1`. This was a connection-path issue, not an application startup failure. The project has no `test` script in `package.json`; this activity verified installation and startup, not a unit-test suite.

## Issues and limitations

- The supplied README identifies the project as BoardTrack, COMP 018, Activity 3, but does not provide a group number. No official class-tracker confirmation was available.
- The tested process used the local PostgreSQL `postgres` superuser; least-privilege database access is covered separately in Activity 4.
- This is local disposable-environment evidence only and does not establish production installation or operation.

## Evidence

- [Install and startup checks](evidence/activity-3/install-and-start.md)
- [Captured login page](evidence/activity-3/login.png)
