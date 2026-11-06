# Activity 6 — Backup and recovery

**Status: Pass**  
**Date:** 2026-11-05 (Asia/Manila, UTC+08:00)  
**Scope:** Created a PostgreSQL custom-format dump of the disposable BoardTrack test database outside the repository, restored it into a separate new disposable database, and compared schema/data counts. The source database was not overwritten; no production database was accessed.

## Results

| Check | Result |
|---|---|
| Backup | `pg_dump -F c` completed; archive size 29,139 bytes. |
| Archive integrity | `pg_restore --list` succeeded. |
| Restore | Restored into `boardtrack_restore_20261105_2254`, a separate database. |
| Verification | Source and restore each contained 8 public base tables, 2 properties, 6 rooms, 4 tenants, 4 leases, 6 payments, 4 utility bills, and 3 application users. |
| Cleanup | The temporary archive was stored outside the repository and removed after verification. |

The database-only dump does not contain cluster-wide PostgreSQL roles or memberships. Those were not part of this restore test; separate role backup/recovery would need an authorized `pg_dumpall --globals-only` procedure.

## Issues and limitations

- Recovery was verified only for this disposable seeded database and does not prove a production backup schedule, off-host retention, or disaster-recovery readiness.
- The archive and restored database were temporary test data and were removed after verification.

## Evidence

- [Backup and restore verification](evidence/activity-6/backup-restore.md)
