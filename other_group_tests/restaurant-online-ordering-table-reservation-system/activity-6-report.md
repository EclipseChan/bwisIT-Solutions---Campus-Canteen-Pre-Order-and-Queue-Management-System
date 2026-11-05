# Activity 6 — Backup and Recovery

**Status: Passed with issues**  
**Run date:** 2026-11-05  
**Test scope:** Back up the disposable test database, restore to a separate database, and compare schema/data and access behavior.

## Results

- Created a PostgreSQL custom-format backup using `pg_dump -Fc` as `rors_backup`, from the isolated disposable database. The archive was **50,951 bytes**, SHA-256 `4ED34AA06CD34F26D16B908B51B1ED0155DA5645BCCFCC11FE76FB9CF3356C40`. It was stored outside the repository, checked with `pg_restore --list`, used for restore verification, and then deleted.
- Restored with exit code 0 into the separate `grp_binarysisters_projectdb_restore_test` database. The verification found eight tables, four views, seven sequences, 19 indexes, two extensions, and the expected constraints.
- All eight source/restored row counts matched: customer 51, staff 10, menu_item 50, restaurant_table 20, orders 60, order_item 167, payment 56, reservation 50.
- The database-level ACL did **not** match. The source database has an explicit ACL; the restored database has `datacl IS NULL` (PostgreSQL defaults). A temporary login role without project-role memberships was denied CONNECT to the source but allowed CONNECT to the restored database. The probe role was dropped after the check.

The commands were run against the disposable cluster on `127.0.0.1:59959`:

```powershell
pg_dump -w -h 127.0.0.1 -p 59959 -U rors_backup -d grp_binarysisters_projectdb -Fc -f <temporary-backup-file>
pg_restore --list <temporary-backup-file>
pg_restore -w -h 127.0.0.1 -p 59959 -U postgres -d grp_binarysisters_projectdb_restore_test --exit-on-error <temporary-backup-file>
```

## Issues and recovery limitations

- **Restore security regression:** default database privileges allow an otherwise ungranted login role to connect to the restored database. The restore process should reapply the approved database-level CONNECT grants and repeat a denied-connect test before the restored database is made available. Table-level grants remained restricted; the probe test established CONNECT only, not access to application data.
- A database-only `pg_dump` does not include cluster-wide roles. This test restored within the same temporary cluster, where role definitions already existed; recovery to a fresh PostgreSQL cluster would require separately provisioning the approved roles and their credentials.
- The temporary cluster used `trust` authentication, so password authentication was not verified. No production backup, recovery point, retention, or recovery-time objective was assessed.
- The supplied restore-verification template contains a placeholder representative SELECT. Schema/object inventory and explicit source-versus-restored row-count comparisons were used for this verification instead.

## Evidence

- [Backup command result](activity6-evidence/backup-create.txt)
- [Backup metadata and checksum](activity6-evidence/backup-metadata.txt)
- [Archive manifest](activity6-evidence/archive-list.txt)
- [Restore command result](activity6-evidence/restore-run.txt)
- [Restore schema/data verification](activity6-evidence/restore-verification.txt)
- [Source/restored row-count comparison](activity6-evidence/row-count-comparison.txt)
- [Database ACL comparison](activity6-evidence/database-connect-comparison.txt)
- [Temporary-role source CONNECT check](activity6-evidence/probe-login-source.txt)
- [Temporary-role restored CONNECT check](activity6-evidence/probe-login-restore.txt)
