# Group 7 — CampusSafe test results

**Run date:** 2026-11-05  
**Source:** `grp07-campussafe-main.zip`  
**Environment:** Windows; PHP 8.2.12; disposable PostgreSQL 18.6 cluster on loopback.

| Activity | Status | Summary |
|---|---|---|
| [Activity 3](activity-3-report.md) | Passed with issues | App installed and ran; login and report submission passed. PHP/PostgreSQL extensions and executable path needed temporary manual configuration. |
| [Activity 4](activity-4-report.md) | Passed with issues | Role grants and expected allow/deny checks passed. The app role can connect to unrelated default databases; password authentication was not tested. |
| [Activity 5](activity-5-report.md) | Passed with issues | Health, integrity, maintenance, and query-plan checks completed on a small local dataset; production monitoring was not assessed. |
| [Activity 6](activity-6-report.md) | Passed with issues | Custom-format dump restored successfully with matching pre-recovery data; cluster-global role backup and production RPO/RTO were not assessed. |

Database checks used a fresh, disposable cluster. No existing PostgreSQL service/database or submitted application source was changed. A fresh screenshot was captured during the browser run.
