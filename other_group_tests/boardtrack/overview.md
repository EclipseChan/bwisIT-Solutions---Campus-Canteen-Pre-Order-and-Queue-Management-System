# BoardTrack — Activity 3–6 test overview

Tested 2026-11-05 (Asia/Manila, UTC+08:00) against the user-supplied local BoardTrack project using a temporary application copy and disposable PostgreSQL databases. Activity 4 was retested with the app's PostgreSQL connection explicitly running as `postgres`. No production service was accessed and no application source files were changed.

| Activity | Status | Report |
|---|---|---|
| 3 — Installation | Pass | [Activity 3 report](activity-3-report.md) |
| 4 — Access control | Passed with issues | [Activity 4 report](activity-4-report.md) |
| 5 — Maintenance and monitoring | Passed with issues | [Activity 5 report](activity-5-report.md) |
| 6 — Backup and recovery | Pass | [Activity 6 report](activity-6-report.md) |

## Cross-activity issues

- The project README identifies the application as BoardTrack but provides no group number; no official class-tracker confirmation was available.
- **Activity 4 — Access control:** Application-level role boundaries and tenant row filtering worked for the tested requests, including when the app connected as `postgres`. However, `postgres` has superuser privileges, unrestricted CRUD, and `BYPASSRLS`; tenant isolation is enforced only by application queries, and no database row-level security was enabled. A compromised app or exposed DB credential could bypass those app checks. Use and verify a restricted runtime database login before production. Admin allowed writes were not exercised; denied writes were checked without modifying data.
- **Activity 5 — Maintenance and monitoring:** Local health, `ANALYZE`, and a read-only query plan were checked on a small seeded test database. PostgreSQL log contents, retention, alerting, monitoring dashboards, and production maintenance were not assessed; query timing is not representative of production load.
- **Activity 6 — Backup and recovery:** The disposable seeded database restored with matching schema and row counts. The database-only archive did not include cluster-wide roles or memberships, and the temporary archive was removed after verification. Production backup retention and disaster recovery were not assessed.
- **Test scope:** Results are from local disposable databases only. They do not confirm production behavior. The provided project README does not state a group number, and no official class-tracker confirmation was available.

All findings are local/disposable test results only; they do not establish production behavior.
