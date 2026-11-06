# Activity 6 — BrewPOS backup and recovery report

**Status: Passed with issues**  
**Run date:** 2026-11-05  
**Environment:** Disposable PostgreSQL 18.6 cluster; separate source and recovery databases.

## Results from earlier disposable-cluster checks

| Check | Result |
|---|---|
| Backup creation | PASS — `pg_dump` created a non-empty custom-format backup using the `brewpos_app` role. |
| Archive inspection | PASS — `pg_restore --list` returned the expected schema, table, sequence, and data entries. |
| Restore | PASS — backup restored into a new disposable database without errors. |
| Data verification | PASS — restored counts matched the source: 2 staff, 3 categories, 11 menu items, 5 orders, and 9 order lines. |
| Recovery simulation | PASS — a category inserted into the disposable source after backup was absent from the restored database. |
| Integrity evidence | PASS — archive size was 16,921 bytes; SHA-256 was `FBEAA26BB8EC3082831C974466DE242C31B21B92360CBEDA22360BF0767CA5F0`. The archive itself was removed after testing. |

**Issues and limitations:** This verifies a local dump-and-restore procedure only. PostgreSQL database dumps do not include cluster-wide role definitions or memberships; preserving those requires a separate globals backup. No automated schedule, off-device protected storage, retention policy, production restore, or owner-approved RPO/RTO was tested.

The backup and both databases were temporary and isolated. No dump containing the sample data was retained in the repository.

## Independent verification on the working copy — 2026-11-05

A custom-format dump was created from the running app's test database using the application role, listed successfully, and restored into a separate temporary database. The source database was not overwritten or changed by the backup/restore. The restored database was removed after verification; the dump was deleted after metadata capture.

| Check | Result |
|---|---|
| Dump and archive inspection | PASS — 16,991 bytes; SHA-256 `2592C99194EC43262AD0E40D116C52C4DEB707967491105ADA78F375E6EE8EAC`; 49 TOC entries. |
| Restore | PASS — `pg_restore` exited 0 into a newly created database. |
| Source/restore comparison | PASS — counts and total sales matched: 2 staff, 4 categories, 12 menu items, 7 orders, 12 order lines, 1811.00 total sales. |
| Restored application privileges | PASS — the app role read the restored snapshot; order-ticket UPDATE and staff INSERT remained denied, while menu-item UPDATE remained granted. |
| Cleanup | PASS — the temporary restore database and dump file were removed. |

The post-backup marker test in the earlier report was not repeated against the active working copy because it would require mutating the source database. This retest also does not verify automated scheduling, retention, encryption, off-device storage, or cluster-global role backup. Overall status remains **Passed with issues**.
