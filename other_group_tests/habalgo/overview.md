# HabalGo test overview

Tested 2026-11-05 (Asia/Manila, UTC+08:00). Activities 3–5 were retested against the user's local HabalGo app and PostgreSQL 18.6 database, `habalgo_test_20261105`. The `sample data.sql` seed loaded 10 drivers. The PHP app and all seven read endpoints worked; the UI's driver selector displayed all 10. Temporary runtime/read-only role checks against those drivers passed and were cleaned up. No production database was accessed, and the application source was not edited.

| Activity | Status | Report |
|---|---|---|
| 3 — Installation | Pass with limitation | [Activity 3 report](./activity-3-report.md) |
| 4 — Access control | Passed with issues | [Activity 4 report](./activity-4-report.md) |
| 5 — Maintenance and monitoring | Pass with limitation | [Activity 5 report](./activity-5-report.md) |
| 6 — Backup and recovery | Passed with limitation | [Activity 6 report](./activity-6-report.md) |

The database contains 10 seeded drivers; customer, vehicle, booking, payment, and rating tables remain empty. Activity 3 verified these driver options appear in the UI, but did not test populated booking or CRUD workflows. Activity 4 verified read-only/runtime behavior against seeded drivers using temporary roles; the checked-in role script was not applied, and application-level login/authorization remains unverified. Activity 5 verified database readiness, statistics, and active log-file configuration, but did not inspect log contents or run maintenance commands. Activity 6's backup/restore test occurred before seeding and verified recovery of the then-empty database only. No credentials, test roles, or backup archive were retained. Results are local-only and do not establish production behavior.

## Why activities have limitations

- **Activity 3 — Installation:** The PHP app and its read endpoints worked, but the available seed file adds drivers only. With no customers, vehicles, bookings, payments, or ratings, end-to-end flows and CRUD against existing records could not be exercised. There is also a setup mismatch: `.env.example` documents `DB_PASSWORD`, while `config.php` reads `DB_PASS`; the successful retest used the local PostgreSQL passfile, so it did not confirm that the documented `.env` setup works.
- **Activity 4 — Access control:** Database grants were checked using temporary roles and `SET ROLE` from an administrator session; direct authentication with the app/read-only role accounts was not tested. The checked-in role script targets `grp00_habalgodb`, not this disposable database, and contains fixed password literals, so it was deliberately not run unchanged. Its runtime role also grants writes on tables the inspected API only reads. The app itself showed no login or per-user authorization flow, so database role checks do not establish application-level access control.
- **Activity 5 — Maintenance and monitoring:** Read-only health, activity statistics, and logging configuration were checked, and an active log file was confirmed. Log contents and retention were not reviewed, and no `ANALYZE`, `VACUUM`, or query-plan checks were run. These checks therefore show local availability and configuration, not that alerts, log review, or maintenance procedures are effective.
- **Activity 6 — Backup and recovery:** The successful dump and restore happened before the 10 drivers were seeded, when all eight application tables were empty. Matching schema and zero-row counts confirm the archive could restore an empty database, but do not prove recovery of real records. The test archive and temporary restore database were removed afterward, so backup retention, storage, and recovery from a retained backup were not assessed.
