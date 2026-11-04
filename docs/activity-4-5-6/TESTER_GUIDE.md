# Activities 4–6 Tester Guide

**Status: TEMPLATE — no other-group project has been identified or tested.** This guide describes a safe workflow; it is not operational evidence.

## 1. Scope and prerequisites

- Use only other groups' Activity 3 projects confirmed by the class tracker and authorized by the owner/instructor. This repository and `canteen_db` belong to bwisIT Solutions and are not target projects.
- `group-01`, `group-02`, and `group-03` are provisional folder labels only. Replace/resize folders only after checking the authoritative inventory.
- Required before any live operation: confirmed project/repository/database identity, PostgreSQL version, reachability, owner contact/authorization, approved account and role, target schema documentation, and relevant activity-specific permissions.
- Required local tools: Windows PowerShell 5.1+ or PowerShell 7+ (`powershell` or `pwsh`), PostgreSQL client tools (`psql`, `pg_dump`, `pg_restore`), Git, and an authorized local credential source. Never pass passwords on a command line or store secrets in config/evidence.
- Copy `config/projects.example.json` to the ignored `config/projects.local.json`. Populate only confirmed, non-secret facts. Do not copy `.env` values into the project configuration.

## 2. Safe setup and preview

1. Review [current blockers](BLOCKERS.md), [credential rotation](CREDENTIAL_ROTATION_CHECKLIST.md), [evidence handling](EVIDENCE_GUIDE.md), and the [submission checklist](../activity-5-6/SUBMISSION_CHECKLIST.md).
2. Confirm `config/projects.local.json` names the verified project using the exact project key. Do not treat a provisional folder label as project identity.
3. Preview the configured checks:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/verify/run-all.ps1 -Project <verified-project-key> -DryRun
   ```

   Expected result: previews/status lines and a summary; no database, backup, restore, or recovery action. Missing or unverified facts must remain `BLOCKED`/`SKIP`, not `PASS`.
4. Save the actual preview output only if useful, label it `DRY RUN — NOT OPERATIONAL EVIDENCE`, and redact before sharing.
5. Execute only the selected activity after written authorization, configuration review, SQL/script review, and evidence-directory approval. The runners default to safe behavior; use `-Execute` only for authorized operations. Activity 6 restore and recovery additionally require `-Confirm` and distinct disposable databases.

## 3. Activity 4 — access control

1. Read the target project's source, database-role design, schema, and approved access requirements.
2. Complete `db-access-control/<provisional-project>/plan.md`; verify role identities and least-privilege intent with the owner before drafting SQL.
3. Review the project-specific SQL templates. They are comment-only templates, not executable SQL. Do not copy the canteen project's root SQL into another project's database.
4. Run previews for the eight Activity 4 checks listed in [expected results](EXPECTED_RESULTS.md). Only use `-Execute` for read-only inspection or explicitly reviewed allowed/denied test SQL with authorization.
5. Record actual role, membership, database/schema/table/sequence/default privilege, PUBLIC, and allowed/denied outcomes. Document each difference; do not infer a pass from a plan or preview.
6. Complete the Activity 4 tracker tab, PDF section, and dated owner feedback after evidence review.

## 4. Activity 5 — maintenance and monitoring

1. Review the project's actual schema, maintenance window, authorized maintenance account, logging policy, and query workload with the owner.
2. Tailor `db-maintenance/<project>/health-check.sql`, `maintenance.sql`, and `query-plan.sql` to the verified schema. Inspect every statement before running it.
3. Run only authorized health/activity/role/log inspections. If logs are unavailable or logging changes are not approved, record `BLOCKED`; do not enable or alter logging unilaterally.
4. Run `ANALYZE` or standalone `VACUUM (VERBOSE, ANALYZE)` only when approved and appropriate; never put `VACUUM` in a transaction. Do not run `VACUUM FULL` without explicit approval.
5. Use `EXPLAIN (ANALYZE, BUFFERS)` only for a safe, reviewed `SELECT` in an approved test environment; `ANALYZE` executes the query.
6. Save real output, note time range/limitations, complete the report and Activity 5 tracker/PDF, and send dated feedback to the owner.

## 5. Activity 6 — backup and recovery

1. Review the owner-approved backup plan, account, storage location, retention, recovery objectives, and permission to create disposable databases.
2. Set `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, and an absolute `BACKUP_DIR` outside the repository in a protected local environment. Use the approved credential store; never put credentials in scripts or command history.
3. Execute one platform's backup script only after authorization. Confirm the dump is a custom-format archive in protected storage outside Git and any submission ZIP.
4. Record the real file name, size, SHA-256, server/client versions, command, date/time, account, and any warnings. `checksums.txt` and `archive-listing.txt` are templates until filled with real output.
5. Inspect `pg_restore --list`. Restore only into a new, empty, uniquely named disposable database. Do not overwrite or alter the original database or backup.
6. Verify objects, data, constraints, sequences, roles/memberships, privileges, and representative allowed/denied behavior. Simulate recovery only with a disposable marker in the restored test database, then compare the fresh recovery database to the expected state.
7. Preserve the original and initial backup. Complete the Activity 6 report, tracker/PDF, and dated owner feedback.

## 6. Evidence capture

- Follow [EVIDENCE_GUIDE.md](EVIDENCE_GUIDE.md). Store text output under `evidence/activity-4`, `evidence/activity-5`, or `evidence/activity-6`, organized by verified project and date.
- Record account, application/database role, database, date/time and timezone, exact command/action, result/status, and limitations.
- Redact passwords, tokens, connection strings, sensitive personal data, and log/query literals. Do not save raw secrets or data-bearing dumps in the repository or submission.
- Templates, dry-run output, and a successful command exit alone are not proof that the requirement passed.

## 7. Troubleshooting and limitations

| Condition | Safe response |
|---|---|
| Project identity, tracker, or authorization is missing | Stop; leave the project `BLOCKED`; request the authoritative inventory/authorization. |
| Configuration is incomplete | Use only a dry run; fill missing values from an authoritative non-secret source. |
| PostgreSQL client tools are missing | Install/use the approved client tool version; do not substitute a different target or fabricate output. |
| Permission denied, target unreachable, or logs unavailable | Preserve the error safely and record the precise limitation; do not elevate privileges or change logging without approval. |
| Restore/setup permission is unknown | Do not create a database or restore; request an approved disposable-database account. |
| A command would affect the original database or create a dump inside the repository | Stop and correct the target/storage plan before proceeding. |

The project inventory, tracker/PDF links, group number, credential rotation, restore setup permission, and logging-change permission remain unresolved in [BLOCKERS.md](BLOCKERS.md). No live target operation is asserted here.
