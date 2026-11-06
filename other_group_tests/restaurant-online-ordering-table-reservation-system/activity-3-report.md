# Activity 3 — Installation

**Status: Passed with issues**  
**Run date:** 2026-11-05  
**Test scope:** Retest the supplied ZIP, check PHP syntax, provision an isolated disposable database, and start the application.

## Result

The application started and its database health check passed after loading the PostgreSQL PHP extensions for the test process. PHP 8.2.12 is installed at `C:\xampp2\php\php.exe`; `php` is still not resolvable in this PowerShell session because it has not inherited the updated PATH.

All **39 PHP files passed `php -l`**. The PHP package includes `php_pdo_pgsql.dll` and `php_pgsql.dll`, but both extensions are disabled in the active `C:\xampp2\php\php.ini`. Without overrides, `tools/test-connection.php` exited 1 with:

```text
FAIL  PHP extension pdo_pgsql is not enabled. Enable it in php.ini (docs/RUN_LOCALLY.md step 1).
```

For the retest only, the extensions were loaded with `-d` command-line options; no PHP configuration or application source file was changed. A fresh PostgreSQL 18.6 cluster listened only on `127.0.0.1` at a temporary port. The migrations, seeds, and role/grant scripts were applied there. The application connection check succeeded as `rors_app` and reached all eight expected tables.

The README server command was then run against that database. The home page returned HTTP 200, and `/health` returned:

```json
{"status":"ok","database":"grp_binarysisters_projectdb","account":"rors_app","tables":8}
```

The browser also rendered the home page. A screenshot was captured during this retest. This verifies local startup and the PHP-to-PostgreSQL path only; it is not production verification.

The documented `database/setup.ps1 -WithRoles` flow was not used: the supplied ZIP still lacks `database/roles/03_set_passwords.psql`. Instead, roles were created with the included SQL in the disposable cluster, which used local `trust` authentication. Password authentication was therefore not tested.

## Issues and next step

- Enable `pdo_pgsql` and `pgsql` in `C:\xampp2\php\php.ini`, then open a fresh terminal/VS Code session so the updated user PATH is inherited. Re-run the connection check without `-d` overrides.
- Add or correct the missing role-password setup step before relying on `database/setup.ps1 -WithRoles`; make setup fail explicitly if that step is unavailable.
- Customer/staff login and end-to-end ordering/reservation flows were not exercised in this retest.

## Evidence

- [PHP, database, and HTTP retest results](activity3-evidence/php-retest.txt)
- [Earlier PHP runtime check](activity3-evidence/php-runtime-check.txt) (superseded by this retest)
- [Install and role-password setup review](activity3-evidence/install-prerequisite-review.txt)
