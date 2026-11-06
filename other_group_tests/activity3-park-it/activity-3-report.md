# Activity 3 — Park-It installation report

**Status: PASS — local install and startup verified.**  
**Date:** 2026-11-05  
**Device:** Windows, Node.js/npm and PostgreSQL 18.6  
**Source:** `park-it-database-main.zip`

The archive was extracted to a temporary local copy. Dependencies installed successfully with npm. The supplied schema and seed data loaded into a disposable local PostgreSQL database, and the application server started successfully against it.

| Check | Result |
|---|---|
| Dependency installation | PASS — npm install completed; the runtime-validation replay also completed `npm ci`. |
| Server syntax and startup | PASS — `server.js` syntax check passed and the server started. |
| Home page | PASS — `GET /` returned HTTP 200. |
| Database connection | PASS — `GET /api/test` returned HTTP 200 against the disposable database. |
| Main data route | PASS — `GET /api/zones` returned HTTP 200. |
| Smoke test | PASS — 1 test passed; required application dependencies and files were available. |

**Validation summary:** 5 checks passed, 0 failed.

**Scope:** This confirms the supplied application can be installed and started on this Windows device in a temporary test copy. A disposable PostgreSQL cluster/database was used; the existing PostgreSQL service and any peer database were not changed. The temporary test workspace was removed after validation. This was not a permanent application installation or a test of production credentials.

**Setup issue noted:** The README refers to `.env.example`, but the archive contains `.envexample`. For this test, database settings were supplied through temporary environment variables rather than creating a credentials file. The archive's setup instructions should be corrected for a repeatable manual setup.
