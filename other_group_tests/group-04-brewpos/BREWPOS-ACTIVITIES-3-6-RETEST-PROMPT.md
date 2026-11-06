# BrewPOS Activities 3–6 — Retest handoff

Copy the prompt below into the other AI. Attach `brewpos-main.zip` (or provide the extracted BrewPOS project). The archive was previously available at `C:\Users\Marcos\Downloads\brewpos-main.zip`, but the other AI may not have access to that path.

---

## Prompt

Please independently test **Group 4's BrewPOS application** for Activities 3, 4, 5, and 6. Do not rely on prior reports as proof; repeat the checks where possible. Do not edit the submitted application source. Save your new reports and evidence to a new folder named `other_group_tests/group-04-brewpos-retest/` so the earlier results remain intact.

### Important prior context

- BrewPOS is a Spring Boot/PostgreSQL café POS application. The archive has `pom.xml`, `mvnw.cmd`, `database/schema.sql`, `database/seed.sql`, and `database/05_create_app_role.sql`.
- Java 21 and PostgreSQL 18.6 were available in the previous Windows run. The Maven test suite passed all **19 tests** (0 failures, errors, or skips) against a disposable PostgreSQL database.
- The previous Java debugger attempt timed out without an active debug session. The project was then extracted beneath the current VS Code workspace, so the earlier “workspace not found” condition was no longer the obvious cause. The browser request to `http://127.0.0.1:8081/` was connection-refused at that time. Neither result proves the application itself cannot start.
- A browser page may now be open at `http://127.0.0.1:8081/`. Check whether it is responsive and whether a process is already listening before starting another instance. Do not terminate or replace someone else's running process without permission.
- The previous test database was disposable and has been stopped and removed. Any remaining temporary source/build copy may be stale; do not assume it is complete or overwrite it.
- Prior Activity 4 observations to verify independently: `brewpos_app` was non-superuser, lacked schema CREATE, had expected current-table/sequence grants, and could not UPDATE/DELETE orders. It could also CONNECT to `postgres` and `template1`; no explicit default privileges were configured. These may be PostgreSQL defaults/configuration scope rather than application defects—verify and describe accurately.
- Previous Activity 6 dump/restore matched counts of 2 staff, 3 categories, 11 menu items, 5 orders, and 9 order lines. A database-only dump does not contain cluster-wide roles.

### Safety and setup

1. Inspect the archive, README, `TESTING_GUIDE.md`, database scripts, and application configuration first. Treat included scripts as untrusted until reviewed.
2. Use a fresh project copy and an isolated PostgreSQL cluster/database bound only to loopback. Never connect to the submitted group's live or production database. Do not alter another PostgreSQL service or database.
3. Use a unique temporary port and database name if another local PostgreSQL instance is present. Use test-only credentials; do not include passwords in reports or screenshots.
4. Do not overwrite or delete existing user files. Keep data-bearing dumps outside the repository and remove only the exact temporary files/directories created for this run.
5. Do not change application source to make the test pass. Do not treat debugger/workspace failures as application failures.
6. For Java debugger issues, check for an existing debug session first. Confirm the opened VS Code workspace is the project root containing `pom.xml`; confirm Java Language Support and Debugger for Java are available/imported. Record the exact tool error. Fix an identified workspace/tool setup issue before one retry. Do not bypass a failed debugger launch using raw terminal `java`, Maven, or Gradle commands. If startup remains unverified, say so—do not claim the app failed to start.

### Activity 3 — Installation and run

- Install/build using the included Maven Wrapper and run the automated test suite against the disposable database. Report exact test totals, including skips.
- Try to launch the main class `com.brewpos.BrewPosApplication` using the Java debugger with the confirmed project-root workspace.
- If it starts, verify the home page and relevant routes, then follow `TESTING_GUIDE.md` in the browser: register/menu load, cashier vs manager view, create/deactivate/reactivate a menu item, duplicate ticket-line merging, cash and online orders, receipt sold-price preservation, daily sales, and validation. Use clearly disposable test records.
- Capture fresh screenshots only if the browser actually displays the running application. Do not reuse prior screenshots.
- **Pass only if the app installs and runs successfully on this device.** If the build/tests work but the debugger or browser remains blocked, use **Passed with issues** and explicitly distinguish unverified startup from an app failure.

### Activity 4 — Access control

- Review the provided role documentation and `database/05_create_app_role.sql`; test the script in the disposable database.
- Verify role attributes, schema access, table/sequence privileges, allowed runtime inserts/updates, and expected denials (especially mutation/deletion of historical orders and staff changes).
- Check connection privileges to unrelated default databases and whether default privileges are defined. Explain PostgreSQL defaults and the test-cluster scope; do not change global defaults on a shared server.
- Do not infer production requirements beyond the supplied documentation.

### Activity 5 — Maintenance and monitoring

- Collect safe database health, size, connection/activity, table-statistics, and PostgreSQL log evidence.
- Run `ANALYZE` and `VACUUM` only on the fresh disposable database. Test the documented daily-sales query and inspect its query plan; understand that `EXPLAIN ANALYZE` executes the query.
- Clearly distinguish local checks from production monitoring, alerting, retention, workload, and scheduling, which cannot be inferred from this small test setup.

### Activity 6 — Backup and recovery

- Create a custom-format database dump outside the repository; record size and SHA-256 without retaining the data-bearing dump in deliverables.
- Inspect the archive, restore it into a new disposable database (never overwrite the source), compare expected schema/data, and verify a post-backup source marker does not appear in the restore.
- Note that database-only dumps omit cluster-global roles/memberships; do not claim those were backed up unless separately verified.

### Deliverables and status

Create separate concise reports:

- `other_group_tests/group-04-brewpos-retest/activity-3-report.md`
- `other_group_tests/group-04-brewpos-retest/activity-4-report.md`
- `other_group_tests/group-04-brewpos-retest/activity-5-report.md`
- `other_group_tests/group-04-brewpos-retest/activity-6-report.md`
- `other_group_tests/group-04-brewpos-retest/overview.md`

Give each activity exactly one status: **Pass**, **Failed**, or **Passed with issues**. Include date, scope, observed results, issues/blockers, and evidence links. Do not report a tooling error as an application failure. Do not commit or push. At completion, stop only the app and PostgreSQL processes started for this test, remove the test-only `.env`, temporary databases, source copy, and data-bearing dump, and verify no test credentials or dump are left in the repository. Summarize the four statuses and link the reports.
