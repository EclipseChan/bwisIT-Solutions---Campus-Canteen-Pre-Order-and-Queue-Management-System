# Activity 3 — CampusSafe installation report

**Status: Passed with issues**  
**Run date:** 2026-11-05  
**Device:** Windows; PHP 8.2.12; PostgreSQL 18.6  
**Source:** `grp07-campussafe-main.zip`, extracted to a disposable temporary copy.

| Check | Result |
|---|---|
| PHP syntax | PASS — 35 PHP files passed `php -l`. |
| PostgreSQL extension | PASS with setup — `pdo_pgsql` and `pgsql` DLLs loaded for the test process; PDO connected to the isolated database. |
| Database install and seed | PASS — the supplied schema and seed scripts loaded into a fresh disposable database; 9 tables and 16 original reports were present. |
| Application server | PASS — PHP's built-in server started on `127.0.0.1:8000`; home page returned HTTP 200. |
| Browser login and user flow | PASS — demo student login succeeded; submitting a clearly labeled test report created report #17 and its initial audit-history entry. |
| Screenshot | Captured during the live local browser session; the submitted report confirmation was visible. |

**Setup issue:** The device's PHP installation was under `C:\xampp2`, which is not among the paths checked by the supplied `start.bat`/`setup.bat`; PHP was also missing `pdo_pgsql` in its default module list. The app was launched successfully by specifying that PHP executable and enabling the existing PostgreSQL extension DLLs for this process only. No global PHP configuration was edited. This proves the application can run on this device with those prerequisites configured, but the bundled launcher did not work out of the box in this environment.

Only a disposable local database was used. The production/peer database was not contacted.
