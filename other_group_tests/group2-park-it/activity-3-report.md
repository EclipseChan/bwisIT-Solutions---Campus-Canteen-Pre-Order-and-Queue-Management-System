**Status: Passed with issues** | **Date:** 2026-11-05 | **Test scope:** Temporary local copy of `Park it\park-it-database-final`, PHP runtime checks, and isolated disposable PostgreSQL database `parkit_test_20261105_1429`.

# Activity 3 — Installation

## Checks and outcomes

- A temporary copy was created; the source application was not edited. The project has no dependency manifest or separate package-install step. All 17 PHP files passed `php -l`.
- PHP 8.5.12 with `pdo_pgsql` and the XAMPP Apache 2.4.58 executable are available on this device.
- On the rerun, the PHP built-in server started successfully on loopback: HTTP status 200 and the login form rendered. The seed endpoint reported successful initialization, and Admin and Staff logins both reached the dashboard. Both authenticated users opened the vehicle module; the anonymous monitoring API correctly returned HTTP 401.
- The rerun used only the separate disposable database `parkit_test_20261105_1429`; it did not target `grp_parkitdb`.

## Issues and limitations

The Activity 3 rerun passed the local install/startup and login checks. **Setup caveat:** the disposable database already contained the recovery marker as a `parking_zone` row. The idempotent seed script therefore did not create its standard `Main Parking Lot`; the successful dashboard check used the existing test zone and is not a clean-database setup verification. No screenshot was captured. The web server was run locally using PHP's built-in development server rather than a persistent Apache/XAMPP deployment.

**Evidence:** [PHP and startup checks](evidence/activity-3/preflight.md), [Activities 3–5 rerun results](evidence/activity-3-5-rerun-results.md)  
**Environment:** Temporary local copy only; no production installation or database verification.
