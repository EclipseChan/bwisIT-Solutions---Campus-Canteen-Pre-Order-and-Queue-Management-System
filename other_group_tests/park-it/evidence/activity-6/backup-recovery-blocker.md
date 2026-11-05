# Activity 6 evidence — 2026-11-05

- The requested scope was a new disposable local database; the existing `grp_parkitdb` was not selected or contacted.
- Interactive PostgreSQL authentication subsequently succeeded. A new disposable database named `parkit_test_20261105_1429` was created and the supplied schema loaded successfully.
- The user supplied output from `pg_restore --list`: archive creation time `2026-11-05 14:36:39`, source database `parkit_test_20261105_1429`, custom format, 46 TOC entries, dumped from/by PostgreSQL/pg_dump 18.6, gzip compression, dump version `1.16-0`. The shown TOC includes the `parking_zone`, `payment`, `staff_user`, and `transaction` tables and related sequences. The excerpt ends before confirming the remaining `vehicle` entry.
- The user reports running `pg_restore` against a separate new disposable database and seeing no errors. The destination was subsequently confirmed as `parkit_test_restore_20261105_1437`.
- Follow-up queries on both `parkit_test_20261105_1429` and `parkit_test_restore_20261105_1437` report 0 rows for each of the five application tables, 36 public constraints, and the same five public sequence names.
- The user reports inserting the recovery marker into the disposable source after backup, then querying the restored database and receiving `0 rows`, as expected for a restore from the earlier backup. This is a user-reported recovery-point simulation; raw source-insert output was not supplied.
- The data-bearing backup is kept outside the repository. Its size and SHA-256 checksum have not yet been recorded here.

The reported table counts and object inventory support schema/data restore verification for this empty database. The recovery-point simulation also passed based on the reported absent marker. The database contained no application rows at backup time; cluster-wide roles and production recovery objectives were not tested.
