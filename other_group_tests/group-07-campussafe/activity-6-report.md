# Activity 6 — CampusSafe backup and recovery report

**Status: Passed with issues**  
**Run date:** 2026-11-05  
**Environment:** Disposable PostgreSQL 18.6 cluster; source and restore databases were separate.

## Results

| Check | Result |
|---|---|
| Backup | PASS — `pg_dump -Fc` created a 47,731-byte custom-format backup using `campussafe_backup`. |
| Integrity metadata | PASS — SHA-256: `E4BC32E58415D9F47A04D1A742317B1435CDA068FF6FDB0B3F9CF5F86C2A7223`. |
| Archive and restore | PASS — the archive was inspected and restored into a new disposable database without errors. |
| Data verification | PASS — restored counts matched the source at backup time across all 9 tables: role 5, app_user 6, hazard_category 6, campus_location 10, hazard_report 17, assignment 12, report_status_history 61, maintenance_action 9, attachment 5. |
| Recovery simulation | PASS — a test marker inserted into the disposable source after backup was absent from the restored database. |

**Issues and limitations:** A database-only dump does not contain cluster-wide roles or memberships; reapplying the role script to another server was not tested. This demonstrates local dump/restore only. The proposed backup schedule, protected off-device storage, retention, production restore, and RPO/RTO were not independently verified.

The data-bearing dump was stored outside the repository and removed after verification. Only its size and checksum are retained here.
