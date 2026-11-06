# Campus Canteen Pre-Order and Queue Management System

COMP 018 Database Administration, Activity 3: System Development and Repository Deployment.

Students pre-order food from campus canteen stalls, choose a pickup time and get a queue number. Stalls manage their menu and incoming orders. Administrators oversee stalls and sales. The system implements the design approved in Activity 2: seven PostgreSQL tables behind a Spring Boot REST API.

| | |
|---|---|
| Group | bwisIT Solutions (group number: TBD) |
| Members | Joshua Borreta, Martin Lawrence Bola, Joaquin Phillip Juatchon, Karl Raphael Marcos, Sancho Pacheco Jr, Euan Joseph Vera Cruz |
| Branch to test | `main` |
| Status | See the class tracker |

| Layer | Technology |
|---|---|
| Database | PostgreSQL 18 (also tested on 16) |
| Backend | Java 21, Spring Boot 3.4, Spring Data JPA, Spring Security with JWT |
| Client | React 18 with Vite, in `frontend/` (optional, see Step 5). The API can also be exercised with the smoke test and PowerShell or curl requests (see [docs/api-endpoints.md](docs/api-endpoints.md)) |

## For Testers - Start Here

Use this path to set up and verify the canteen application, then run Activities 4–6 against **other groups' Activity 3 projects** confirmed by the class tracker. This canteen project and `canteen_db` are bwisIT Solutions' own Activity 3 project and do not replace those other-group targets. `group-01`, `group-02`, and `group-03` are provisional folder names, not confirmed project inventory.

| I want to... | Go to |
|---|---|
| Set up and run the canteen app | [Quick Setup](#quick-setup), then [Run the Application](#run-the-application) |
| Verify Activity 4 access control | [Test Activity 4 - Access Control](#test-activity-4---access-control) |
| Verify Activity 5 maintenance and monitoring | [Test Activity 5 - Maintenance and Monitoring](#test-activity-5---maintenance-and-monitoring) |
| Verify Activity 6 backup and recovery | [Test Activity 6 - Backup and Recovery](#test-activity-6---backup-and-recovery) |
| Know what a result should look like | [Expected Results](#expected-results) |
| Understand why something is blocked | [Known Blockers](#known-blockers) |

No live database output is included in this README. Treat the results below as expected outcomes, not as claims that checks have passed.

## What You Need

| Requirement | Check command/action | Expected result |
|---|---|---|
| Windows PowerShell 5.1+ or PowerShell 7+ | `powershell -NoProfile -Command '$PSVersionTable.PSVersion'` or `pwsh -NoProfile -Command '$PSVersionTable.PSVersion'` | Version is at least 5.1 (Windows PowerShell) or PowerShell 7+. If unavailable, install an approved PowerShell version before running the verifier scripts. |
| PostgreSQL 16+ and `psql` on PATH | `psql --version` | PostgreSQL client version 16 or newer is reported. If not found, add PostgreSQL's `bin` folder to PATH and open a new terminal. |
| JDK 21 | `java -version` | Java 21 is reported. If another JDK is selected, follow the JDK selection steps under [Quick Setup](#quick-setup). |
| Maven 3.9+ | `mvn -v` | Maven 3.9 or newer and Java 21 are reported. If unavailable, install Maven and add its `bin` folder to PATH. |
| Node.js 18+ (web client only) | `node -v` | Node.js 18 or newer is reported. If unavailable, install Node.js LTS before starting the optional web client. |
| Git | `git --version` | A Git version is reported. If not found, install Git and reopen the terminal. |
| Class tracker / other groups' project inventory | Confirm tracker access with the course team and review its project list. | The authoritative list of other groups' Activity 3 projects and the tracker location are known; otherwise record this as BLOCKED and do not guess. |
| Local PostgreSQL credentials | Configure the approved local environment / `.pgpass` without recording values in Git. | An authorized local connection mechanism is available; no password is printed or committed. |

The first Maven build downloads dependencies and needs internet access. JDK 21 is required: `pom.xml` sets `java.version` to 21, and newer JDKs (for example 25) have not been tested with this project. Do not edit `java.version` to match another JDK.

## Quick Setup

Run these steps from the repository root. Replace the repository URL/folder with the authorized values for your checkout. Do not put credentials in commands, the README, or evidence.

| Step | Exact command/action | Expected result | If it fails |
|---|---|---|---|
| 1. Clone | `git clone <repository-url>`<br>`cd <repository-folder>` | The repository is cloned and the shell is at its root. | Check the URL/access and retry in a new empty destination; do not make changes to another group's repository. |
| 2. Create local settings (Windows) | `Copy-Item .env.example .env` | A local `.env` copy exists and is ignored by Git. Fill its values locally using a secure editor; never commit `.env`. | Confirm the current directory is the repository root and `.env.example` exists. Do not paste values into chat or evidence. |
| 2. Create local settings (Linux/macOS) | `cp .env.example .env` | A local `.env` copy exists and is ignored by Git. Fill its values locally using a secure editor; never commit `.env`. | Confirm the current directory is the repository root and `.env.example` exists. Do not paste values into chat or evidence. |
| 3. Create database roles and memberships (Windows) | `psql -U postgres -d postgres -v ON_ERROR_STOP=1 -f .\db-access-control\01-create-roles.sql`<br>`psql -U postgres -d postgres -v ON_ERROR_STOP=1 -f .\db-access-control\02-role-memberships.sql` | Canteen roles and memberships are created; each role password is requested by hidden prompt. Enter the same local values configured for the roles. | Resolve the `psql`/authentication error before setup. Type the superuser password by hand: pasting into the hidden prompt can capture the wrong text and produce `password authentication failed for user "postgres"`. |
| 3. Create database roles and memberships (Linux/macOS) | `psql -h "$DB_HOST" -p "$DB_PORT" -U postgres -d postgres -v ON_ERROR_STOP=1 -f db-access-control/01-create-roles.sql`<br>`psql -h "$DB_HOST" -p "$DB_PORT" -U postgres -d postgres -v ON_ERROR_STOP=1 -f db-access-control/02-role-memberships.sql` | Canteen roles and memberships are created; each role password is requested by hidden prompt. Enter the same local values configured for the roles. | Confirm the approved host/port environment is set and that the PostgreSQL superuser can connect. Never place passwords in the command line. |
| 4. Run database setup (Windows) | `powershell -ExecutionPolicy Bypass -File .\database\setup.ps1` | The script creates the database owned by `canteen_admin`, applies migrations and sample data as that account, then applies access-control scripts 03–06. | Review the printed error, local settings, PostgreSQL service, and permissions. Do not repeatedly run until the cause is understood. |
| 4. Run database setup (Linux/macOS) | `./database/setup.sh` | The script creates the database owned by `canteen_admin`, applies migrations and sample data as that account, then applies access-control scripts 03–06. | Review the printed error, local settings, PostgreSQL service, and permissions. Do not repeatedly run until the cause is understood. |
| 5. Verify the database tables | `psql -U canteen_admin -d canteen_db -c "\dt"` | Seven tables are listed: `customer_order`, `menu_item`, `notification`, `order_item`, `queue_entry`, `student`, and `vendor`. | Check that setup completed and that `DB_NAME` is `canteen_db`, or use the locally configured database name. |
| 5. Verify the role inventory | `psql -U postgres -d postgres -c "\du"` | The expected canteen login and group roles are visible; review memberships against the Activity 4 plan. | Check that role creation and membership scripts completed under an authorized superuser. |
| 6. Start the API (Windows) | `powershell -ExecutionPolicy Bypass -File .\scripts\run-backend.ps1` | Console reports `Started CanteenApplication`; `GET http://localhost:8080/api/vendors` lists three active stalls. | Check JDK/Maven selection, local settings, database availability, and port 8080. |
| 6. Start the API (Linux/macOS) | `./scripts/run-backend.sh` | Console reports `Started CanteenApplication`; `GET http://localhost:8080/api/vendors` lists three active stalls. | Check JDK/Maven selection, local settings, database availability, and port 8080. |
| 7. Start optional web client | `cd frontend`<br>`npm install`<br>`npm run dev` | Vite starts on port 5173. Open `http://localhost:5173` and log in with a sample account. | Check Node.js 18+, API availability, and port 5173. If Windows blocks `npm`, use `npm.cmd`; see [frontend/README.md](frontend/README.md). |

The setup script asks for the PostgreSQL superuser password, creates the database owned by `canteen_admin`, runs migrations and sample data as that account, then applies access-control scripts 03–06. It does not run the app as the owner. If `psql` is not on PATH on Windows, add `-Psql "C:\Program Files\PostgreSQL\18\bin\psql.exe"` (use your own install path; keep the quotes if it contains spaces). Expected result: the setup script completes and the seven tables and planned roles are present. If setup fails, use the troubleshooting guidance rather than claiming success.

If JDK 21 is not the default, select it in the terminal you will run the API from (Windows PowerShell). Use your actual folder names; a wrong folder fails silently and the older JDK is used instead. This lasts only for that window, so repeat it in every new terminal:

```powershell
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-21.0.13.9-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
java -version
mvn -v
```

Expected result: both version checks report 21 for Java. If they do not, correct `JAVA_HOME`/PATH in that terminal. If Maven is not installed and winget cannot find it, download the Maven binary archive from maven.apache.org, extract it, and add its `bin` folder to `$env:Path` the same way. Expected result: `mvn -v` reports Maven 3.9 or newer and Java 21; if not, fix PATH/JDK selection before starting the API.

Before running `db-access-control/07-security-restrictions.sql`, review every database on the PostgreSQL cluster. It revokes `PUBLIC CONNECT` cluster-wide and can affect other applications; see [docs/database-roles.md](docs/database-roles.md). Expected result: an authorized reviewer confirms the impact is acceptable before the script is applied. If the impact is unknown, do not run it.

## Run the Application

| Component | Command | Expected result | Where |
|---|---|---|---|
| API (Windows) | `powershell -ExecutionPolicy Bypass -File .\scripts\run-backend.ps1` | `Started CanteenApplication`; `GET /api/vendors` returns three active stalls. If not, use [Troubleshooting](#troubleshooting). | `http://localhost:8080` |
| API (Linux/macOS) | `./scripts/run-backend.sh` | `Started CanteenApplication`; `GET /api/vendors` returns three active stalls. If not, use [Troubleshooting](#troubleshooting). | `http://localhost:8080` |
| Web client | `cd frontend`<br>`npm install`<br>`npm run dev` | Vite starts on port 5173. If not, check Node and port availability. | `http://localhost:5173` |
| Smoke test | `powershell -ExecutionPolicy Bypass -File .\test-flow.ps1` | With the API running, the script finishes with `All steps ran.` in green. This is an expected result, not a result claimed by this README. | Repository root |

The web client needs Node.js 18 or newer and the API from Step 4 running. Run `npm install` only once unless dependencies change. The port is fixed because the API only accepts browser requests from `http://localhost:5173` and `http://localhost:3000`. On Windows PowerShell, if `npm` is blocked with “running scripts is disabled”, use `npm.cmd` instead (for example `npm.cmd install`) or run `Set-ExecutionPolicy -Scope Process Bypass` first. Details: [frontend/README.md](frontend/README.md). Expected result: the client opens on port 5173 and can reach the API; if it cannot, check the API and browser origin.

The automatic smoke test registers a new vendor and student, adds menu items, places two orders, moves one through preparing, ready and completed, cancels the other, then prints notifications and a sales report. Run it before 23:59 Philippine time, because its pickup time is 23:59. Expected result: `All steps ran.`; if any step fails or the time window has passed, record the actual output and do not claim a pass.

## Test Activity 4 - Access Control

Activity 4 checks roles, memberships, privileges, and least privilege. This group's `db-access-control/` is the canteen reference implementation; per-project work for other groups belongs in `db-access-control/<group>/`. Confirm other-group projects from the class tracker. Do not run canteen-specific SQL against another group's schema unless it has been adapted and reviewed.

For verifier scripts, first copy `config/projects.example.json` to the ignored `config/projects.local.json` and fill it with confirmed, non-secret project facts. `group-01` below is a placeholder until the class inventory confirms the project. Preview without connecting using `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/run-activity4.ps1 -Project group-01 -DryRun`; expected result: SQL/test previews and no database actions. Missing project facts should be reported as BLOCKED.

| Step | Command | Expected result |
|---|---|---|
| Run Activity 4 checks | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/run-activity4.ps1 -Project group-01 -Execute` | For a fully configured, authorized target, `FAIL: 0`, `BLOCKED: 0`, exit code 0. Otherwise inspect each FAIL/BLOCKED result; no pass is claimed here. |
| Check roles | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity4/01-check-roles.ps1 -Project group-01 -Execute` | Required roles exist and no unexpected SUPERUSER/CREATEDB/CREATEROLE attributes are present. |
| Check memberships | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity4/02-check-memberships.ps1 -Project group-01 -Execute` | Required memberships are present; no unauthorized configured memberships are found. |
| Check database privileges | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity4/03-check-database-privileges.ps1 -Project group-01 -Execute` | CONNECT is allowed only where intended; CREATE is denied for runtime and read-only accounts. |
| Check schema/table privileges | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity4/04-check-schema-table-privileges.ps1 -Project group-01 -Execute` | Runtime privileges match the plan; read-only access has only the required SELECT permissions. |
| Check sequence privileges | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity4/05-check-sequence-privileges.ps1 -Project group-01 -Execute` | Runtime sequence access matches the plan; read-only accounts cannot modify sequences. |
| Check default privileges | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity4/06-check-default-privileges.ps1 -Project group-01 -Execute` | No unintended default grants are found; unexpected entries are investigated. |
| Check PUBLIC restrictions | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity4/07-check-public-restrictions.ps1 -Project group-01 -Execute` | PUBLIC is restricted as configured and has no unintended access. |
| Run allowed/denied tests | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity4/08-run-allowed-denied-tests.ps1 -Project group-01 -Execute` | Allowed operations succeed; denied operations are denied for the expected reason. |

Each manual check has an observable outcome and a place to record evidence:

| Manual check | Expected result | Record in |
|---|---|---|
| `db-access-control/<group>/` contains the per-project plan, SQL, and test evidence. | Project-specific files exist and adaptations are explained. | `db-access-control/<group>/` and Activity 4 evidence |
| Commits are meaningful. | Change history describes the actual work without claiming unperformed tasks. | Git history |
| Activity 4 Log tracker tab is updated. | Target project, actual result, and blocker/status are recorded. | Class tracker |
| PDF has required Activity 4 sections. | Completed sections are consistent with actual evidence. | Course PDF/progress tracker |
| Feedback was sent to each owning group. | Feedback date and reference/recipient are recorded, or the absence of an issue is documented. | Feedback record |
| AI usage is declared and validated. | Actual tools/tasks and human validation are disclosed. | AI usage declaration |
| No secrets appear in files or screenshots. | Secret scan finds no secrets; findings and remediation are documented without values. | Secret-scan checklist |

## Test Activity 5 - Maintenance and Monitoring

Activity 5 must target another group's Activity 3 database, not only this canteen database. Some checks may be blocked by account permissions or unavailable server logs. Use the same non-secret local project configuration described for Activity 4. Preview with `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/run-activity5.ps1 -Project group-01 -DryRun`; expected result: previews without connecting or running maintenance.

| Step | Command | Expected result |
|---|---|---|
| Run Activity 5 checks | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/run-activity5.ps1 -Project group-01 -Execute` | With required inputs/permissions, `FAIL: 0`; `BLOCKED` only for documented permission limits or missing approved inputs. |
| Health check | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity5/01-health-check.ps1 -Project group-01 -Execute` | Version, database name, size, table/index/sequence counts, and activity rows are returned. |
| Session activity | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity5/02-activity-check.ps1 -Project group-01 -Execute` | Active, idle, and idle-in-transaction sessions are summarized. |
| Role check | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity5/03-role-check.ps1 -Project group-01 -Execute` | Activity 4 roles are still present and match configuration. |
| Log check | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity5/04-log-check.ps1 -Project group-01 -Execute` | Real log findings are summarized, or BLOCKED includes the precise permission/logging limitation. |
| Maintenance | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity5/05-maintenance-check.ps1 -Project group-01 -Table "schema.table" -Execute` | ANALYZE and standalone VACUUM (VERBOSE, ANALYZE) complete; before/after statistics are captured. |
| Query plan | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity5/06-query-plan.ps1 -Project group-01 -SqlFile "path\to\reviewed-select.sql" -Execute` | EXPLAIN and EXPLAIN (ANALYZE, BUFFERS) output is captured. EXPLAIN ANALYZE executes the SELECT; review it first. |

Manual checks:

| Manual check | Expected result | Record in |
|---|---|---|
| Review log evidence or access limitation. | Real log findings are present, or the permission/logging limitation is explicit. | Log-review record |
| Confirm there are no invented incidents or timings. | Every finding/timing is traceable to real output. | Activity 5 report |
| Confirm maintenance used the correct account. | Authorized maintenance account was used, not the application runtime account. | Maintenance evidence |
| Confirm no `VACUUM FULL` was run without approval. | No `VACUUM FULL`, unless specifically approved and recorded. | Maintenance evidence |
| Confirm report, tracker tab, PDF sections, feedback, and AI declaration exist. | These records reflect actual work and limitations. | Activity 5 report, tracker, PDF, feedback record |

## Test Activity 6 - Backup and Recovery

Restore and recovery tests must use a disposable test database and must never touch an original database. Data-bearing dumps must be protected outside the repository. Preview with `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/run-activity6.ps1 -Project group-01 -DryRun`; expected result: command previews only. Missing project inputs are BLOCKED; no live backup or restore is claimed here.

| Step | Command | Expected result |
|---|---|---|
| Run Activity 6 checks | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/run-activity6.ps1 -Project group-01 -Execute` | `FAIL: 0`; BLOCKED only for documented missing setup/CREATEDB access, missing required project inputs, or other explicit authorization/permission limits. |
| Check backup plan | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity6/01-check-backup-plan.ps1 -Project group-01` | All required project-specific plan sections are present and placeholders are resolved. |
| Create backup | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity6/02-create-backup.ps1 -Project group-01 -BackupDir "C:\protected\db-backups" -Execute` | Custom-format dump is created outside Git; metadata and any errors are recorded. |
| Checksum | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity6/03-checksum.ps1 -Project group-01 -BackupFile "C:\protected\db-backups\verified.dump" -Execute` | SHA-256, filename, size, and timestamp are recorded in `checksums.txt`. |
| Archive list | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity6/04-archive-list.ps1 -Project group-01 -BackupFile "C:\protected\db-backups\verified.dump" -Execute` | `pg_restore --list` output is saved and includes the archive's relevant objects and ACL entries. |
| Restore test | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity6/05-restore-test.ps1 -Project group-01 -BackupFile "C:\protected\db-backups\verified.dump" -RestoreDbName "project_a6_restore_YYYYMMDD" -Execute -Confirm` | Restore completes into a new, distinct test database; warnings/errors and its name are recorded. |
| Verify restore | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity6/06-verify-restore.ps1 -Project group-01 -RestoreDbName "project_a6_restore_YYYYMMDD" -Execute -AllowedSqlFile "path\to\allowed.sql" -DeniedSqlFile "path\to\denied.sql" -SelectSqlFile "path\to\reviewed-select.sql"` | Tables, row counts, constraints, sequences, roles/memberships, allowed/denied operations, representative SELECT, and application connection are verified or documented as blocked/different. |
| Recovery simulation | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity6/07-recovery-simulation.ps1 -Project group-01 -BackupFile "C:\protected\db-backups\verified.dump" -RestoreDbName "project_a6_restore_YYYYMMDD" -RecoveryDbName "project_a6_recovery_YYYYMMDD" -RPO "owner-approved RPO" -Execute -Confirm` | A disposable marker is recovered in a fresh recovery database and comparison matches; RPO implications are documented. Only the restored test DB is modified. |
| No dumps committed | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity6/08-check-no-dumps-committed.ps1 -Project group-01 -Execute` | No `*.dump`, `*.backup`, `*.sql.gz`, or backup-directory paths are tracked. |

The example path and database names above are placeholders. Replace them only with confirmed values. The configured user must not be the application runtime account for backups. If CREATEDB access is unavailable, the script must report BLOCKED with an instructor/setup-account request; do not grant broad privileges just to pass.

Manual checks:

| Manual check | Expected result | Record in |
|---|---|---|
| Backup plan covers method, storage, access, verification, schedule, retention, RPO, RTO, and role recreation. | All sections are project-specific, reviewed, and approved. | `db-backup-recovery/<group>/backup-plan.md` |
| Backup is stored outside the repository and not shared publicly. | The protected location is outside Git and any submission ZIP. | Backup plan and non-secret metadata |
| Restore is verified, not merely completed. | Objects, data, constraints, sequences, roles/privileges, and representative behavior are checked or differences documented. | Restore verification and report |
| Activity 6 report, tracker tab, PDF sections, feedback, and AI declaration exist. | Records reflect actual output, warnings, and limitations. | Activity 6 report, tracker, PDF, feedback record |
| Original databases were not modified. | Source database identity is excluded as a restore/recovery target; evidence names only disposable test targets. | Restore/recovery records |

## Expected Results

The following table covers the automated and manual Activity 4–6 checks. Every row links to [EXPECTED_RESULTS.md](docs/activity-4-5-6/EXPECTED_RESULTS.md) for fuller interpretation. These are expected results only; the README contains no current live output and does not claim that any check passed.

| Activity | Check | Command or action | Expected result | Failure means | Evidence |
|---|---|---|---|---|---|
| 4 | Role attributes | `activity4/01-check-roles.ps1` against an authorized target | Planned roles exist with required safe attributes. | Role inventory or attribute differs from the approved plan. | Timestamped Activity 4 output; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 4 | Memberships | `activity4/02-check-memberships.ps1` | Required memberships exist; no configured unplanned membership. | Role inheritance may violate least privilege. | Timestamped output; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 4 | Database privileges | `activity4/03-check-database-privileges.ps1` | CONNECT/CREATE and unrelated-database access match the plan. | Unexpected access or missing intended access. | Timestamped output; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 4 | Schema/table privileges | `activity4/04-check-schema-table-privileges.ps1` | Runtime and read-only grants match the planned schema/table policy. | Missing or excessive access. | Timestamped output; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 4 | Sequence privileges | `activity4/05-check-sequence-privileges.ps1` | Sequence permissions match the plan. | Inserts may fail or read-only access may be excessive. | Timestamped output; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 4 | Default privileges | `activity4/06-check-default-privileges.ps1` | Default ACLs match reviewed expectations. | Future objects may receive unintended grants. | Timestamped output and review; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 4 | PUBLIC restrictions | `activity4/07-check-public-restrictions.ps1` | No unintended PUBLIC access. | Database/schema objects may be exposed beyond the plan. | Timestamped output; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 4 | Allowed/denied tests | `activity4/08-run-allowed-denied-tests.ps1` | Allowed operations succeed; denied operations fail for intended privilege reasons. | Policy is not enforced as expected or the adapted tests are invalid. | SQL files and timestamped output; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 4 | Access plan and project SQL | Human review of `db-access-control/<group>/` | Dated plan, reviewed SQL, and project-specific adaptations exist. | Role changes lack a justified least-privilege design. | Project access-control plan; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 4 | Commits, tracker, PDF, feedback, AI | Human review of external/repository records | Required records and actual owner feedback exist. | Activity evidence/documentation is incomplete. | Git history, tracker, PDF, feedback, AI declaration; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 4 | Secret scan | Scan files and screenshots before submission | No secret values or `.env` contents are included. | Submission may expose credentials or tokens. | Secret-scan checklist; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 5 | Health check | `activity5/01-health-check.ps1` | Version, database, size, object counts, and activity output are captured. | Target health/data or access is unknown. | Timestamped Activity 5 output; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 5 | Session activity | `activity5/02-activity-check.ps1` | Active, idle, and idle-in-transaction sessions are summarized. | Session state/access cannot be verified. | Timestamped output; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 5 | Role check | `activity5/03-role-check.ps1` | Activity 4 roles remain present. | Roles changed or target roles are unknown. | Timestamped output; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 5 | Log review | `activity5/04-log-check.ps1` | Real findings are summarized without sensitive lines, or access is BLOCKED. | Log review is incomplete or findings are unsupported. | Redacted log review/limitation; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 5 | Maintenance | `activity5/05-maintenance-check.ps1` with authorized maintenance account | ANALYZE and standalone VACUUM complete; before/after stats are captured. | Maintenance did not complete or used an inappropriate account/target. | Timestamped output; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 5 | Query plan | `activity5/06-query-plan.ps1` on a reviewed SELECT | EXPLAIN and authorized EXPLAIN ANALYZE/BUFFERS output are available. | Query/permission is invalid or unsafe; analyze may have executed the SELECT. | Reviewed SQL file and output; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 5 | Report, tracker, PDF, feedback, AI | Human review | Report and external records reflect only real findings/limitations. | Activity record is incomplete or unsupported. | Report, tracker, PDF, feedback, AI declaration; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 6 | Backup plan | `activity6/01-check-backup-plan.ps1` and owner review | Project-specific plan has required sections and no unresolved placeholders. | Backup process is not ready or is unapproved. | `backup-plan.md`; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 6 | Custom-format backup | `activity6/02-create-backup.ps1 -Execute` | Protected `pg_dump -Fc` outside repository plus metadata/errors. | No valid protected dump or incomplete record. | Non-secret backup metadata; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 6 | Checksum | `activity6/03-checksum.ps1 -Execute` | Filename, size, SHA-256, and timestamp are recorded. | Backup integrity metadata is missing or not reproducible. | `checksums.txt`; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 6 | Archive listing | `activity6/04-archive-list.ps1 -Execute` | Non-empty `pg_restore --list` output has been saved/reviewed. | Archive cannot be listed or expected entries are missing. | `archive-listing.txt`; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 6 | Restore test | `activity6/05-restore-test.ps1 -Execute -Confirm` | Restore completes in a fresh distinct test database; output/warnings/errors are recorded. | Restore is incomplete or target safety/permissions are not established. | Restore evidence; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 6 | Restore verification | `activity6/06-verify-restore.ps1 -Execute` | Objects, row counts, keys, constraints, sequences, roles, permissions, SELECT, and application connection are checked or blocked differences recorded. | Restored state is incomplete or unverified. | Verification output/report; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 6 | Recovery simulation | `activity6/07-recovery-simulation.ps1 -Execute -Confirm` | Disposable marker is recovered in a fresh DB and compared; RPO impact is documented. | Recovery is not demonstrated or comparison differs. | Recovery record; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 6 | Tracked backup scan | `activity6/08-check-no-dumps-committed.ps1 -Execute` | No data-bearing dump or backup-directory paths are tracked. | A backup may be included in Git/submission. | Timestamped output; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 6 | Backup/report/tracker/PDF/feedback/AI | Human review | Protected storage and required report/external records are reviewed and accurate. | Deliverables are missing or make unsupported claims. | Backup plan, report, tracker, PDF, feedback, AI declaration; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |
| 6 | Source database protection | Human review of target names and actual output | Only distinct disposable test databases were modified. | Original data may have been modified. Stop and notify the owner. | Restore/recovery records; [details](docs/activity-4-5-6/EXPECTED_RESULTS.md) |

## Where Evidence Goes

- Activity 4: `evidence/activity-4/<project>/<yyyy-mm-dd>/`
- Activity 5: `evidence/activity-5/<project>/<yyyy-mm-dd>/`
- Activity 6: `evidence/activity-6/<project>/<yyyy-mm-dd>/`
- Database dumps: a protected local path outside Git and outside the submission ZIP.

Text output is preferred; use screenshots only when necessary. Redact secrets before saving or screenshotting. Each evidence record should identify the project, account, role, database, date/time, command/action, and result. If the script does not capture an item, record it separately from actual output; do not infer it. Full guidance: [EVIDENCE_GUIDE.md](docs/activity-4-5-6/EVIDENCE_GUIDE.md).

## Troubleshooting

| Problem | Likely cause | Fix |
|---|---|---|
| `psql` not recognized / not found | PostgreSQL `bin` is not on PATH. | Add the PostgreSQL `bin` folder to PATH and open a new terminal. |
| `password authentication failed for user "postgres"` | Superuser password entry failed or wrong local password. | Type the password by hand at the hidden prompt and verify with the authorized owner; do not place it in a command. |
| `password authentication failed for user "canteen_admin"` | `DB_ADMIN_PASSWORD` does not match the password entered for the role. | Correct the local `.env` value or role password via the authorized procedure; see Step 2. |
| `password authentication failed` for a test target | `.env`/`.pgpass` does not match the authorized role password. | Re-enter/update the local credential securely; if denied, record BLOCKED and request owner/setup access. |
| `Could not resolve placeholder 'DB_PASSWORD'` | API was started without loading `.env`. | Start the API with `scripts\run-backend.ps1` so `.env` is loaded. |
| `Schema-validation: missing column` | Database migrations are incomplete or stale. | Run the setup script again; it is safe to repeat after confirming the target database. |
| Requests fail with connection refused | API is not running on port 8080. | Start the API and verify the startup message before testing. |
| Sample accounts cannot log in | Sample seed data did not load. | Run the setup script again and verify the seed result. |
| `release version 25 not supported` | `java.version` in `pom.xml` was changed to 25. | Set it back to 21; do not change it to match another JDK. |
| `java -version` still shows another JDK | JDK 21 folder name is wrong or was set in a different window. | Select the correct folder in this terminal; see [Quick Setup](#quick-setup). |
| `npm` is blocked or not recognized | PowerShell policy or Node PATH issue. | Use `npm.cmd`, or `Set-ExecutionPolicy -Scope Process Bypass`; open a new window after installing Node. |
| Web client shows “Failed to fetch” | API is not running on port 8080, or client is not on port 5173. | Start the API and use the supported client port/origin. |
| `Port 5173 is already in use` | Another frontend process occupies the fixed port. | Close the other frontend terminal; the port must stay 5173. |
| `permission denied for schema` | Required schema `USAGE` grant is missing. | Review/re-apply the approved schema grants; do not grant broader access than planned. |
| `permission denied for sequence` | Required sequence `USAGE`/`SELECT` grant is missing. | Review/re-apply approved sequence grants. |
| `cannot create database` | Configured account lacks `CREATEDB`. | Record BLOCKED and request the approved instructor/setup account. |
| `pg_restore: warning` | Ownership or role differences may exist. | Record the warning and verify objects/data anyway; do not hide or fabricate a clean restore. |
| Log check returns `BLOCKED` | Logging is unavailable or the account cannot read logs. | Record the precise limitation; do not invent log findings. |
| Script stops at a password prompt | No non-interactive approved credential source is configured. | Use the approved `PGPASSWORD` environment or `.pgpass`; never a script argument or evidence. |
| Verifier reports missing configuration | Project inventory/config entry is incomplete. | Populate `config/projects.local.json` from authoritative non-secret facts; do not guess. |

The full application troubleshooting list is in [docs/troubleshooting.md](docs/troubleshooting.md). More Activity 4–6 checks and expected outcomes are in [EXPECTED_RESULTS.md](docs/activity-4-5-6/EXPECTED_RESULTS.md).

## Known Blockers

These are current scaffold blockers, not completed tasks. The provisional group directories do not establish which groups or projects are in scope.

| Blocker | Owner | Next action |
|---|---|---|
| Other groups' project inventory, tracker URL, and confirmed project list are missing. | Course team / instructor | Supply tracker access and confirmed inventory; replace provisional names only from that source. |
| Per-project database names/versions, role mappings, reachability, and owner contacts are unknown. | Target project owners / course team | Confirm facts from each project's documentation and authorized environment. |
| CREATEDB/setup and database-log access are not confirmed. | Instructor / database owner | Approve least-privilege setup and logging access, or record the exact BLOCKED reason. |
| Credential rotation and final tracker/PDF status are pending in the existing blocker record. | Project owner / submitting team | Complete [credential rotation](docs/activity-4-5-6/CREDENTIAL_ROTATION_CHECKLIST.md) and verify tracker/PDF without recording secret values. |

See [BLOCKERS.md](docs/activity-4-5-6/BLOCKERS.md) for the current blocker index and [docs/activity-5-6/BLOCKERS.md](docs/activity-5-6/BLOCKERS.md) for the existing detailed record.

## AI Usage

The original project declaration records Claude by Anthropic as having helped guide development and says use must be declared in the PDF progress tracker. Copilot SDK in VS Code was used for the current repository documentation and verification-script scaffold; its suggestions were checked against the supplied requirements, PowerShell syntax parsing, safe dry-run behavior, and internal-link targets. No database or backup/restore operation is claimed. This does not claim those checks are database evidence or that all group members' AI use is known. The submitting team must confirm any other tools actually used and complete the declaration: [AI_USAGE_DECLARATION.md](docs/activity-4-5-6/AI_USAGE_DECLARATION.md).

## What is in this repository

| Path | Contents |
|---|---|
| `src/main/` | Spring Boot API (Maven project, `pom.xml` at the root). |
| `database/` | Init script, migrations, seed data, setup scripts, reset script. |
| `db-access-control/` | Canteen database role, membership, privilege, and security-restriction scripts; per-other-project work uses a project subfolder. |
| `db-maintenance/` | Activity 5 reusable maintenance and monitoring templates for provisional project folders. |
| `db-backup-recovery/` | Activity 6 reusable backup/recovery templates; do not commit data-bearing dumps. |
| `scripts/` | Backend run scripts (load `.env`, start API) and Activity 4–6 verification scripts. |
| `config/` | Example non-secret project configuration; local `projects.local.json` is ignored. |
| `evidence/` | Activity 4–6 evidence directory placeholders; real output belongs under activity/project/date folders. |
| `docs/` | Database, roles, endpoints, troubleshooting, requirements matrix, and activity guides. |
| `frontend/` | React web client for students, vendors, administrators (optional). |
| `test-flow.ps1` | End-to-end smoke test (requires the API running). |
| `.env.example` | Settings template (placeholders only); copy to a local ignored `.env`. |
| `add_auth_columns.sql` | Same statements as `database/migrations/002_auth_columns.sql`. |

The database, roles, API, and client technology versions are listed in the [technology table](#campus-canteen-pre-order-and-queue-management-system).

## Prerequisites

| Tool | Needed | Check with |
|---|---|---|
| Git | Any recent version | `git --version` |
| JDK | 21 | `java -version` |
| Maven | 3.9 or newer | `mvn -v` |
| PostgreSQL | 16 or newer, with `psql` on PATH | `psql --version` |
| Node.js | 18 or newer (LTS), only for the web client | `node -v` |

Expected results: Git reports an installed version, Java reports 21, Maven reports 3.9+ and Java 21, PostgreSQL reports client 16+, and optional Node.js reports 18+. If a check fails, see [What You Need](#what-you-need) or [Troubleshooting](#troubleshooting).

You also need the password of the PostgreSQL superuser (`postgres`), chosen when PostgreSQL was installed. The first run downloads Maven dependencies, so you need an internet connection. Keep credentials local; never commit `.env`.

Use JDK 21. `pom.xml` sets `java.version` to 21, and newer JDKs (for example 25) have not been tested with this project. If a newer JDK is your default, install JDK 21 next to it and select it as shown in [Quick Setup](#quick-setup). Do not edit `java.version` to match another JDK.

## Setup

Work from the repository root. The numbered steps below retain the original setup instructions; use [Quick Setup](#quick-setup) for a compact checklist with failure actions.

### Step 1: Clone

```text
git clone <repository-url>
cd <repository-folder>
```

Expected result: the repository is cloned and the working directory is its root. If cloning fails, verify the authorized URL and repository access.

### Step 2: Create your settings file

- Windows PowerShell: `Copy-Item .env.example .env`
- Linux or macOS: `cp .env.example .env`

Expected result: a local `.env` file is created from `.env.example`. Edit it locally and set:

- `DB_ADMIN_PASSWORD`: maintenance and migration password for `canteen_admin`.
- `DB_PASSWORD`: runtime password for `canteen_app`.
- `DB_READONLY_PASSWORD`: reporting password for `canteen_readonly`.
- `JWT_SECRET`: at least 32 random characters.

`.env` is ignored by Git and must never be committed. Do not copy its contents into the tracker, screenshots, or evidence. If the file is absent, confirm the repository root and `.env.example` first.

### Step 3: Create roles, database, tables and sample data

Create the PostgreSQL roles as a superuser. The psql script asks for each role password with a hidden prompt; enter the same values configured locally.

- Windows PowerShell:

  ```text
  psql -U postgres -d postgres -v ON_ERROR_STOP=1 -f .\db-access-control\01-create-roles.sql
  psql -U postgres -d postgres -v ON_ERROR_STOP=1 -f .\db-access-control\02-role-memberships.sql
  ```

- Linux/macOS:

  ```text
  psql -h "$DB_HOST" -p "$DB_PORT" -U postgres -d postgres -v ON_ERROR_STOP=1 -f db-access-control/01-create-roles.sql
  psql -h "$DB_HOST" -p "$DB_PORT" -U postgres -d postgres -v ON_ERROR_STOP=1 -f db-access-control/02-role-memberships.sql
  ```

Expected result: roles and their memberships are created without SQL errors. If authentication fails, type the superuser password by hand: pasting into the hidden prompt can capture the wrong text and give `password authentication failed for user "postgres"`. Never add a password to the command.

- Windows: `powershell -ExecutionPolicy Bypass -File .\database\setup.ps1`
- Linux or macOS: `./database/setup.sh`

Expected result: the setup script asks for the PostgreSQL superuser password, creates the database owned by `canteen_admin`, runs migrations and sample data as that account, then applies access-control scripts 03–06. It does not run the app as the owner. If `psql` is not on PATH on Windows, add `-Psql "C:\Program Files\PostgreSQL\18\bin\psql.exe"` (use your own install path; keep the quotes if it contains spaces). If setup fails, fix the reported cause before continuing.

Review every database on the PostgreSQL cluster before running `db-access-control/07-security-restrictions.sql`. It revokes `PUBLIC CONNECT` cluster-wide and can affect other applications; see [docs/database-roles.md](docs/database-roles.md). Expected result: an authorized reviewer confirms this cluster-wide change is appropriate. If the impact is not known, do not run the script.

Check the tables:

```text
psql -U canteen_admin -d canteen_db -c "\dt"
```

Expected result: seven tables are listed: `customer_order`, `menu_item`, `notification`, `order_item`, `queue_entry`, `student`, `vendor`. If not, setup or the database name may be incorrect.

### Step 4: Start the API (port 8080)

If JDK 21 is not your default, select it in the terminal you will run the API from (Windows PowerShell). Use your actual folder names; a wrong folder fails silently and the older JDK is used instead. This lasts only for that window, so repeat it in every new terminal:

```powershell
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-21.0.13.9-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
java -version
mvn -v
```

Expected result: both commands report 21 for Java. If not, correct the folder and PATH in this terminal. If Maven is not installed and winget cannot find it, download the Maven binary archive from maven.apache.org, extract it, and add its `bin` folder to `$env:Path` the same way. Expected result: `mvn -v` reports Maven 3.9 or newer and Java 21; if not, fix Maven/JDK configuration.

The API reads environment variables, not the `.env` file itself, so start it with the script that loads `.env` first:

- Windows: `powershell -ExecutionPolicy Bypass -File .\scripts\run-backend.ps1`
- Linux or macOS: `./scripts/run-backend.sh`

Expected result: console shows `Started CanteenApplication`. Then open `http://localhost:8080/api/vendors` in a browser. It should list three stalls (Aling Nena's Silog, Kuya Jun's Burgers, Merienda Corner). The fourth sample stall is switched off on purpose, so it is hidden. If the endpoint is unavailable, check API startup and database connectivity.

### Step 5 (optional): Start the web client (port 5173)

A small React client in `frontend/` has a view for each role. It needs Node.js 18 or newer and the API from Step 4 running. In a second terminal, from the repository root:

```text
cd frontend
npm install
npm run dev
```

Expected result: Vite starts on port 5173. Open `http://localhost:5173` and log in with a sample account. `npm install` is needed only once. The port is fixed because the API only accepts browser requests from `http://localhost:5173` and `http://localhost:3000`. On Windows PowerShell, if `npm` is blocked with “running scripts is disabled”, use `npm.cmd` instead (for example `npm.cmd install`) or run `Set-ExecutionPolicy -Scope Process Bypass` first. Details: [frontend/README.md](frontend/README.md). If startup fails, check Node, port availability, and API startup.

## Sample accounts

All sample accounts use the demo password `Password123!`. It exists only in the sample data; do not reuse it for real accounts or treat it as a production credential.

| Application role | Email | Notes |
|---|---|---|
| Administrator | admin@canteen.test | Stalls and canteen report |
| Vendor | nena@vendor.test | Has two active orders today |
| Vendor | jun@vendor.test | |
| Vendor | merienda@vendor.test | |
| Vendor | waffles@vendor.test | Stall is switched off, so it cannot log in |
| Student | maria@student.test | Has a pending order today |
| Student | juan@student.test | Has an order being prepared today |

Expected result: the listed sample users authenticate only against the seeded local sample database. If they cannot log in, the seed may not have loaded; run the setup script and check its actual output.

## Check that it works

### Automatic check

With the API running, in another terminal at the repository root:

```text
powershell -ExecutionPolicy Bypass -File .\test-flow.ps1
```

Expected result: it ends with `All steps ran.` in green. The test registers a new vendor and student, adds menu items, places two orders, moves one through preparing, ready and completed, cancels the other, then prints notifications and a sales report. Run it before 23:59 Philippine time, because its pickup time is 23:59. This README does not claim that the smoke test has run or passed.

### Check in the web client

With the API and client running, log in at `http://localhost:5173`:

| Log in as | Do this | Expected |
|---|---|---|
| maria@student.test | Order food: view a menu, set quantities and a pickup time, place the order | A queue number; the order appears under My orders |
| nena@vendor.test | Orders tab: mark an order preparing, ready, then completed | The status moves forward each time |
| maria@student.test | Refresh My orders and Notifications | The new status and a notification (the client does not update live) |
| admin@canteen.test | Stalls tab: switch a stall off; Sales tab | The stall disappears from the student list; per-stall report shown |

Expected result: each action matches the table. If it does not, save actual output/screenshots with secrets redacted and follow [Troubleshooting](#troubleshooting).

### Check by role

Log in with `POST /api/auth/login` using `email` and `password`, then send the returned token as `Authorization: Bearer <token>`. Do not save a real token in the README or evidence. Endpoint list: [docs/api-endpoints.md](docs/api-endpoints.md).

| Log in as | Do this | Expected |
|---|---|---|
| maria@student.test | `GET /api/orders` | Her pending order with queue number 1. |
| maria@student.test | `POST /api/orders` for a stall, with a later pickup time. | A queue number and total. |
| nena@vendor.test | `GET /api/vendor/orders`, then `PATCH` a status to `preparing`, then `ready`. | Orders move forward; going backwards is rejected with 409. |
| nena@vendor.test | Add, edit, hide and delete a menu item | The public menu `GET /api/vendors/{id}/menu` changes accordingly |
| nena@vendor.test | `GET /api/vendor/reports/sales` | Revenue and top items from completed orders. |
| admin@canteen.test | `PATCH /api/admin/vendors/{id}/active` with `{"active": false}` | The stall disappears from `GET /api/vendors` |
| admin@canteen.test | `GET /api/admin/reports/sales` | Canteen-wide report with per-vendor breakdown. |
| maria@student.test | `POST /api/orders/{id}/cancel` on a pending order. | Status becomes cancelled; a preparing order cannot be cancelled (409). |

Expected result: each request enforces the stated application-role behavior. If a request differs, record status, endpoint, sanitized request/response, and account role without a token or password.

## Application user roles

| Application role | What it can do | Database role it maps to |
|---|---|---|
| Student | Order, view and cancel (while pending) their own orders, read their notifications. | No login of its own; uses the runtime account. |
| Vendor | Manage their own menu, handle orders for their stall, view their sales. | No login of its own; uses the runtime account. |
| Administrator | Switch stalls on or off, view the canteen report. | No login of its own; uses the runtime account. |
| Application runtime | The account the API connects with. | `canteen_app`, member of `canteen_app_grp`. |

Details: [docs/user-roles.md](docs/user-roles.md) and [docs/database-roles.md](docs/database-roles.md).

## Configuration reference

| Variable | Meaning | Default |
|---|---|---|
| `DB_HOST` | Database server | localhost |
| `DB_PORT` | Database port | 5432 |
| `DB_NAME` | Database name | `canteen_db` |
| `DB_USER` | Runtime database login | `canteen_app` |
| `DB_PASSWORD` | Runtime login password | Set locally in `.env` |
| `DB_ADMIN_USER` | Maintenance and migration login | `canteen_admin` |
| `DB_ADMIN_PASSWORD` | Maintenance login password | Set locally in `.env` |
| `DB_READONLY_PASSWORD` | Read-only reporting login password | Set locally in `.env` |
| `JWT_SECRET` | Signs login tokens, 32 or more characters | none, required |

To use another database name, change `DB_NAME` in `.env` before running the setup script. Never include a real value in this reference or in Git.

## Database

Seven tables: `student`, `vendor`, `menu_item`, `customer_order`, `order_item`, `queue_entry` and `notification`. Scripts, migrations and seed data are in `database/`; access-control scripts are in `db-access-control/`. ERD, columns, constraints and changes from the approved Activity 2 design: [docs/database.md](docs/database.md).

### Reset the data

To clear all data and reload the samples (tables stay):

```text
psql -U canteen_admin -d canteen_db -f database/reset.sql
psql -U canteen_admin -d canteen_db -f database/seed/001_sample_data.sql
```

Expected result: application data is cleared and sample data is reloaded while table structures remain. If either command fails, stop and check the target database/account before retrying; do not run against another group's database.

## Common problems

| Problem | Fix |
|---|---|
| `psql` not recognized | Add the PostgreSQL `bin` folder to PATH and open a new terminal |
| `password authentication failed for user "canteen_admin"` | `DB_ADMIN_PASSWORD` does not match the password entered for the role; see Step 2 |
| `Could not resolve placeholder 'DB_PASSWORD'` | Start the API with `scripts\run-backend.ps1` so `.env` is loaded |
| `Schema-validation: missing column` | Run the setup script again; it is safe to repeat |
| Requests fail with connection refused | The API is not running on port 8080 |
| Sample accounts cannot log in | The seed did not load; run the setup script again |
| `release version 25 not supported` | `java.version` in `pom.xml` was changed to 25; set it back to 21 |
| `java -version` still shows another JDK | The JDK 21 folder name is wrong or was set in a different window; see Step 4 |
| `npm` is blocked or not recognized | Use `npm.cmd`, or `Set-ExecutionPolicy -Scope Process Bypass`; open a new window after installing Node |
| Web client shows "Failed to fetch" | The API is not running on port 8080, or the client is not on port 5173 |
| `Port 5173 is already in use` | Close the other frontend terminal; the port must stay 5173 |

These are the original application problems/fixes. The expanded [Troubleshooting](#troubleshooting) table above also covers database-operations testers. The full application list is in [docs/troubleshooting.md](docs/troubleshooting.md).

## Security notes

- No real credentials are committed. `.env` is ignored by Git; `.env.example` holds placeholders only. `.env` must never be committed.
- Passwords are stored as BCrypt hashes. The demo password applies only to the sample data and must not be reused for real accounts.
- Login tokens last 2 hours.
- Browser requests are accepted only from `http://localhost:5173` and `http://localhost:3000`.
- The API listens on all network interfaces by default; keep it on a local or trusted network while developing.
- Review every database on the PostgreSQL cluster before running `db-access-control/07-security-restrictions.sql`; it revokes `PUBLIC CONNECT` cluster-wide and can affect other applications.
- Keep passwords, tokens, connection strings, `.env` contents, and data-bearing backup files out of the repository, tracker, screenshots, and submission archive.

## For groups testing this project

- Use only this repository and its documentation, with your own local PostgreSQL. Please do not edit the repository to make it work; record problems in the tracker's testing log and tell us.
- Record in the log whether each of Steps 1 to 4 worked, and which roles from the original application role tests you exercised.
- Expected result of each step is stated above, so any difference is worth reporting.
- For Activities 4–6, separately use only other groups' projects from the confirmed inventory, follow their documentation, and obtain owner/instructor authorization. Do not treat `canteen_db` as the other-group target.

## Documentation index

- [Database documentation](docs/database.md)
- [Application user roles](docs/user-roles.md)
- [Database user and role setup](docs/database-roles.md)
- [Backend endpoints](docs/api-endpoints.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Web client](frontend/README.md)

## Detailed Documentation

- [Requirements matrix](docs/activity-4-5-6/REQUIREMENTS_MATRIX.md)
- [Tester guide](docs/activity-4-5-6/TESTER_GUIDE.md)
- [Expected results](docs/activity-4-5-6/EXPECTED_RESULTS.md)
- [Evidence guide](docs/activity-4-5-6/EVIDENCE_GUIDE.md)
- [Manual checks](docs/activity-4-5-6/MANUAL_CHECKS.md)
- [Current blockers](docs/activity-4-5-6/BLOCKERS.md)
- [README content preservation map](docs/activity-4-5-6/README_CONTENT_MAP.md)
- [Credential rotation checklist](docs/activity-4-5-6/CREDENTIAL_ROTATION_CHECKLIST.md)
- [AI usage declaration](docs/activity-4-5-6/AI_USAGE_DECLARATION.md)
- [Activity 5/6 blockers](docs/activity-5-6/BLOCKERS.md)
- [Database verification scripts](scripts/verify/README.md)
