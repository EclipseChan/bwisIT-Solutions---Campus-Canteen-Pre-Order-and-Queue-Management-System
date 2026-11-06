# Activity 4 — CampusSafe access-control report

**Status: Passed with issues**  
**Run date:** 2026-11-05  
**Environment:** Fresh disposable PostgreSQL 18.6 cluster; database `grp07_campussafedb`, bound to loopback.

## Results

| Check | Result |
|---|---|
| Role attributes | PASS — three group roles are `NOLOGIN`; three application login roles are non-superusers and lack `CREATEDB`/`CREATEROLE`. |
| Runtime allowed access | PASS — `campussafe_app` inserted a report and status-history row and updated the test report inside a transaction that was rolled back. |
| Runtime denied access | PASS — deletion of a hazard report and update of status-history were rejected. |
| Auditor restrictions | PASS — `campussafe_report` could read reports, could not read `app_user`, and could not update a report. |
| Backup restrictions | PASS — `campussafe_backup` could read user data and was denied report insertion. |
| Schema/default privileges | PASS with scope note — schema CREATE is denied; default ACLs exist for tables and sequences created by the role-script owner. Future objects created by another owner may not inherit those defaults. |
| Unrelated databases | ISSUE — `campussafe_app` connected to `postgres` and `template1` in the isolated cluster through default `PUBLIC CONNECT` privileges. The supplied script revokes `PUBLIC` privileges on the CampusSafe database only. |
| Password authentication | NOT TESTED — the disposable cluster used loopback `trust` authentication. The role script initially specifies a shared placeholder password and instructs the operator to replace it. |

**Review note:** The runtime role has `SELECT` on every current table, including `app_user.password_hash`, as documented by the supplied script. This is required for the implemented authentication flow but should be considered when reviewing database-account exposure.

These are checks of the supplied role design on an isolated cluster, not a production policy review. No global PostgreSQL privileges were changed.
