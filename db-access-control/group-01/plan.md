# Access-Control Plan — `group-01`

**TEMPLATE — replace with real project data only after checking the class tracker.** This label is provisional and is not a confirmed group identity. No roles, grants, databases, or results are supplied here.

| Field | Verified project value |
|---|---|
| Group/project/repository | `<UNKNOWN>` |
| Database / PostgreSQL version | `<UNKNOWN>` |
| Owner/contact and authorization date | `<UNKNOWN>` |
| Runtime/application role | `<UNKNOWN>` |
| Maintenance/read-only/login/group roles | `<UNKNOWN>` |
| Required access by role and object | `<COMPLETE FROM OWNER-APPROVED REQUIREMENTS>` |
| Prohibited access and reason | `<COMPLETE FROM OWNER-APPROVED REQUIREMENTS>` |
| Review and change window | `<UNKNOWN>` |

## Plan before any execution

1. Confirm this project is in scope and obtain owner/instructor authorization.
2. Read the target project's own schema, role documentation, and existing access-control scripts. Do not copy the canteen project's root SQL into this project.
3. Populate the role/grant templates using only confirmed facts and least privilege; have the owner review them.
4. Define specific allowed and denied tests and their expected privilege behavior before running any SQL.
5. Execute only approved statements using an approved account; capture real output and explain every adaptation.
6. Preserve the target's original database and document limitations, feedback, and tracker/PDF status.

## Template files

- `roles-and-privileges.sql.template` and `verification.sql.template` are comment-only authoring aids, not executable SQL.
- Keep evidence in `evidence/activity-4/<verified-project>/<date>/`; do not store passwords, tokens, connection strings, or `.env` values.
- Project identity, roles, plan, test outputs, tracker, PDF, and owner feedback remain **BLOCKED** until verified.

See the shared [Activity 4–6 blockers](../../docs/activity-4-5-6/BLOCKERS.md).
