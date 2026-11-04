# Copilot Prompt - Activity 4/5/6 Tester Evidence Package

> This is the task prompt for GitHub Copilot. Run ONE phase at a time.
> Do not expect PDFs. Requirements are in docs/activity-requirements/.


You are a senior PostgreSQL database administrator and technical writer working in this repository:

bwisIT-Solutions---Campus-Canteen-Pre-Order-and-Queue-Management-System

Your task is to make the repository easy for a tester or instructor to verify for COMP018 Activities 4, 5, and 6.

Use these text extracts of the official activity documents as your requirements source:

- docs/activity-requirements/COMP018_Activity_4_Requirements.md
- docs/activity-requirements/COMP018_Activity_5_Requirements.md
- docs/activity-requirements/COMP018_Activity_6_Requirements.md

If the official PDFs are also available, they remain the authoritative source and win
any conflict. If a text extract looks truncated or garbled, say so and mark the affected
requirement as NEEDS VERIFICATION instead of guessing.

Do not ask for, expect, or depend on PDF attachments. If you cannot read a file,
say which file failed and continue with the others.

Also read the existing repository:
- README.md
- docs/database.md
- docs/database-roles.md
- docs/user-roles.md
- database/setup.ps1
- database/setup.sh
- database/migrations/
- database/seed/
- db-access-control/
- .env.example
- .gitignore

If a compliance context file exists in docs/ or at COMP018_Activity_5_6_Compliance_Context.md, use it as a reference, but the official activity documents are authoritative.

## Primary outcome

Produce an Activity 4/5/6 evidence package that a tester can follow without guessing:

1. A requirements-to-evidence traceability matrix extracted from all three activity documents.
2. Simple, safe, tester-runnable scripts that check each verifiable requirement and print PASS, FAIL, SKIP, or BLOCKED.
3. A concise "For Testers" README section with setup, run, and test steps.
4. The expected result for every script and every manual check in the README.
5. Evidence folder templates and a blockers log.
6. Clear separation between automated checks, manual checks, and blocked items.

Do not fabricate evidence. Do not claim a test passed unless it was actually run and its real output was saved.

## Hard rules

1. Do not change application business logic. This task is about scripts, tests, documentation, and evidence structure.
2. Do not include real passwords, API keys, tokens, connection strings, or .env contents in any file, script, README, tracker template, PDF outline, or screenshot instruction.
3. Use placeholders and environment variables. Read real credentials from .env, PGPASSWORD, .pgpass, or an interactive prompt.
4. Do not commit .dump, .backup, .sql.gz, or other data-bearing backup files.
5. Do not modify another group's repository.
6. Activity 4, 5, and 6 must target the Activity 3 projects of other groups, not only this canteen project.
7. The existing db-access-control/ work for this canteen project is a useful reference implementation, but it is not a substitute for per-project work on other groups' databases.
8. If the other groups' project inventory, database names, accounts, CREATEDB access, or logging permission are unknown, create explicit BLOCKED entries. Do not invent values.
9. Use the Activity 4 account that fits each task:
   - Inspection/audit: read-only or auditor account where possible.
   - Maintenance: maintenance owner account.
   - Backup/restore: maintenance or dedicated backup account.
   - Never the application runtime account for maintenance or backup.
10. Scripts must be safe by default. Destructive, maintenance, backup, restore, and recovery actions require an explicit flag such as -Execute and, where appropriate, -Confirm.
11. Do not use VACUUM FULL unless the instructor explicitly approves it.
12. Do not run destructive recovery tests against an original database.
13. Keep the README concise. Put detailed matrices and long explanations in docs/ and link to them.

## Phase 1 — Extract requirements

Read all three activity requirement files under `docs/activity-requirements/` and extract every required task, deliverable, rubric criterion, and submission-checklist item.

Create:

docs/activity-4-5-6/REQUIREMENTS_MATRIX.md

Use this table format:

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|

Rules for the matrix:
- One row per distinct requirement or checklist item.
- "How checked" must name the script or the manual check.
- "Expected result" must be concrete and testable.
- "Evidence file" must name the file the tester should inspect.
- "Status" must be one of: Implemented, Template, Manual only, Blocked.
- Include the exact Activity 4, 5, and 6 tracker columns and PDF sections as rows or in a separate section.
- Do not collapse multiple requirements into one vague row.

Required coverage:

Activity 4:
- Part A: set up all other groups' Activity 3 projects; identify database objects and access requirements; review user-roles docs; prepare per-project access-control plans; record blockers; report to owners.
- Part B: identify users, group roles, and privileges.
- Part C: group roles (NOLOGIN), login roles, memberships, database access, schema access, object-level access.
- Part D: least privilege; no superuser for the app; no unrelated database access; no writes outside responsibilities; read-only cannot write; no unnecessary CREATEDB/CREATEROLE; review PUBLIC privileges and inherited memberships.
- Part E: test each login account in each project database; record account, statement, expected result, actual result, evidence.
- Part F: db-access-control/ with one subfolder per project; meaningful commits; no secrets; no other-repo changes; Activity 4 Log tracker tab; PDF sections; feedback to owners; AI usage declaration.

Activity 5:
- Part A: PostgreSQL version, database name, size, object/table count, sessions/connections, running queries and duration, failed connections/errors, Activity 4 roles/accounts, account used per check.
- Part B: log review for failed logins, SQL errors, long-running queries, blocked activity, warnings, permission-denied errors; evidence, explanation, impact, next step; limitations.
- Part C: review tables/indexes; ANALYZE; VACUUM (VERBOSE, ANALYZE); confirm completion; explain purpose and account.
- Part D: one meaningful application SELECT; EXPLAIN and EXPLAIN (ANALYZE, BUFFERS); interpret scan type, estimated vs actual rows, timing, buffers; recommend improvement or justify plan.
- Part E: per-project report with environment, health, logs, maintenance, query plan, limitations, prioritized recommendations.
- Part F: db-maintenance/ with one subfolder per project; meaningful commits; no secrets; no other-repo changes; Activity 5 Log tracker tab; PDF sections; feedback to owners; AI usage declaration.

Activity 6:
- Part A: backup plan with database/objects, method, storage, access, verification, schedule, retention, RPO, RTO, and role recreation after restore.
- Part B: pg_dump custom-format backup; record command, file name, size, checksum, date/time, errors; pg_restore --list; explain why a backup file is not proof of recovery.
- Part C: create a separate empty test database; restore; verify tables/objects, sample records, constraints, sequences, Activity 4 roles/memberships/privileges, one permitted and one denied operation, representative SELECT, application connection if feasible; document limitations.
- Part D: controlled recovery simulation using disposable test data; before/after state; recovery method; comparison; RPO implications.
- Part E: per-project report with commands, evidence, verification, incident timeline, limitations, evaluation, recommendations.
- Part F: db-backup-recovery/ with one subfolder per project; no committed dumps; meaningful commits; no secrets; no other-repo changes; Activity 6 Log tracker tab; PDF sections; feedback to owners; AI usage declaration.

## Phase 2 — Design the test scripts

Create a scripts/verify/ folder.

Suggested structure:

scripts/verify/
  README.md
  run-all.ps1
  run-activity4.ps1
  run-activity5.ps1
  run-activity6.ps1
  lib/
    common.ps1
  activity4/
    01-check-roles.ps1
    02-check-memberships.ps1
    03-check-database-privileges.ps1
    04-check-schema-table-privileges.ps1
    05-check-sequence-privileges.ps1
    06-check-default-privileges.ps1
    07-check-public-restrictions.ps1
    08-run-allowed-denied-tests.ps1
  activity5/
    01-health-check.ps1
    02-activity-check.ps1
    03-role-check.ps1
    04-log-check.ps1
    05-maintenance-check.ps1
    06-query-plan.ps1
  activity6/
    01-check-backup-plan.ps1
    02-create-backup.ps1
    03-checksum.ps1
    04-archive-list.ps1
    05-restore-test.ps1
    06-verify-restore.ps1
    07-recovery-simulation.ps1
    08-check-no-dumps-committed.ps1

You may adjust file names, but keep the structure simple and predictable.

Script requirements:
- PowerShell 5.1+ compatible. Add simple bash equivalents only where they are straightforward.
- No external PowerShell modules beyond built-in cmdlets, psql, and git.
- Accept parameters such as:
  - -Project <group-XX>
  - -DbName <name>
  - -DbHost <host>
  - -DbPort <port>
  - -AdminUser <name>
  - -AppUser <name>
  - -ReadonlyUser <name>
  - -EvidenceDir <path>
  - -DryRun
  - -Execute
  - -Confirm
- Read passwords from PGPASSWORD, .pgpass, or the environment. Never accept a password parameter. Never print a password.
- Use psql with:
  -w -v ON_ERROR_STOP=1 -P pager=off
- Print one line per check in this format:
  PASS  <check name> - <short evidence>
  FAIL  <check name> - <reason>
  SKIP  <check name> - <prerequisite missing>
  BLOCKED <check name> - <blocker and required action>
- Print a final summary:
  PASS: n
  FAIL: n
  SKIP: n
  BLOCKED: n
- Exit 0 only when there are no FAIL and no BLOCKED results. Exit non-zero when any FAIL or BLOCKED exists.
- Save the full output to a timestamped evidence file:
  evidence/activity-4/<project>/<yyyy-mm-dd>/<script-name>.txt
  evidence/activity-5/<project>/<yyyy-mm-dd>/<script-name>.txt
  evidence/activity-6/<project>/<yyyy-mm-dd>/<script-name>.txt
- Add a -DryRun mode that prints the SQL/commands and expected result without executing maintenance, backup, restore, or recovery actions.
- Do not run destructive actions without -Execute. Recovery simulation must also require -Confirm.
- Add a header to every script:
  Purpose, Activity/Part, Required account, Safety notes, Expected result.
- Do not hard-code database names, accounts, paths, or group numbers. Use parameters or config.

Create a shared library:

scripts/verify/lib/common.ps1

It should provide:
- Load-DotEnv: parse KEY=VALUE lines from .env without printing secrets.
- Invoke-Psql: run psql and return output plus exit code.
- Write-Check: print PASS/FAIL/SKIP/BLOCKED consistently.
- New-EvidencePath: create timestamped evidence folders.
- Save-Evidence: write output to the evidence file.
- Assert-Contains / Assert-NotContains / Assert-ExitCode / Assert-Equals.
- Get-ProjectConfig: read a project entry from config/projects.local.json or parameters.

Create:

config/projects.example.json

with fields:
{
  "group": "group-01",
  "projectName": "<project name>",
  "repoUrl": "<repository URL>",
  "dbName": "<database name>",
  "pgVersion": "<version or unknown>",
  "adminUser": "<A4 maintenance account>",
  "appUser": "<A4 runtime account>",
  "readonlyUser": "<A4 readonly account>",
  "reachable": "unknown",
  "ownerContact": "<contact or unknown>",
  "notes": "<notes>"
}

Add config/projects.local.json to .gitignore. It may contain local-only names but must not contain passwords.

## Phase 3 — Write the Activity 4 checks

Each check must state the expected result in its header and in the README.

01-check-roles.ps1:
- Check required group roles exist and are NOLOGIN.
- Check required login roles exist and have LOGIN.
- Check application and read-only roles are not SUPERUSER, not CREATEDB, not CREATEROLE, not REPLICATION, not BYPASSRLS.
- Expected: all required roles exist with correct attributes; no FAIL.

02-check-memberships.ps1:
- Check each login role is a member of the intended group role.
- Check there are no unexpected memberships.
- Expected: required memberships present; no unauthorized memberships.

03-check-database-privileges.ps1:
- Check CONNECT on the application database for the intended roles.
- Check CONNECT on unrelated databases is denied for app/readonly roles.
- Check CREATE on the application database is denied for app/readonly roles.
- Expected: correct CONNECT, no CREATE, no unrelated database access.

04-check-schema-table-privileges.ps1:
- Check USAGE on the application schema.
- Check table privileges for app and readonly roles.
- Check readonly has SELECT only and no INSERT/UPDATE/DELETE.
- Expected: app has required DML; readonly has SELECT only; no excess grants.

05-check-sequence-privileges.ps1:
- Check sequence USAGE/SELECT for the app role where required.
- Check readonly cannot modify sequences.
- Expected: app can use required sequences; readonly cannot.

06-check-default-privileges.ps1:
- Check pg_default_acl for unintended grants.
- Expected: no unexpected default privileges for PUBLIC or app roles.

07-check-public-restrictions.ps1:
- Check PUBLIC CONNECT is revoked where required.
- Check PUBLIC has no unintended table/schema privileges.
- Expected: PUBLIC is restricted; no unintended access.

08-run-allowed-denied-tests.ps1:
- Run the existing Activity 4 test SQL (readonly-allowed, readonly-denied, runtime-allowed, runtime-denied) against the project database.
- Capture each PASS notice and each denial.
- Record account, statement, expected result, actual result.
- Expected: all allowed operations succeed; all denied operations are denied with the expected error.
- If the test SQL is specific to the canteen schema, create project-adapted copies under db-access-control/<project>/tests/ and explain the adaptation.

## Phase 4 — Write the Activity 5 checks

01-health-check.ps1:
- SELECT version();
- SELECT current_database();
- SELECT pg_size_pretty(pg_database_size(current_database()));
- Count user tables, indexes, sequences.
- Query pg_stat_database for the current database.
- Query pg_stat_activity for the current database.
- Expected: all queries return; output is saved; permission limitations are recorded.

02-activity-check.ps1:
- Check sessions, states, wait events, query durations.
- Identify active, idle, and idle-in-transaction sessions.
- Expected: session summary produced; long-running or blocked sessions flagged if present.

03-role-check.ps1:
- Verify Activity 4 roles and login accounts still exist.
- Compare against the expected role list from the project config.
- Expected: no missing or unexpected roles; differences recorded.

04-log-check.ps1:
- Read logging settings: log_destination, logging_collector, log_directory, log_filename, log_connections, log_disconnections, log_min_duration_statement, log_statement, log_line_prefix, log_lock_waits.
- Attempt to locate/read available logs.
- If logging is disabled or access is denied, print BLOCKED and record the limitation.
- Expected: either real log findings or a documented limitation; no invented incidents.

05-maintenance-check.ps1:
- Before: query pg_stat_user_tables for the target table.
- Require -Execute and -Table.
- Run ANALYZE on the table.
- Run VACUUM (VERBOSE, ANALYZE) on the table as a standalone command.
- After: query pg_stat_user_tables again.
- Expected: both commands complete; before/after stats captured; no VACUUM FULL.

06-query-plan.ps1:
- Require -SqlFile containing a safe SELECT.
- Run EXPLAIN.
- Run EXPLAIN (ANALYZE, BUFFERS) only when -Execute is supplied.
- Save both plans.
- Expected: plan captured; scan type, rows, timing, and buffers available for interpretation.

## Phase 5 — Write the Activity 6 checks

01-check-backup-plan.ps1:
- Verify backup-plan.md exists for the project.
- Check it contains headings for: database/objects, method, storage, access, verification, schedule, retention, RPO, RTO, role recreation.
- Expected: all required sections present; no placeholder-only content.

02-create-backup.ps1:
- Require -Execute.
- Run pg_dump -Fc with parameters.
- Write the dump to a protected local path outside the repository.
- Record: command, file name, size, SHA256, date/time, PostgreSQL versions, account used, errors.
- Expected: dump created; metadata recorded; no dump committed.

03-checksum.ps1:
- Compute SHA256 for the backup file.
- Print file name, size, checksum, timestamp.
- Expected: checksum recorded in checksums.txt.

04-archive-list.ps1:
- Run pg_restore --list on the backup.
- Save the listing.
- Expected: archive listing produced with tables, sequences, constraints, indexes, ACLs.

05-restore-test.ps1:
- Require -Execute and -Confirm.
- Check whether the account can create a database.
- If not, print BLOCKED with the exact instructor/setup request.
- Create a separate test database with a distinct name.
- Run pg_restore into it.
- Do not restore over the original.
- Expected: restore completes; warnings/errors captured; test database name recorded.

06-verify-restore.ps1:
- Verify tables, row counts, primary keys, foreign keys, constraints, sequences.
- Verify Activity 4 roles/memberships/privileges or document that role scripts must be rerun.
- Run one permitted and one denied operation.
- Run a representative SELECT.
- Record application connection result if feasible.
- Expected: all checks PASS; differences documented.

07-recovery-simulation.ps1:
- Require -Execute and -Confirm.
- Use only the restored test database.
- Create or select a clearly identified disposable test record.
- Record before state.
- Delete the record.
- Record after-loss state.
- Restore the backup into a fresh recovery database.
- Compare recovered state with expected state.
- Expected: record recovered; comparison PASS; RPO implications documented.
- Do not touch the original database.

08-check-no-dumps-committed.ps1:
- Run git ls-files and check for *.dump, *.backup, *.sql.gz, backups/.
- Expected: no data-bearing backup files tracked.

## Phase 6 — Rewrite the README for testers

Update README.md so a tester can understand it quickly and verify Activities 4, 5, and 6
without prior knowledge of the project.

### 6.1 Hard rule: nothing lost

Before editing, list every existing README heading and subsection. After editing, produce a
mapping table showing where each one went. Every existing fact, command, table row, expected
result, warning, and link must still exist. You may move text, shorten wording, and regroup
sections, but you may not delete information.

A useful test: the new README must still answer all of these:

- What the project is and who is in the group.
- What each top-level folder contains.
- What tools and versions are required.
- How to clone, configure `.env`, create roles, run setup, start the API, and start the web client.
- What the sample accounts are.
- How to run the automatic smoke test and what success looks like.
- How to test each application role through the API or web client.
- How application roles map to database roles.
- Every configuration variable.
- The seven database tables and how to reset data.
- Every known problem and its fix.
- Security notes.
- Instructions for other groups testing this project.
- The documentation index.
- The AI usage declaration.

Create `docs/activity-4-5-6/README_CONTENT_MAP.md` with:

| Original README section | New location | Content preserved? | Notes |
|---|---|---|---|

Every row must say "Yes". If something was intentionally replaced, explain why and where
the replacement is.

### 6.2 Structure

Keep the existing project information, then add a short tester path near the top followed by
the detailed reference material. Suggested order:

```
# Campus Canteen Pre-Order and Queue Management System
Short description + metadata table (group, members, branch, status)

## For Testers — Start Here
## What You Need
## Quick Setup
## Run the Application
## Test Activity 4 — Access Control
## Test Activity 5 — Maintenance and Monitoring
## Test Activity 6 — Backup and Recovery
## Expected Results
## Where Evidence Goes
## Troubleshooting
## Known Blockers
## AI Usage

## What is in this repository
## Prerequisites
## Setup
## Sample accounts
## Check that it works
## Application user roles
## Configuration reference
## Database
## Common problems
## Security notes
## For groups testing this project
## Documentation index
## Detailed Documentation
```

The tester sections come first because a tester needs them first. The original reference
sections stay below, intact.

### 6.3 "For Testers — Start Here"

One short paragraph, then a table:

| I want to... | Go to |
|---|---|
| Set up and run the canteen app | Quick Setup, then Run the Application |
| Verify Activity 4 access control | Test Activity 4 |
| Verify Activity 5 maintenance and monitoring | Test Activity 5 |
| Verify Activity 6 backup and recovery | Test Activity 6 |
| Know what "correct" looks like | Expected Results |
| Understand why something is blocked | Known Blockers |

State clearly which parts are the group's own canteen project and which parts must use
another group's Activity 3 project. Activity 4, 5, and 6 require other groups' projects;
do not let a tester believe testing only `canteen_db` is enough.

### 6.4 "What You Need"

List prerequisites as a table with a check command and the expected output. Include:

- Windows PowerShell 5.1+ or PowerShell 7+
- PostgreSQL 16+ with `psql` on PATH
- Java 21 and Maven 3.9+
- Node.js 18+ (only for the web client)
- Git
- Access to the class tracker / other groups' project inventory
- Local credentials in `.env`, never committed

### 6.5 "Quick Setup"

Numbered steps. Every step must contain:

1. The exact command.
2. The expected result.
3. What to do if it fails.

Cover at minimum:

1. Clone the repository.
2. Copy `.env.example` to `.env` and fill local values. Never commit `.env`.
3. Create the Activity 4 roles and memberships as a superuser.
4. Run `database/setup.ps1` or `database/setup.sh`.
5. Verify the database and roles.
6. Start the API and confirm a known endpoint.
7. Optionally start the web client.

Do not remove the existing JDK 21 guidance, the hidden-password warning, the
`db-access-control/07-security-restrictions.sql` warning, or the expected 7-table list.

### 6.6 "Run the Application"

Keep the existing backend and frontend commands. Add a compact table:

| Component | Command | Expected result | Where |
|---|---|---|---|
| API | `powershell -ExecutionPolicy Bypass -File .\scripts\run-backend.ps1` | `Started CanteenApplication`, `GET /api/vendors` returns 3 stalls | http://localhost:8080 |
| Web client | `cd frontend; npm install; npm run dev` | Vite starts on port 5173 | http://localhost:5173 |
| Smoke test | `powershell -ExecutionPolicy Bypass -File .\test-flow.ps1` | Ends with `All steps ran.` | repo root |

### 6.7 "Test Activity 4 — Access Control"

Explain in two or three sentences:

- Activity 4 is about roles, memberships, privileges, and least privilege.
- The canteen `db-access-control/` folder is the group's own reference implementation.
- Per-project work for other groups goes in `db-access-control/<group>/`.

Then give:

| Step | Command | Expected result |
|---|---|---|
| Run all Activity 4 checks | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/run-activity4.ps1 -Project group-01` | `FAIL: 0`, `BLOCKED: 0`, exit code 0 |
| Check roles | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity4/01-check-roles.ps1 -Project group-01` | All required roles exist; no unexpected SUPERUSER/CREATEDB/CREATEROLE |
| Check memberships | `... 02-check-memberships.ps1 ...` | Required memberships present; no unauthorized memberships |
| Check database privileges | `... 03-check-database-privileges.ps1 ...` | CONNECT allowed only where intended; CREATE denied for app and read-only |
| Check schema/table privileges | `... 04-check-schema-table-privileges.ps1 ...` | App has required DML; read-only has SELECT only |
| Check sequence privileges | `... 05-check-sequence-privileges.ps1 ...` | App can use required sequences; read-only cannot modify them |
| Check default privileges | `... 06-check-default-privileges.ps1 ...` | No unintended default grants |
| Check PUBLIC restrictions | `... 07-check-public-restrictions.ps1 ...` | PUBLIC is restricted; no unintended access |
| Run allowed/denied tests | `... 08-run-allowed-denied-tests.ps1 ...` | Allowed operations succeed; denied operations are denied |

Then a short manual-check list:

- `db-access-control/<group>/` exists with plan, SQL, and test evidence.
- Commits are meaningful.
- The Activity 4 Log tracker tab is updated.
- The PDF has the required A4 sections.
- Feedback was sent to each owning group.
- AI usage is declared and validated.
- No secrets appear in any file or screenshot.

Every manual check needs an expected result and a place to record evidence.

### 6.8 "Test Activity 5 — Maintenance and Monitoring"

State clearly that Activity 5 must target another group's Activity 3 database, not only the
canteen database, and that some checks may be blocked by permissions.

Table:

| Step | Command | Expected result |
|---|---|---|
| Run all Activity 5 checks | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/run-activity5.ps1 -Project group-01` | `FAIL: 0`, `BLOCKED` only for documented permission limits |
| Health check | `... activity5/01-health-check.ps1 ...` | Version, database name, size, table/index/sequence counts, and activity rows returned |
| Session activity | `... 02-activity-check.ps1 ...` | Active/idle/idle-in-transaction sessions summarised |
| Role check | `... 03-role-check.ps1 ...` | Activity 4 roles still exist |
| Log check | `... 04-log-check.ps1 ...` | Real log findings, or `BLOCKED` with the exact permission limitation |
| Maintenance | `... 05-maintenance-check.ps1 -Table <table> -Execute ...` | ANALYZE and VACUUM (VERBOSE, ANALYZE) complete; before/after stats captured |
| Query plan | `... 06-query-plan.ps1 -SqlFile <file> -Execute ...` | EXPLAIN and EXPLAIN (ANALYZE, BUFFERS) output captured |

Manual checks:

- Log evidence exists, or the limitation is documented honestly.
- No invented incidents or timings.
- Maintenance was run with the correct account, not the application runtime account.
- No `VACUUM FULL` unless approved.
- The Activity 5 report, tracker tab, PDF sections, feedback, and AI declaration exist.

### 6.9 "Test Activity 6 — Backup and Recovery"

State clearly that restore and recovery tests must use a disposable test database and must
never touch an original database.

Table:

| Step | Command | Expected result |
|---|---|---|
| Run all Activity 6 checks | `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/run-activity6.ps1 -Project group-01` | `FAIL: 0`; `BLOCKED` only for missing CREATEDB/setup access |
| Check backup plan | `... activity6/01-check-backup-plan.ps1 ...` | All required plan sections present |
| Create backup | `... 02-create-backup.ps1 -Execute ...` | Custom-format dump created outside Git; metadata recorded |
| Checksum | `... 03-checksum.ps1 ...` | SHA256 recorded |
| Archive list | `... 04-archive-list.ps1 ...` | `pg_restore --list` shows tables, sequences, constraints, indexes, ACLs |
| Restore test | `... 05-restore-test.ps1 -Execute -Confirm ...` | Restore completes into a separate test database |
| Verify restore | `... 06-verify-restore.ps1 ...` | Tables, rows, constraints, sequences, roles, allowed and denied operations verified |
| Recovery simulation | `... 07-recovery-simulation.ps1 -Execute -Confirm ...` | Disposable record recovered; comparison PASS |
| No dumps committed | `... 08-check-no-dumps-committed.ps1 ...` | No `*.dump`, `*.backup`, or `*.sql.gz` tracked |

Manual checks:

- Backup plan includes method, storage, access, verification, schedule, retention, RPO, RTO.
- The backup file is stored outside the repository and not shared publicly.
- The restore was verified, not just completed.
- The Activity 6 report, tracker tab, PDF sections, feedback, and AI declaration exist.
- Original databases were not modified.

### 6.10 "Expected Results"

A single table covering every automated and manual check:

| Activity | Check | Command or action | Expected result | Failure means | Evidence |
|---|---|---|---|---|---|

Rules:
- One row per check.
- Expected results must be observable.
- Use "Expected result", not "we ran this and it passed", unless current real output is included.
- Link each row to `docs/activity-4-5-6/EXPECTED_RESULTS.md` for detail.

### 6.11 "Where Evidence Goes"

Explain:

- `evidence/activity-4/<project>/<yyyy-mm-dd>/`
- `evidence/activity-5/<project>/<yyyy-mm-dd>/`
- `evidence/activity-6/<project>/<yyyy-mm-dd>/`
- Dumps go to a protected local path outside Git.
- Text output is preferred; screenshots only when necessary.
- Redact secrets before saving or screenshotting.
- Each evidence file records account, role, database, date, command, and result.

### 6.12 "Troubleshooting"

Keep the existing common-problems table. Add tester-specific problems:

| Problem | Likely cause | Fix |
|---|---|---|
| `psql` not found | PostgreSQL `bin` not on PATH | Add it and open a new terminal |
| `password authentication failed` | `.env` value does not match the role password | Re-enter the password with `\password` |
| `database does not exist` | Setup did not complete, or wrong `DB_NAME` | Re-run setup; check `.env` |
| `permission denied for schema` | Missing `USAGE` grant | Re-apply schema grants |
| `permission denied for sequence` | Missing `USAGE`/`SELECT` on sequence | Re-apply sequence grants |
| `cannot create database` | Account lacks `CREATEDB` | Record `BLOCKED`; use the approved setup account |
| `pg_restore: warning` | Ownership or role differences | Record the warning; verify objects anyway |
| Log check returns `BLOCKED` | Logging disabled or no permission | Record the limitation; do not invent logs |
| Script stops at a prompt | Password requested interactively | Use `PGPASSWORD` or `.pgpass`, never a script argument |

### 6.12b "Known Blockers", "AI Usage", and "Detailed Documentation"

Keep these three short sections near the end of the README:

- **Known Blockers** — a 3-5 row table of current blockers with owner and next action, plus a link to `docs/activity-4-5-6/BLOCKERS.md`. Do not remove blockers because they look bad.
- **AI Usage** — one short paragraph naming the tools actually used (OpenCode, Claude, ChatGPT, and Copilot only if Copilot was actually used), what they helped with, and how output was validated. Link to `docs/activity-4-5-6/AI_USAGE_DECLARATION.md`. Do not claim a tool was not used without checking with the group.
- **Detailed Documentation** — links to:
  - `docs/activity-4-5-6/REQUIREMENTS_MATRIX.md`
  - `docs/activity-4-5-6/TESTER_GUIDE.md`
  - `docs/activity-4-5-6/EXPECTED_RESULTS.md`
  - `docs/activity-4-5-6/EVIDENCE_GUIDE.md`
  - `docs/activity-4-5-6/MANUAL_CHECKS.md`
  - `docs/activity-4-5-6/BLOCKERS.md`
  - `docs/activity-4-5-6/README_CONTENT_MAP.md`
  - `docs/activity-4-5-6/CREDENTIAL_ROTATION_CHECKLIST.md`

### 6.13 README rules

- Keep the tester path short. Move long explanations to `docs/`.
- Use numbered steps and tables.
- Every command must have an expected result.
- Every expected result must be observable.
- Do not claim a test passed unless the real output is included and current.
- Do not include secrets, real passwords, tokens, connection strings, or `.env` contents.
- Keep all existing content. Add, do not replace, unless the replacement preserves the fact.
- After editing, verify the README renders and every internal link resolves.

## Phase 7 — Create the supporting docs

Create:

docs/activity-4-5-6/TESTER_GUIDE.md
- Detailed tester walkthrough.
- Prerequisites.
- Setup.
- Per-activity test steps.
- Evidence capture.
- Troubleshooting.
- Limitations.

docs/activity-4-5-6/EXPECTED_RESULTS.md
- One row per script and manual check.
- Columns: Activity, Check, Command, Expected result, Failure meaning, Evidence.

docs/activity-4-5-6/README_CONTENT_MAP.md
- Proof that no existing README content was lost.
- Columns: Original README section, New location, Content preserved?, Notes.
- List every original heading and subsection, including tables and warnings.
- Every row must say "Yes" unless a deliberate replacement is explained.

docs/activity-4-5-6/EVIDENCE_GUIDE.md
- How to capture command output.
- Screenshot rules.
- Redaction checklist.
- File naming.
- What not to commit.
- How to record account, role, database, date, command, result.

docs/activity-4-5-6/MANUAL_CHECKS.md
- Requirements that cannot be automated:
  - Activity 4 Log tracker tab updated.
  - Activity 5 Log tracker tab updated.
  - Activity 6 Log tracker tab updated.
  - PDF sections completed.
  - Feedback sent to owners with dates.
  - AI usage declaration complete.
  - No secrets in repo, ZIP, PDF, tracker, screenshots.
  - Backup files stored securely and not committed.
  - Original databases and backups preserved.
- Columns: Activity, Manual check, Expected result, Evidence/link, Status.

docs/activity-4-5-6/BLOCKERS.md
- Current blockers:
  - Other groups' project inventory unknown.
  - CREATEDB/setup account for disposable restore databases unknown.
  - PostgreSQL logging changes permitted unknown.
  - Credential rotation status pending.
  - Class tracker link unknown.
  - Group number TBD.
- For each: activity, impact, fallback, action needed, do not invent.

docs/activity-4-5-6/CREDENTIAL_ROTATION_CHECKLIST.md
- DB_PASSWORD, DB_ADMIN_PASSWORD, DB_READONLY_PASSWORD, JWT_SECRET.
- Date rotated, old credential fails, new credential works.
- Local .env updated, not committed.
- Clean ZIP rebuilt without .env.
- Old ZIP removed or secured.
- No values recorded anywhere.

docs/activity-4-5-6/AI_USAGE_DECLARATION.md
- Tools: OpenCode, Claude, ChatGPT, and GitHub Copilot if actually used.
- Tasks performed.
- How output was validated.
- Statement that AI was not used to fabricate evidence.
- No secrets shared with AI tools.

## Phase 8 — Project folders for other groups

Create the per-project structure:

db-access-control/group-XX/
db-maintenance/group-XX/
db-backup-recovery/group-XX/

For each, include:
- README.md or plan.md with placeholders.
- The scripts/templates relevant to that activity.
- A BLOCKERS.md entry if the project is unknown.
- Clearly mark placeholder folders as "TEMPLATE — replace with real project data."

Do not create fake group names, database names, accounts, or results.

## Phase 9 — Verification and reporting

After creating files:
1. List every file created or changed.
2. Provide a summary table:
   | Area | Files | Status | Notes |
3. Provide a coverage table:
   | Activity | Automated checks | Manual checks | Blocked items |
4. Run a static check if possible:
   - powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/run-all.ps1 -DryRun
   - If PowerShell is unavailable, inspect scripts manually and report that they were not executed.
5. Check for secrets:
   - Search for .env values in tracked files.
   - Confirm .env, dumps, backups, and node_modules are not tracked.
6. Verify the README:
   - Every original heading still exists or is mapped in `docs/activity-4-5-6/README_CONTENT_MAP.md`.
   - Every command has a stated expected result.
   - Every internal link resolves.
7. Report what is still blocked:
   - Other groups' project inventory.
   - CREATEDB/setup account.
   - Logging permission.
   - Credential rotation.
   - Tracker/PDF links.
8. Do not claim any test passed unless it was actually executed and the real output was saved.

## Output format

Start with a short plan and the requirements matrix outline. Then create the files. Then provide:

1. A file-by-file summary.
2. The exact commands a tester should run, in order.
3. The expected result for each command.
4. A list of manual checks the tester must perform.
5. A list of blockers and what input is needed.
6. A secret-scan result.

If any requirement cannot be automated, say so and explain the manual check. Do not hide gaps.