**Status: Passed with issues** | **Date:** 2026-11-05 | **Test scope:** Custom-format backup, restore, schema/data comparison, and recovery-point simulation using disposable databases `parkit_test_20261105_1429` and `parkit_test_restore_20261105_1437`; no existing database was used.

# Activity 6 — Backup and recovery

## Outcome

The custom-format archive listing identifies `parkit_test_20261105_1429`, PostgreSQL 18.6, and the application tables. The user reports that restore into `parkit_test_restore_20261105_1437` completed without errors. Follow-up queries on both databases show matching table row counts, 36 public constraints, and the same five public sequence names. After the backup and restore, a uniquely named marker was inserted into the disposable source only; a query against the restored database returned 0 matching rows as expected.

- A custom-format archive was created; its reported TOC contains 46 entries and identifies the source database and PostgreSQL/pg_dump version as 18.6.
- The user reports that restore into the separate new database completed without errors.
- Independently reported source/restore query results match: all five application tables have zero rows in both databases, each has 36 public constraints, and both have the same five public sequences.
- Recovery-point simulation passed: the post-backup source marker was absent from the restore made from the earlier archive.
- The data-bearing archive is outside the repository. Its file size and SHA-256 checksum have not yet been recorded in this report.
- No data-bearing backup was written to the repository.

## Issues and limitations

The reported table/data counts and constraint/sequence inventory match across the two disposable databases, and the post-backup marker was absent from the earlier restore as expected. The database was empty apart from the recovery marker, and cluster-wide roles were not captured or tested. The backup size, SHA-256 checksum, and production recovery objectives were not recorded. No production recovery is claimed.

**Evidence:** [Backup archive, restore, and comparison results](evidence/activity-6/backup-recovery-blocker.md)  
**Environment:** Disposable local database only; the existing `grp_parkitdb` and production were not accessed.
