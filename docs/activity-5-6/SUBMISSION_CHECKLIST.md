# Activities 5 and 6 Submission Checklist

**Status:** TEMPLATE / NOT SIGNED OFF. The paths below identify where real evidence or external deliverables must go; template files do not satisfy evidence requirements until populated from authorized real executions. `group-01`, `group-02`, and `group-03` are provisional folder names, not confirmed project identities.

## Activity 5

| Checklist item | File/evidence that will satisfy it | Current status |
|---|---|---|
| Every other group's project and database identified from the tracker. | `docs/activity-5-6/PROJECT_INVENTORY_TEMPLATE.md` populated from class tracker; tracker URL recorded. | Blocked: inventory/tracker unavailable |
| Roles/accounts match the Activity 4 access-control plan and Activity 3 user-roles documentation. | Per-project `db-maintenance/<group-XX>/report.md`; project Activity 4/user-role source references. | Blocked: project documentation unavailable |
| Health/activity checks include evidence and interpretation. | Per-project `health-check.sql`, `health-evidence.txt`, and `report.md`. | Template only |
| Available logs reviewed; findings grounded in evidence. | Per-project `log-review.md`, with source, time range, actual redacted findings/output, and limitations. | Template only |
| Maintenance commands appropriate, explained, and documented. | Per-project `maintenance.sql`, `maintenance-evidence.txt`, and `report.md`. | Template only |
| Query execution plan included and interpreted. | Per-project `query-plan.sql`, `query-plan-evidence.txt`, and `report.md`. | Template only |
| Recommendations prioritized and justified. | Per-project `report.md`; summary in `db-maintenance/README.md`. | Template only |
| Scripts and evidence are in `db-maintenance/`. | `db-maintenance/README.md` and the confirmed per-project folders. | Placeholder folders only |
| `Activity 5 Log` tracker tab updated. | External class Google Sheets `Activity 5 Log` tab, with the exact required columns documented in `docs/activity-5-6/TRACKER_LOG_TEMPLATE.md`. | Blocked: tracker unavailable |
| PDF progress documentation complete and secret-free. | Updated 17-page base PDF: `C:\Users\Marcos\Downloads\Progress Tracker - GRP 8 - Canteen System-1.pdf`, extended with Activity 5 sections; final link in tracker. | Not updated |
| No real credentials or secrets in submitted files. | `docs/activity-5-6/SECRET_SCAN_CHECKLIST.md`, final ZIP scan, PDF/tracker/screenshot reviews. | Pending |
| AI use disclosed and suggestions validated. | `docs/activity-5-6/AI_USAGE_DECLARATION.md`, completed and human-reviewed. | Draft |

## Activity 6

| Checklist item | File/evidence that will satisfy it | Current status |
|---|---|---|
| Backup plans identify database, storage, schedule, retention, RPO/RTO, and Activity 4 role recreation. | Per-project `db-backup-recovery/<group-XX>/backup-plan.md`. | Template only |
| Backup created and archive listing inspected. | Protected local dump outside Git; per-project `checksums.txt` and `archive-listing.txt`; summary in report/README. Never commit the dump. | Not run |
| Restore performed in a separate test database. | Per-project `restore-evidence.txt`, plus approved disposable restore database and command output. | Not run; setup permission unknown |
| Tables, records, constraints, access control, and representative query verified. | Per-project `restore-verify.sql`, `restore-evidence.txt`, and `report.md`. | Template only |
| Recovery simulation used only disposable test data. | Per-project `recovery-simulation.md`, with before/after/recovered output from disposable databases. | Template only |
| Original databases and backups preserved. | Per-project report and recovery record; confirm originals untouched and protected backup retained outside Git. | Not run |
| Evidence, limitations, and recommendations included. | Per-project `report.md` and `BLOCKERS.md`. | Template only |
| Backup files stored securely and not committed. | Protected local backup location; `.gitignore`; `git status`/tracked-file check; ZIP scan. | No dumps created |
| Scripts and evidence are in `db-backup-recovery/`. | `db-backup-recovery/README.md` and confirmed per-project folders; data-bearing dumps remain outside Git. | Placeholder folders only |
| `Activity 6 Log` tracker tab updated. | External class Google Sheets `Activity 6 Log` tab, with exact columns documented in `docs/activity-5-6/TRACKER_LOG_TEMPLATE.md`. | Blocked: tracker unavailable |
| PDF progress documentation complete and secret-free. | Updated 17-page base PDF extended with Activity 6 sections; final link in tracker. | Not updated |
| No secrets or real credentials submitted. | `docs/activity-5-6/SECRET_SCAN_CHECKLIST.md`, final ZIP scan, PDF/tracker/screenshot reviews. | Pending |
| AI use declared and commands validated. | Completed `docs/activity-5-6/AI_USAGE_DECLARATION.md`; actual commands and results reviewed by a human. | Draft; operations not run |

## Cross-cutting and P0

| Checklist item | File/evidence that will satisfy it | Current status |
|---|---|---|
| `.env` removed from submission ZIP. | Final ZIP at `C:\Users\Marcos\Documents\programming stuff\datamana\submission\bwisIT-Solutions---Campus-Canteen-Pre-Order-and-Queue-Management-System_activity5-6.zip`; name-only archive inspection. | Built; archive-name check passed. Full content scan and credential rotation still pending |
| Exposed credentials rotated. | `docs/activity-5-6/CREDENTIAL_ROTATION_CHECKLIST.md` with dates/results only. | Pending; do not submit as complete |
| `node_modules/`, `target/`, dumps, and backups excluded from ZIP. | Final ZIP name-only archive inspection; `SECRET_SCAN_CHECKLIST.md`. | Built; archive-name check passed |
| Repository, PDF, screenshots, tracker, and ZIP secret scan completed. | Completed scan/review records in `SECRET_SCAN_CHECKLIST.md`. | Pending |
| No data-bearing backup file tracked. | `git status`, `git ls-files` backup-pattern check, `.gitignore`. | No backup created |
| Meaningful commit history. | Repository commit history for implementation/evidence milestones. | Not applicable yet; no commits made |
| No other group's repository modified. | Repository/worktree scope and owner feedback records. | No other repository accessed |
| Feedback sent to every reachable owner with dates. | Per-project report and external feedback records; Activity 5/6 tracker rows. | Blocked: inventory/contacts unavailable |
| AI declaration lists tools, tasks, and validation. | `docs/activity-5-6/AI_USAGE_DECLARATION.md` plus Activity 5/6 PDF sections. | Draft |

## External deliverables also required by the specification

- [ ] Update the Google Sheets `Activity 5 Log` and `Activity 6 Log` tabs with one row per confirmed project.
- [ ] Extend the specified 17-page previous Activities 3/4 PDF (do not use the superseded 8-page PDF) with required Activity 5/6 sections, project tables, evidence, limitations, feedback, and AI declarations.
- [ ] Send feedback to reachable project owners and record dates.
- [ ] Recheck the final ZIP, PDF, tracker, screenshots, and repository after credential rotation.

The template's existence is not completion evidence. Fill a row only after the referenced action has actually been completed and verified.
