# Park It test overview

**Date:** 2026-11-05  
**Scope:** Local review of `Park it\park-it-database-final`; no production database was accessed.

| Activity | Status | Report |
|---|---|---|
| 3 — Installation | Passed with issues | [Activity 3 report](activity-3-report.md) |
| 4 — Access control | Passed with issues | [Activity 4 report](activity-4-report.md) |
| 5 — Maintenance and monitoring | Passed with issues | [Activity 5 report](activity-5-report.md) |
| 6 — Backup and recovery | Passed with issues | [Activity 6 report](activity-6-report.md) |

## Cross-activity issues

- The local PostgreSQL 18 service is running. Interactive password authentication succeeded, and the authorized new disposable database `parkit_test_20261105_1429` was created and loaded with the supplied schema. The existing `grp_parkitdb` was not accessed.
- Activity 3–5 were rerun: the local application rendered, seed initialization reported success, both roles signed in, anonymous monitoring access returned HTTP 401, and `ANALYZE`, targeted `VACUUM`, and a query plan succeeded. The existing recovery-marker zone prevented seed from creating its default Main Parking Lot; PostgreSQL log files were listed but their contents were not reviewed. See [rerun results](evidence/activity-3-5-rerun-results.md).
- The only authenticated database role tested so far was `postgres`, a superuser. No application-role least-privilege checks have been performed.
- A custom-format backup archive was restored to a separate disposable database. Reported source-versus-restore checks match on all five empty table counts, 36 constraints, and five sequence names. A marker inserted into the disposable source after backup was absent from the restore, as expected. Cluster-wide roles and production recovery objectives were not tested. See [Activity 6](activity-6-report.md).
- The temporary PHP copy passed syntax checks and its local web server rendered the login page using the disposable test database. It was stopped and removed after the rerun.
- The project config uses the `postgres` database account. No approved app-role matrix was supplied, and the schema contains no project role/grant setup. Runtime privilege behavior remains unverified.
- This testing repository already contains older `activity3-park-it`, `activity4-park-it`, `activity5-park-it`, and `activity6-park-it` reports. Those describe a different Park-It implementation/test environment and were not reused or overwritten.
- No credentials, data-bearing backup, or production evidence is included.
