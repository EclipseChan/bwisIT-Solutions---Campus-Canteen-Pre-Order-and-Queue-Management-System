# Park-It Activities 4–6 test notes

**Date:** 2026-11-05  
**Input archive:** `C:\Users\Marcos\Downloads\park-it-database-main.zip`  
**Authorization:** User confirmed Park-It as the target and approved testing in a disposable local PostgreSQL database.

## What went wrong / blockers found

1. **Mixed project materials:** The archive root README and `schema.sql` describe Park-It and `grp_parkitdb`, but the included Activity 4 and Activity 5 materials describe CampusSafe and `grp07_campussafedb`. The CampusSafe role SQL was not run against Park-It.
2. **No Park-It access-control plan:** The supplied Park-It server code uses the `parking_zone` table for its API routes, but the archive contains no Park-It role plan. For the isolated test only, roles were provisionally inferred from those routes; owners still need to approve the real policy.
3. **No Activity 6 plan/materials:** The archive contains no Park-It backup plan, backup/restore scripts, RPO/RTO, retention schedule, or protected backup destination.
4. **Setup filename mismatch:** The root README refers to `.env.example`, while the archive contains `.envexample`. The app was not started, so application configuration and browser behavior were not tested.
5. **Maintenance evidence is project-specific:** The supplied maintenance README is labeled Activity 4 and describes CampusSafe, not Park-It. Its findings were not reused as Park-It test evidence.

## What was tested

All database actions used a newly initialized PostgreSQL 18.6 cluster bound to `127.0.0.1:55439`, with a disposable Park-It test database populated from the archive's `schema.sql` and `seed.sql`. The already-running PostgreSQL Windows service was not used or changed.

- **Activity 4:** Built provisional runtime, read-only, and backup roles; verified allowed/denied access, role attributes, schema/table/sequence grants, and connection restrictions in the disposable cluster.
- **Activity 5:** Collected local health/session/logging information, ran ANALYZE and standalone VACUUM (ANALYZE) on the disposable table, and captured a query plan. The one-row dataset is not a representative workload.
- **Activity 6:** Created a custom-format backup using the test backup role, inspected its archive/checksum, restored to new disposable databases, and confirmed a post-backup marker was absent from the recovery restore. The dump did not include cluster-wide role definitions; no separate role/global backup was tested.

## Evidence and status

- [Activity 3 installation report](activity3-park-it/activity-3-report.md)
- [Activity 4 report](activity4-park-it/activity-4-report.md)
- [Activity 5 report](activity5-park-it/activity-5-report.md)
- [Activity 6 report](activity6-park-it/activity-6-report.md)

The local procedure checks completed, but these results are **not production or owner-approved sign-off**. Login connections used loopback-only `trust` authentication, so password authentication was not verified. No peer database was contacted. The temporary backup was kept outside the repository and removed after verification.

No new screenshots were captured: the work was performed with PostgreSQL command-line tools, and the archive's pre-existing screenshots were not treated as independently verified evidence.

## Reporting format for future applications

Each application will have a separate Markdown report for Activity 3 installation verification and Activities 4, 5, and 6, with a short shared overview for cross-activity issues and links to the reports.
