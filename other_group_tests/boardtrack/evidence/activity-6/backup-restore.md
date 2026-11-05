# Activity 6 evidence — backup and restore

- Source database: `boardtrack_test_20261105_2254` (disposable local database).
- Backup command: PostgreSQL `pg_dump -F c`; archive stored in the Windows temp directory, outside the repository and submission artifacts.
- Archive size: 29,139 bytes.
- SHA-256: `2021B539B52816164CE51CD03FA67E05F7EEF2849009478176740585BBB6B526`.
- `pg_restore --list`: succeeded.
- Restored to new database `boardtrack_restore_20261105_2254`; the source was not overwritten.

| Object/count | Source | Restore |
|---|---:|---:|
| Public base tables | 8 | 8 |
| Properties | 2 | 2 |
| Rooms | 6 | 6 |
| Tenants | 4 | 4 |
| Leases | 4 | 4 |
| Payments | 6 | 6 |
| Utility bills | 4 | 4 |
| Application users | 3 | 3 |

The temporary archive and disposable databases were removed after these checks. A database-only dump does not contain cluster-wide roles or memberships.
