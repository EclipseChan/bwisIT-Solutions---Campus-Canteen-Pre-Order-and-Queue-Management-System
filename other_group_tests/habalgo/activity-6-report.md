Status: **Passed with limitation**
Date: 2026-11-05 (Asia/Manila, UTC+08:00)
Test scope: Backup and recovery of the user's disposable local PostgreSQL database `habalgo_test_20261105`. No production database was accessed.

## Checks and outcomes

- PostgreSQL 18.6 accepted authenticated local connections.
- `pg_dump -Fc` completed with exit code 0 and produced a 24,945-byte archive. `pg_restore --list` completed with exit code 0 and listed 71 archive entries.
- The archive restored with exit code 0 into a separate temporary database. The restored database had the same 8 tables, 17 indexes, and 58 constraints as the source.
- All 8 source tables contained 0 rows; the restored table row counts also matched at 0. Source row counts were unchanged after the test.
- The temporary restore database and backup archive were removed after verification. The source database was not modified.

## Limitation

The test database was empty, so this run verifies schema and empty-database recovery but does not demonstrate recovery of populated records. A populated disposable database is required to verify non-empty data recovery.

## Evidence

- [Backup and restore test evidence](./activity-6/evidence/backup-restore-test.txt)
