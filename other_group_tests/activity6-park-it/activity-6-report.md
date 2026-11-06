# Activity 6 — Park-It backup and recovery report

**Run date:** 2026-11-05  
**Environment:** Same disposable PostgreSQL 18.6 cluster. The backup and restore targets were separate test databases; no peer or original database was contacted or modified.

## Results

| Check | Result |
|---|---|
| Backup | PASS — `park_it_backup` created a custom-format dump of `park_it_a4a6_test`. |
| Integrity metadata | PASS — SHA-256 and file size recorded in [backup metadata](backup-metadata.txt). |
| Archive inspection | PASS — `pg_restore --list` returned a non-empty archive listing; see [archive listing](archive-listing.txt). |
| Restore | PASS — restored to the new `park_it_a4a6_restore` database; it contains the expected 5 public tables and seeded `Zone A` row. |
| Restore integrity | PASS — the restore had 5 public tables, the same 36 public constraints as the disposable source, the generated-ID sequence, and runtime/read-only privilege checks matching the test role design. Its sequence value was 2; the disposable source's value is now 3 because the later recovery marker consumed an ID after the backup. |
| Recovery simulation | PASS — after the backup, a marker was inserted only into the disposable source test database. A fresh restore from the earlier dump contained the original zone but not the later marker. The [comparison output](recovery-comparison.txt) records both states. |

PostgreSQL database dumps do not include cluster-wide role definitions. The test roles already existed in the isolated cluster, so recreating roles/memberships on a separate server was not tested; a project recovery plan must preserve those globals separately.

## Evidence

- [Backup metadata](backup-metadata.txt)
- [Archive listing](archive-listing.txt)
- [Restored database verification](restore-verification.txt)
- [Constraint and sequence verification](restore-constraints-sequence.txt)
- [Recovery comparison](recovery-comparison.txt)
- [Source-versus-restore schema/data comparison](source-versus-restore.txt)

The data-bearing dump was stored temporarily outside the repository at the path recorded in `backup-metadata.txt` and removed after verification. The repository contains only its non-secret metadata and archive listing.

**Limitations:** The archive has no Park-It backup plan, approved schedule/retention, protected storage destination, owner-approved RPO/RTO, or production restore authorization. This demonstrates a local backup/restore procedure only; it is not evidence that the project meets operational recovery objectives.
