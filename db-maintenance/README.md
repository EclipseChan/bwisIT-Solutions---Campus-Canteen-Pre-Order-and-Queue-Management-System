# Activity 5 — Database Maintenance and Monitoring

**Status: SCAFFOLD ONLY.** No other-group project inventory was available when this scaffold was created. `group-01`, `group-02`, and `group-03` are placeholders, not assertions about real groups or projects. Replace/resize these folders only after checking the class tracker. Do not use the bwisIT Solutions canteen database as a monitored project.

## Project inventory

| Placeholder folder | Group / project | Repository URL | Database / PostgreSQL | Account / application role | Overall status | Limitations | Last updated |
|---|---|---|---|---|---|---|---|
| [group-01](group-01/) | <UNKNOWN> | <UNKNOWN> | <UNKNOWN> | <UNKNOWN> | Not assessed | Project identity and connection details unavailable | 2026-11-04 (scaffold only) |
| [group-02](group-02/) | <UNKNOWN> | <UNKNOWN> | <UNKNOWN> | <UNKNOWN> | Not assessed | Project identity and connection details unavailable | 2026-11-04 (scaffold only) |
| [group-03](group-03/) | <UNKNOWN> | <UNKNOWN> | <UNKNOWN> | <UNKNOWN> | Not assessed | Project identity and connection details unavailable | 2026-11-04 (scaffold only) |

After an authorized review, set each project's overall status to `Healthy`, `Issues found`, or `Not reachable` and replace the scaffold date with the actual update date. `Not assessed` is not a health result.

## Folder contents

Each placeholder folder contains a health-check SQL template, log-review template, maintenance SQL template, query-plan SQL template, report template, evidence placeholders, and `BLOCKERS.md`. Evidence files are empty-of-results templates; replace their markers only with real, redacted output from an authorized target project.

Use the collection questions in [DATA_COLLECTION_CHECKLIST.md](../docs/activity-5-6/DATA_COLLECTION_CHECKLIST.md) before tailoring or running any SQL. Record the inventory in [PROJECT_INVENTORY_TEMPLATE.md](../docs/activity-5-6/PROJECT_INVENTORY_TEMPLATE.md). Never bypass Activity 4 privileges or claim health without evidence.

## Activity 5 execution sequence (after inventory and authorization)

1. Confirm project identity, database, server version, permitted account/application role, reachability, and owner authorization.
2. Read the target project's Activity 3 and Activity 4 documentation; tailor the templates to its actual schema.
3. Capture health checks and review available logs; record permissions and time range.
4. Review table statistics before selecting maintenance. Run `ANALYZE` and `VACUUM (VERBOSE, ANALYZE)` only when approved and appropriate; run `VACUUM` outside a transaction. Never use `VACUUM FULL` without instructor approval.
5. Capture a real application `SELECT` plan; use `EXPLAIN (ANALYZE, BUFFERS)` only for a safe `SELECT` in an approved test environment.
6. Interpret actual output, record limitations, prioritize recommendations, and send feedback to the owner.
7. Update the external `Activity 5 Log` tracker tab and the Activity 5 PDF section.

No command in this scaffold has been run against a database. See [docs/activity-5-6/SUBMISSION_CHECKLIST.md](../docs/activity-5-6/SUBMISSION_CHECKLIST.md) for all acceptance items.
