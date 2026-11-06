Status: **Pass with limitation**
Date: 2026-11-05 (Asia/Manila, UTC+08:00)
Test scope: PHP syntax and HTTP startup checks, followed by a database-backed browser/API rerun against the user's disposable local PostgreSQL database. No production verification.

## Checks and outcomes

- PHP 8.5.12 was available with `PDO`, `pdo_pgsql`, and `pgsql` enabled. Syntax checks passed for `api.php` and `config.php`.
- The PHP built-in server started and served the HabalGo interface with HTTP 200. The browser displayed the dashboard and navigation without a database error.
- Read-only requests to `dashboard`, `options`, `customers`, `vehicles`, `bookings`, `payments`, and `ratings` all returned HTTP 200 with object/array response shapes as expected.
- After loading `sample data.sql`, `options` returned all 10 seeded drivers. The browser's Vehicles → Add vehicle form listed all 10 driver names in its assignment selector; the form was cancelled without saving a vehicle.
- PostgreSQL 18.6 accepted local connections; the PHP application successfully queried the disposable test database.
- The temporary PHP server was stopped after testing; PostgreSQL remained available.

## Issues and caveats

- Only the driver table contains sample records. Customer, vehicle, booking, payment, and rating workflows with populated records were not verified.
- Setup configuration mismatch: `.env.example` uses `DB_PASSWORD`, while `config.php` reads `DB_PASS`. This mismatch remains a setup risk; the retest connected using the local PostgreSQL passfile rather than `.env`.
- The PHP debugger/workspace instructions are not applicable to this PHP application.
- The supplied application source was not edited. No production behavior was verified.

## Evidence

- [HTTP and syntax checks](./activity-3/evidence/http-smoke-test.txt)
- [Browser check](./activity-3/evidence/browser-capture.txt)
