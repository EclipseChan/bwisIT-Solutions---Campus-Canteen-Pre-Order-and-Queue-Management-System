# Activity 6 — Database Backup, Restoration, and Recovery

**Status: SCAFFOLD ONLY.** The other-group inventory was not available. `group-01`, `group-02`, and `group-03` are provisional organizational placeholders, not real project identities. Replace/resize these folders only after checking the class tracker. This activity must not use the bwisIT Solutions canteen database as a target.

## Project inventory and backup status

| Placeholder folder | Group / project | Repository URL | Database | Backup name / size / SHA256 | Method and time | Restore test | Access control after restore | Recovery simulation | Proposed RPO/RTO | Evidence | Feedback status/date |
|---|---|---|---|---|---|---|---|---|---|---|---|
| [group-01](group-01/) | <UNKNOWN> | <UNKNOWN> | <UNKNOWN> | <NOT_CREATED> | <NOT_RUN> | <NOT_RUN> | <NOT_RUN> | <NOT_RUN> | <TO_BE_JUSTIFIED> | Placeholder only | <UNKNOWN> |
| [group-02](group-02/) | <UNKNOWN> | <UNKNOWN> | <UNKNOWN> | <NOT_CREATED> | <NOT_RUN> | <NOT_RUN> | <NOT_RUN> | <NOT_RUN> | <TO_BE_JUSTIFIED> | Placeholder only | <UNKNOWN> |
| [group-03](group-03/) | <UNKNOWN> | <UNKNOWN> | <UNKNOWN> | <NOT_CREATED> | <NOT_RUN> | <NOT_RUN> | <NOT_RUN> | <NOT_RUN> | <TO_BE_JUSTIFIED> | Placeholder only | <UNKNOWN> |

## Contents and safety

Each folder contains a backup plan, PowerShell and Bash backup scripts, checksum/archive-listing/restore evidence templates, verification SQL, recovery simulation, report, and `BLOCKERS.md`. Evidence files are templates until populated with real, reviewed output.

The scripts require non-secret PostgreSQL environment variables and a `BACKUP_DIR` outside this repository. They do not set or print passwords; use an approved local `.pgpass` or secure interactive prompt. Dumps contain data and must remain in a protected local location outside Git and outside the submission ZIP. Commit only scripts, plans, checksums, archive listings, and redacted verification evidence.

## Activity 6 sequence (after inventory and authorization)

1. Complete [PROJECT_INVENTORY_TEMPLATE.md](../docs/activity-5-6/PROJECT_INVENTORY_TEMPLATE.md) and [DATA_COLLECTION_CHECKLIST.md](../docs/activity-5-6/DATA_COLLECTION_CHECKLIST.md); confirm owner/instructor authorization.
2. Complete each `backup-plan.md`, including storage, access, schedule, retention, justified RPO/RTO, and Activity 4 role recreation.
3. Configure `PGHOST`, `PGPORT`, `PGDATABASE`, `PGUSER`, and `BACKUP_DIR` locally. Keep credentials out of command history; use approved local credential handling.
4. Run exactly one platform's backup script. Record the generated file name, size, date/time, checksum, PostgreSQL version, and any errors without copying secrets.
5. Run `pg_restore --list` against the protected dump and save actual output to that project's `archive-listing.txt`.
6. Have an instructor-approved account create a separate empty test database. Restore there, never over the original. Recreate/verify Activity 4 roles and privileges as documented.
7. Run the tailored `restore-verify.sql`; record actual object, data, constraint, sequence, role, privilege, permitted/denied-operation, and representative-query results.
8. Perform any recovery simulation only on disposable restored/recovery databases and disposable test data. Preserve both the original and initial backup.
9. Complete the report, update the external `Activity 6 Log` tracker and PDF, send feedback to the owner, and run final secret/artifact scans.

No backup or restore command has been run. Restore-database creation and logging permissions are currently unknown; document them as blockers until confirmed. See [docs/activity-5-6/SUBMISSION_CHECKLIST.md](../docs/activity-5-6/SUBMISSION_CHECKLIST.md).
