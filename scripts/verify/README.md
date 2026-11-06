# Database verification scripts

These PowerShell 5.1+ scripts provide repeatable checks for COMP018 Activities 4, 5, and 6. They are templates until the project inventory, database owner approval, local configuration, and actual command output are supplied. No database or backup operation has been run by creating these scripts.

**Command name:** on Windows, use `powershell` (Windows PowerShell 5.1). If you installed PowerShell 7, `pwsh` also works. The examples below use `powershell -NoProfile -ExecutionPolicy Bypass -File` so they run on a default Windows install.

## Safety and configuration

- Copy `config/projects.example.json` to the ignored `config/projects.local.json`; use one JSON object per project in an array when testing multiple groups.
- Replace every placeholder with verified, non-secret facts. Do not put passwords, tokens, connection strings, or `.env` values in this file.
- Credentials come from a locally approved `PGPASSWORD` environment variable or `.pgpass`. No script accepts or prints password parameters.
- Use only the database and accounts authorized by its owner. Database names, account names, schema names, expected objects, test SQL paths, log paths, and recovery marker are not inferred.
- `-DryRun` prints a preview and performs no database, backup, restore, or recovery operation. Use `-Execute` only after manually reviewing the target, query, and permissions.
- Activity 6 restore and recovery require both `-Execute -Confirm`. They require a new, distinct database name ending in `_a6_restore_YYYYMMDD` or `_a6_recovery_YYYYMMDD`; the scripts refuse the configured source database and never drop an existing database.
- Recovery simulation additionally requires an exactly-one, unique disposable marker row already present in the protected backup. It deletes only from the restored test database, then restores the archive into a fresh recovery database. Never use a real user/customer record. The original source database is not a valid test target.
- Dumps must be written to a protected absolute directory outside this repository. Do not include dumps in Git, ZIPs, or submission evidence.
- `-LoadEnv` loads `.env` into the current child process without displaying it. Prefer approved environment/pgpass configuration; do not copy `.env` values into evidence.

## Run safely

From the repository root, preview all checks:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/run-all.ps1 -Project group-01 -DryRun
```

Run an individual activity preview:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/run-activity4.ps1 -Project group-01 -DryRun
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/run-activity5.ps1 -Project group-01 -DryRun
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/run-activity6.ps1 -Project group-01 -DryRun
```

For real read-only checks, configure the local project entry and approved authentication, then use `-Execute`. Checks requiring user-provided files or values report `BLOCKED` until those inputs are supplied. `BLOCKED` is not a successful verification and must be explained in the report.

## Activity 4 — access control

The Activity 4 runner executes these checks in order:

| Script | Expected result |
|---|---|
| `activity4/01-check-roles.ps1` | Required NOLOGIN group roles and expected LOGIN roles exist with safe role attributes. |
| `activity4/02-check-memberships.ps1` | Required role memberships exist; unplanned membership among configured roles is flagged. |
| `activity4/03-check-database-privileges.ps1` | CONNECT/CREATE and unrelated-database access match the explicit plan. |
| `activity4/04-check-schema-table-privileges.ps1` | Runtime and read-only schema/table privileges match the configured plan. |
| `activity4/05-check-sequence-privileges.ps1` | Sequence privileges match the configured plan. |
| `activity4/06-check-default-privileges.ps1` | Default ACLs are captured and reviewed against the intended policy. |
| `activity4/07-check-public-restrictions.ps1` | PUBLIC has no unintended schema/table access. |
| `activity4/08-run-allowed-denied-tests.ps1` | Project-adapted allowed/denied SQL tests match their expected outcomes. |

Supply project-adapted tests under `db-access-control/<project>/tests/`: `runtime-allowed.sql`, `runtime-denied.sql`, `readonly-allowed.sql`, and `readonly-denied.sql`. Review each statement before `-Execute`; do not run the canteen project's SQL against another group's schema without adaptation and owner approval.

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/run-activity4.ps1 -Project group-01 -Execute
```

## Activity 5 — maintenance and monitoring

| Script | Expected result |
|---|---|
| `activity5/01-health-check.ps1` | PostgreSQL version, database size, object counts, and health indicators are captured. |
| `activity5/02-activity-check.ps1` | Active, idle, and idle-in-transaction sessions are summarized. |
| `activity5/03-role-check.ps1` | Activity 4 roles are checked. |
| `activity5/04-log-check.ps1` | Logging settings and explicitly configured logs are reviewed; inaccessible logs are BLOCKED. Sensitive log lines must not be copied to evidence. |
| `activity5/05-maintenance-check.ps1` | Before/after statistics plus standalone ANALYZE and VACUUM results are captured for the configured table. Never use VACUUM FULL. |
| `activity5/06-query-plan.ps1` | EXPLAIN output and, when explicitly authorized, EXPLAIN ANALYZE/BUFFERS are captured for one reviewed SELECT. ANALYZE executes the SELECT. |

Example table/query-plan invocation:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity5/05-maintenance-check.ps1 -Project group-01 -Table public.example_table -Execute
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity5/06-query-plan.ps1 -Project group-01 -SqlFile path\to\reviewed-select.sql -Execute
```

## Activity 6 — backup and recovery

| Script | Expected result |
|---|---|
| `activity6/01-check-backup-plan.ps1` | The project plan contains all required topics and no unresolved template markers. |
| `activity6/02-create-backup.ps1` | `pg_dump -Fc` creates a protected dump outside the repository and records non-secret metadata. Requires `-BackupDir` and `-Execute`. |
| `activity6/03-checksum.ps1` | SHA-256, file size, filename, and timestamp are appended to `checksums.txt`. Requires `-BackupFile` and `-Execute`. |
| `activity6/04-archive-list.ps1` | `pg_restore --list` output is saved to `archive-listing.txt`. Requires `-BackupFile` and `-Execute`. |
| `activity6/05-restore-test.ps1` | A new separate restore database is created and restored; warnings/errors and target are recorded. Requires `-BackupFile`, `-RestoreDbName`, `-Execute`, and `-Confirm`. |
| `activity6/06-verify-restore.ps1` | Configured objects, row counts, sequences, constraints, role/access tests, representative SELECT, and application connection are checked. |
| `activity6/07-recovery-simulation.ps1` | One disposable marker row is removed only from the restored test database; a fresh recovery database is restored and compared. Requires `-BackupFile`, `-RestoreDbName`, `-Execute`, and `-Confirm`. |
| `activity6/08-check-no-dumps-committed.ps1` | `git ls-files` contains no matching data-bearing dump or backup paths. |

Use the direct script for each action so its distinct parameters are unambiguous. Example only—replace with verified paths and database names:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity6/02-create-backup.ps1 -Project group-01 -BackupDir C:\protected\db-backups -Execute
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity6/03-checksum.ps1 -Project group-01 -BackupFile C:\protected\db-backups\verified.dump -Execute
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity6/04-archive-list.ps1 -Project group-01 -BackupFile C:\protected\db-backups\verified.dump -Execute
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity6/05-restore-test.ps1 -Project group-01 -BackupFile C:\protected\db-backups\verified.dump -RestoreDbName project_a6_restore_YYYYMMDD -Execute -Confirm
```

Run restore verification only after the restore succeeded:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity6/06-verify-restore.ps1 -Project group-01 -RestoreDbName project_a6_restore_YYYYMMDD -Execute -AllowedSqlFile path\to\allowed.sql -DeniedSqlFile path\to\denied.sql -SelectSqlFile path\to\select.sql
```

Run recovery only after the owner has confirmed the marker is disposable and included in the backup:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/activity6/07-recovery-simulation.ps1 -Project group-01 -BackupFile C:\protected\db-backups\verified.dump -RestoreDbName project_a6_restore_YYYYMMDD -RecoveryDbName project_a6_recovery_YYYYMMDD -RPO "owner-approved value" -Execute -Confirm
```

If the configured account cannot create a test database, request an instructor/setup account to create a **new empty restore-test database** with a distinct `*_a6_restore_YYYYMMDD` name and owner-approved maintenance account. Do not grant broad privileges just to make the script pass. Record the request and limitation.

## Status, evidence, and expected results

Each check prints one `PASS`, `FAIL`, `SKIP`, or `BLOCKED` line. The final activity summary counts all four. Exit status is zero only when there are no `FAIL` or `BLOCKED` results. A PASS means the stated automated check matched its configured expectation; manual comparison, owner approval, and unconfigured checks remain the team's responsibility.

Timestamped transcripts are written under:

```text
evidence/activity-4/<project>/<yyyy-mm-dd>/
evidence/activity-5/<project>/<yyyy-mm-dd>/
evidence/activity-6/<project>/<yyyy-mm-dd>/
```

Evidence directories may contain database names, role names, query plans, and non-secret operational output. Review and redact sensitive information before sharing or submitting. The scripts do not create fabricated evidence; no output file should be described as real until the command was actually run.

## Script development validation

Parse all PowerShell scripts without running database actions:

```powershell
$files = Get-ChildItem scripts/verify -Filter *.ps1 -Recurse
foreach ($file in $files) {
    $tokens = $null; $errors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors) | Out-Null
    if ($errors.Count) { $errors | ForEach-Object { Write-Error "$($file.FullName): $($_.Message)" } }
}
```

Then run the top-level preview command above. Do not treat syntax/dry-run validation as database evidence.
