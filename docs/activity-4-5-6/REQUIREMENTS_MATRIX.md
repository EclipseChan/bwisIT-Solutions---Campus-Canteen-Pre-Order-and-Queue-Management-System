# COMP018 Activities 4, 5, and 6 Requirements Matrix

**Purpose:** Trace each required task, deliverable, rubric criterion, tracker field, PDF section, and submission-checklist item to a check and evidence target.

**Scope:** Activities 4–6 target every other group's Activity 3 project listed in the class tracker, not this group's canteen application. `group-01`, `group-02`, and `group-03` are provisional folder names only; they do not establish which groups or projects are in scope.

**Status meanings:** `Implemented` = the stated check/evidence is completed and present; `Template` = a reusable scaffold exists but is not real project evidence; `Manual only` = a human/external action or artifact is required; `Blocked` = actual execution or completion depends on missing inventory, authorization, real output, or external access. These statuses describe current repository state, not the expected result.

## Activity 4

### Part A — Database setup and assessment

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 4 | A | Identify every other group's Activity 3 project from the class tracker; exclude this group's own project. | Manually reconcile tracker rows against inventory; verify each row is another group's project. | Every in-scope other-group project is listed once; no own project is included. | `docs/activity-4-5-6/evidence/activity4-project-inventory.md` | Blocked |
| 4 | A | Clone each other group's repository and record its URL and branch/tag. | Manually compare repository checkout metadata with the tracker. | A checkout/source reference exists for each inventoried project and identifies the repository and revision. | `docs/activity-4-5-6/evidence/activity4-project-inventory.md` | Blocked |
| 4 | A | Review each project README, PDF progress documentation, user-roles documentation, and database documentation. | Manually record each source reviewed and extract setup/access facts. | All four source types are reviewed for each project, or each unavailable source is recorded as a blocker. | `docs/activity-4-5-6/evidence/activity4-source-review.md` | Blocked |
| 4 | A | Set up every other group's application and its own separate PostgreSQL database using documented procedures. | Manually execute the documented setup in an authorized local/instructor-approved environment and verify the database/application. | Each project has a separate initialized database and a recorded setup outcome; failures have a blocker rather than a success claim. | `docs/activity-4-5-6/evidence/activity4-setup-results.md` | Blocked |
| 4 | A | Identify database name, schemas, tables, sequences, views, and other objects used by each application. | Manually compare project database documentation/migrations with catalog queries on the initialized database. | Per-project object inventory names the database and all relevant object types, with discrepancies recorded. | `docs/activity-4-5-6/evidence/activity4-object-inventory.md` | Blocked |
| 4 | A | Review application database operations and Activity 3 user-role documentation to determine required access. | Manually map documented application operations and user roles to database operations. | Each required account/component has a justified access requirement based on project documentation. | `docs/activity-4-5-6/evidence/activity4-access-control-plans.md` | Blocked |
| 4 | A | Prepare a per-project database access-control plan before creating accounts or assigning privileges. | Manually review the dated plan against project requirements before execution evidence. | A plan exists for each project before role/grant implementation. | `docs/activity-4-5-6/evidence/activity4-access-control-plans.md` | Blocked |
| 4 | A | Document missing setup instructions and database inconsistencies and report them to project owners. | Manually compare observed setup with project documentation and retain dated feedback record. | Each issue has evidence, description, owner feedback reference/date, or an explicit no-issue review record. | `docs/activity-4-5-6/evidence/activity4-issues-feedback.md` | Blocked |
| 4 | A | If setup fails, record the blocker, report it to owners, and continue with other projects. | Manually record failure cause and owner notification, then inspect remaining inventory rows. | Failed project is marked blocked with feedback; other reachable projects continue independently. | `docs/activity-4-5-6/evidence/activity4-blockers.md` | Blocked |

### Part B — Users, group roles, and privileges

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 4 | B | Determine each project's required database access types from its own application needs and Activity 3 user roles. | Manually review the access-control plan against source documentation and application operations. | Every required responsibility is represented; role examples are applied only where appropriate. | `docs/activity-4-5-6/evidence/activity4-access-control-plans.md` | Blocked |
| 4 | B | Identify login accounts and group roles and document their responsibilities and intended privileges. | Manually compare role design with catalog membership/privilege evidence. | The plan identifies each login/group role, responsibility, and least-privilege permissions. | `docs/activity-4-5-6/evidence/activity4-role-design.md` | Blocked |
| 4 | B | Distinguish database administrator, runtime, read-only, data-entry, and auditor needs where applicable. | Manually map each needed responsibility to its account/role; do not require unused example roles. | Each applicable role type has a justified permission set; inapplicable examples are noted. | `docs/activity-4-5-6/evidence/activity4-role-design.md` | Blocked |
| 4 | B | Verify that role names are backed by actual PostgreSQL privileges, not labels alone. | Inspect effective role membership/privileges and run applicable allowed/denied tests. | Effective permissions match the documented responsibility. | `docs/activity-4-5-6/evidence/activity4-privilege-verification.md` | Blocked |

### Part C — Role and privilege implementation

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 4 | C | Create group roles that represent common privileges, generally with `NOLOGIN`. | Inspect role attributes in PostgreSQL and compare with role plan. | Group roles have `NOLOGIN` unless a documented, justified exception applies. | `docs/activity-4-5-6/evidence/activity4-role-verification.txt` | Blocked |
| 4 | C | Create individual login roles for accounts that authenticate to PostgreSQL. | Inspect PostgreSQL role attributes and match login roles to the plan. | Each required authenticating account exists as a login role; no undocumented login account is introduced. | `docs/activity-4-5-6/evidence/activity4-role-verification.txt` | Blocked |
| 4 | C | Assign login roles to appropriate group roles. | Query role memberships and compare to planned role mapping. | Every membership matches the plan; unjustified memberships are absent. | `docs/activity-4-5-6/evidence/activity4-membership-verification.txt` | Blocked |
| 4 | C | Grant only necessary database-level access. | Inspect database ACLs/effective connection privileges. | Required accounts can connect to their database; unrelated or unjustified access is denied. | `docs/activity-4-5-6/evidence/activity4-database-privileges.txt` | Blocked |
| 4 | C | Grant required schema privileges. | Inspect schema ACLs/effective schema privileges. | Required accounts have only required schema access; schema `USAGE` is not mistaken for table access. | `docs/activity-4-5-6/evidence/activity4-schema-privileges.txt` | Blocked |
| 4 | C | Configure needed table, sequence, view, and other object privileges. | Inspect object ACLs and test operations requiring tables/sequences/views. | Each required object operation works and unneeded operations are denied. | `docs/activity-4-5-6/evidence/activity4-object-privileges.txt` | Blocked |
| 4 | C | Review default privileges for future objects where necessary. | Inspect default-privilege settings and verify intended behavior for newly created objects where applicable. | Future-object grants are documented and match least privilege; no assumption that existing grants apply automatically. | `docs/activity-4-5-6/evidence/activity4-default-privileges.txt` | Blocked |
| 4 | C | Apply database-level grants in the appropriate administrative database and schema/object grants in the target database. | Manually review execution database/context for each grants script and its output. | Grants execute in the correct scope and target database. | `docs/activity-4-5-6/evidence/activity4-grant-execution.md` | Blocked |
| 4 | C | Avoid unjustified `SUPERUSER`, `CREATEDB`, `CREATEROLE`, and other elevated attributes. | Inspect role attributes and compare every elevated attribute with documented administrative justification. | No unnecessary elevated attribute is present; any exception is specifically justified and limited. | `docs/activity-4-5-6/evidence/activity4-role-verification.txt` | Blocked |
| 4 | C | Keep actual passwords out of repositories, tracker, and PDF; use secure local credential handling. | Review scripts/docs/tracker/PDF and secret-scan results; inspect local credential procedure without recording values. | No credential value is committed or submitted; scripts use safe placeholders/local credential handling. | `docs/activity-4-5-6/evidence/activity4-secret-scan.md` | Template |

### Part D — Least privilege

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 4 | D | Do not use a PostgreSQL superuser for normal application operations. | Inspect application database configuration and role attributes. | Runtime account is not a superuser and application uses that restricted account. | `docs/activity-4-5-6/evidence/activity4-least-privilege.md` | Blocked |
| 4 | D | Prevent application accounts from accessing unrelated application databases through broad grants. | Test database connection denial and inspect direct/inherited/PUBLIC privileges. | Unrelated database access is denied through the applicable access paths. | `docs/activity-4-5-6/evidence/activity4-privilege-verification.md` | Blocked |
| 4 | D | Prevent users from modifying tables or records outside assigned responsibilities. | Test representative forbidden writes and inspect direct grants, inherited roles, ownership, and PUBLIC access. | Out-of-scope modifications are denied. | `docs/activity-4-5-6/evidence/activity4-privilege-verification.md` | Blocked |
| 4 | D | Ensure read-only accounts cannot insert, update, or delete records. | Attempt read-only write operations using the documented read-only login. | Read operations are allowed as intended; write operations are denied. | `docs/activity-4-5-6/evidence/activity4-privilege-verification.md` | Blocked |
| 4 | D | Avoid unnecessary database-creation and role-management privileges. | Inspect `CREATEDB`, `CREATEROLE`, and effective role attributes for each account. | Non-administrative accounts have no unjustified database/role-management privileges. | `docs/activity-4-5-6/evidence/activity4-role-verification.txt` | Blocked |
| 4 | D | Review publicly available privileges and inherited role memberships; restrict where appropriate. | Inspect PUBLIC ACLs and effective inherited memberships; test resulting access. | PUBLIC and inherited access paths are documented and appropriate; unnecessary access is removed. | `docs/activity-4-5-6/evidence/activity4-public-and-inherited-privileges.txt` | Blocked |

### Part E — Access-control testing

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 4 | E | Test each login account in every project database. | Manually execute the planned tests with each authorized login and target database. | Test matrix covers every account/database pair; inaccessible cases are recorded as blockers. | `docs/activity-4-5-6/evidence/activity4-privilege-verification.md` | Blocked |
| 4 | E | Test runtime access to an authorized table. | Run a representative authorized table read as the runtime account. | The authorized read succeeds. | `docs/activity-4-5-6/evidence/activity4-privilege-verification.md` | Blocked |
| 4 | E | Test runtime insert of an authorized record when required. | Run an approved, reversible/disposable insert test as the runtime account when the app requires it. | The required insert succeeds; if not required, the reason is recorded. | `docs/activity-4-5-6/evidence/activity4-privilege-verification.md` | Blocked |
| 4 | E | Test read-only retrieval of approved records. | Run an approved SELECT as the read-only account. | Approved retrieval succeeds. | `docs/activity-4-5-6/evidence/activity4-privilege-verification.md` | Blocked |
| 4 | E | Test denial of read-only updates. | Attempt an update against a safe, approved test target as the read-only account. | The update is denied; no data is changed. | `docs/activity-4-5-6/evidence/activity4-privilege-verification.md` | Blocked |
| 4 | E | Test denial of database creation by an ordinary application account. | Attempt the denied database-creation operation using that account. | Database creation is denied and no database is created. | `docs/activity-4-5-6/evidence/activity4-privilege-verification.md` | Blocked |
| 4 | E | Test denial of access to an unrelated database without permission. | Attempt connection with the account and inspect other effective access paths if it succeeds. | Connection is denied unless another documented applicable access path grants it. | `docs/activity-4-5-6/evidence/activity4-privilege-verification.md` | Blocked |
| 4 | E | Test denial of access to a table without required privileges. | Attempt a safe operation on a table for which the account has no privilege. | The operation is denied. | `docs/activity-4-5-6/evidence/activity4-privilege-verification.md` | Blocked |
| 4 | E | Record the account, SQL statement/operation, expected result, actual result, and evidence for every test. | Manually review each test record against the required fields and output/screenshot. | Every test has all four required fields and secret-free evidence. | `docs/activity-4-5-6/evidence/activity4-privilege-verification.md` | Template |
| 4 | E | Investigate any unauthorized operation that succeeds. | Inspect direct grants, inherited roles, ownership, PUBLIC privileges, and other access paths. | Cause is identified and remediated or explicitly blocked; retest confirms the intended denial. | `docs/activity-4-5-6/evidence/activity4-unexpected-access-investigation.md` | Blocked |

### Part F — Repository, tracker, PDF, and submission

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 4 | F | Store work in this group's repository under `db-access-control/`, with one subfolder per project and project SQL, plan, and test evidence. | Inspect repository tree against confirmed project inventory. | Each project has its own folder containing its plan, scripts, and test evidence. | `db-access-control/` and `docs/activity-4-5-6/evidence/activity4-project-inventory.md` | Blocked |
| 4 | F | Use meaningful commits showing how roles and privileges were developed. | Inspect commit history for scoped, descriptive changes. | History shows meaningful development milestones; no claim based solely on uncommitted files. | Git commit history | Manual only |
| 4 | F | Do not commit passwords or secrets; use placeholders and local credential configuration. | Review Git-tracked/staged files and secret-scan results. | No real secret is present in committed or submitted files. | `docs/activity-4-5-6/evidence/activity4-secret-scan.md` | Template |
| 4 | F | Do not modify another group's repository; send recommended fixes as owner feedback. | Review worktree/repository scope and dated feedback records. | All work is in this group's repository; recommendations are sent to owners, not applied to their repository. | `docs/activity-4-5-6/evidence/activity4-issues-feedback.md` | Blocked |
| 4 | F | Keep this group's Activity 3 tracker row up to date. | Manually inspect the class tracker row. | The group's own row reflects the current status. | Class Google Sheets tracker, own Activity 3 row | Manual only |
| 4 | F | Add one Activity 4 Log row for every project set up; edit only this group's rows. | Manually inspect the tracker tab and reconcile rows to confirmed inventory. | One row per project; only this group's rows are edited. | Class Google Sheets tracker, `Activity 4 Log` | Manual only |
| 4 | F / Tracker | Record exact Activity 4 tracker column: `Project`. | Inspect `Activity 4 Log` header and each project row. | Header is `Project`; value is the group number and project name. | Class Google Sheets tracker, `Activity 4 Log` | Manual only |
| 4 | F / Tracker | Record exact Activity 4 tracker column: `Repository cloned`. | Inspect tracker header/value. | Header is `Repository cloned`; value records repository URL and branch/tag. | Class Google Sheets tracker, `Activity 4 Log` | Manual only |
| 4 | F / Tracker | Record exact Activity 4 tracker column: `Database setup result`. | Inspect tracker header/value. | Header is `Database setup result`; value is Success, Success with issues, or Failed, with a short note. | Class Google Sheets tracker, `Activity 4 Log` | Manual only |
| 4 | F / Tracker | Record exact Activity 4 tracker column: `Access-control folder link`. | Open/verify tracker link. | Header is `Access-control folder link`; link opens the project's folder in this repository. | Class Google Sheets tracker, `Activity 4 Log` | Manual only |
| 4 | F / Tracker | Record exact Activity 4 tracker column: `Access-control status`. | Inspect tracker header/value. | Header is `Access-control status`; value is Not started, Planning, Roles created, Privileges tested, or Completed, matching actual progress. | Class Google Sheets tracker, `Activity 4 Log` | Manual only |
| 4 | F / Tracker | Record exact Activity 4 tracker column: `Feedback sent to owners`. | Inspect dated feedback record and tracker value. | Header is `Feedback sent to owners`; value is Yes/No and includes date where sent. | Class Google Sheets tracker, `Activity 4 Log` | Manual only |
| 4 | F / Tracker | Record exact Activity 4 tracker column: `PDF progress document`. | Open/verify tracker link. | Header is `PDF progress document`; same group's PDF link is present on every row. | Class Google Sheets tracker, `Activity 4 Log` | Manual only |
| 4 | F / Tracker | Record exact Activity 4 tracker column: `Last updated`. | Inspect tracker values. | Header is `Last updated`; each row has the group's most recent update date. | Class Google Sheets tracker, `Activity 4 Log` | Manual only |
| 4 | F / PDF | Include `Cover and links`: group number, members, repository link, tracker link. | Manually inspect the submitted PDF cover. | All four items are present and links identify the correct group resources. | Activity 4 progress PDF | Manual only |
| 4 | F / PDF | Include `Projects set up`: every cloned project, repository link, database objects, and setup result. | Reconcile PDF table against inventory and setup evidence. | Every project has all required columns and a supported setup result. | Activity 4 progress PDF | Manual only |
| 4 | F / PDF | Include `Access-control plan`: per-project login account, group role, application role, responsibility, and privileges. | Compare PDF tables with per-project plans. | All named fields are present for every project. | Activity 4 progress PDF | Manual only |
| 4 | F / PDF | Include `SQL scripts summary`: role, membership, grant, restriction scripts, and folder link. | Compare PDF summary with repository scripts. | Script purposes and project folder links are accurate. | Activity 4 progress PDF | Manual only |
| 4 | F / PDF | Include `Verification results`: per-project account, statement, expected result, actual result, and evidence. | Compare PDF tables to real test output. | Every reported result is supported by evidence and includes all required fields. | Activity 4 progress PDF | Manual only |
| 4 | F / PDF | Include `Issues and fixes`: unexpected results, causes, and corrections. | Compare PDF statements to issue records and retest evidence. | Issues and fixes are evidence-backed; absent issues are not fabricated. | Activity 4 progress PDF | Manual only |
| 4 | F / PDF | Include `Feedback to owners`: setup problems and security recommendations sent to each owner. | Compare PDF with dated owner feedback records. | Feedback coverage and dates match actual communications. | Activity 4 progress PDF | Manual only |
| 4 | F / PDF | Include `AI usage declaration`: AI tools, tasks, and validation of generated SQL/security configuration. | Manually review declaration against actual AI use and validation records. | Tools/tasks are disclosed and validation is described accurately. | Activity 4 progress PDF | Manual only |
| 4 | F / PDF | Submit progress PDF with repository link and record it in the tracker; keep PDF/screenshots secret-free. | Open PDF and repository links; manually inspect pages/screenshots for credentials. | PDF is linked, readable, complete, and contains no credentials/secrets. | Activity 4 progress PDF; class tracker | Manual only |

### Activity 4 required deliverables

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 4 | Deliverable | Provide database setup evidence for each project's initialized database. | Inspect setup logs/output and match them to each project/database. | Each project has evidence of initialization or an explicit failure/blocker record. | `docs/activity-4-5-6/evidence/activity4-setup-results.md` | Blocked |
| 4 | Deliverable | Provide a per-project access-control plan listing login account, group role, application role, responsibility, and privileges. | Inspect each plan against the required fields. | Every project plan contains all five fields. | `docs/activity-4-5-6/evidence/activity4-access-control-plans.md` | Blocked |
| 4 | Deliverable | Provide SQL for roles, memberships, grants, and necessary restrictions in this group's repository. | Inspect project scripts and compare against plan. | Scripts cover planned role and privilege configuration; no real password is embedded. | `db-access-control/<project-folder>/` | Blocked |
| 4 | Deliverable | Provide privilege verification results demonstrating permitted and denied operations. | Inspect test output and expected/actual results. | Each project has both allowed and denied test evidence as applicable. | `docs/activity-4-5-6/evidence/activity4-privilege-verification.md` | Blocked |
| 4 | Deliverable | Document security structure and rationale for assigned privileges. | Compare security documentation with implemented ACLs and plan. | Structure and least-privilege decisions are explained and evidence-consistent. | `docs/activity-4-5-6/evidence/activity4-security-documentation.md` | Blocked |
| 4 | Deliverable | Provide a progress PDF with repository link and tracker recording. | Open PDF/repository link and verify tracker entry. | PDF records Activity 4 progress and is linked/submitted as required. | Activity 4 progress PDF; class tracker | Manual only |
| 4 | Deliverable | Declare AI tools used, if any, and validation of generated SQL/security configuration. | Review declaration and validation evidence. | Declaration is accurate and validation is documented. | Activity 4 progress PDF, AI usage declaration | Manual only |

### Activity 4 rubric

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 4 | Rubric | Database setup and assessment — 5 points. | Evaluate setup evidence and object/access assessment for each project. | Each other-group project has a verifiable setup/assessment result or documented blocker. | `docs/activity-4-5-6/evidence/activity4-setup-results.md` | Blocked |
| 4 | Rubric | Access-control planning and role design — 10 points. | Evaluate per-project access plan and role rationale. | Roles map to documented responsibilities and follow least privilege. | `docs/activity-4-5-6/evidence/activity4-access-control-plans.md` | Blocked |
| 4 | Rubric | Correct creation of roles and login accounts — 15 points. | Compare role catalog and memberships with the plan. | Required group/login roles are correctly configured. | `docs/activity-4-5-6/evidence/activity4-role-verification.txt` | Blocked |
| 4 | Rubric | Appropriate privilege assignment and least privilege — 25 points. | Inspect effective privileges and D-part tests. | Required actions work; unjustified/elevated actions are denied. | `docs/activity-4-5-6/evidence/activity4-privilege-verification.md` | Blocked |
| 4 | Rubric | Successful verification of allowed and denied operations — 20 points. | Inspect actual test output for all relevant accounts/projects. | Both positive and negative behavior are evidenced; unexpected success is investigated. | `docs/activity-4-5-6/evidence/activity4-privilege-verification.md` | Blocked |
| 4 | Rubric | Documentation and technical justification — 10 points. | Compare plan, SQL summary, verification, issue records, and PDF. | Decisions and results are complete, consistent, and technically justified. | Activity 4 progress PDF | Manual only |
| 4 | Rubric | Own repository, tracker update, and PDF — 10 points. | Inspect repository structure/history, Activity 4 Log, and PDF. | Work is in own repo; tracker/PDF requirements are met. | `db-access-control/`; class tracker; Activity 4 progress PDF | Manual only |
| 4 | Rubric | AI transparency and validation — 5 points. | Review declaration and validation records. | AI use and validation are disclosed; no unvalidated generated configuration is represented as verified. | Activity 4 progress PDF, AI usage declaration | Manual only |

### Activity 4 submission checklist

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 4 | Checklist | All other groups' projects run with their own PostgreSQL databases. | Reconcile inventory with setup evidence. | Each reachable target has its own running database; failures are documented. | `docs/activity-4-5-6/evidence/activity4-setup-results.md` | Blocked |
| 4 | Checklist | Database objects and access requirements identified for each project. | Compare object inventory and access plan with project docs/database. | Objects and access needs are documented per project. | `docs/activity-4-5-6/evidence/activity4-object-inventory.md` | Blocked |
| 4 | Checklist | Group roles and login roles properly defined. | Inspect PostgreSQL roles and role plan. | Configured group/login roles match each plan. | `docs/activity-4-5-6/evidence/activity4-role-verification.txt` | Blocked |
| 4 | Checklist | Role memberships and database privileges documented. | Inspect membership/ACL output and plans. | Memberships/database grants are both recorded and match intended access. | `docs/activity-4-5-6/evidence/activity4-membership-verification.txt` | Blocked |
| 4 | Checklist | Schema, table, and sequence permissions reviewed. | Inspect effective grants on these object types. | Relevant permissions are reviewed and documented per project. | `docs/activity-4-5-6/evidence/activity4-object-privileges.txt` | Blocked |
| 4 | Checklist | Unnecessary elevated privileges avoided. | Inspect role attributes and justifications. | No account has unjustified elevated attributes. | `docs/activity-4-5-6/evidence/activity4-role-verification.txt` | Blocked |
| 4 | Checklist | Allowed and denied operations tested. | Inspect test matrix and real output. | Required allowed and denied cases have results and evidence. | `docs/activity-4-5-6/evidence/activity4-privilege-verification.md` | Blocked |
| 4 | Checklist | SQL scripts and test evidence included in submission and own repository. | Inspect repository and submission file lists. | Scripts and test evidence are present; no secret/data artifact is improperly included. | `db-access-control/` | Blocked |
| 4 | Checklist | Scripts are in own repository and Activity 4 Log is updated. | Inspect repo and tracker. | Repository contains scripts; tracker has a row for each project. | `db-access-control/`; class tracker, `Activity 4 Log` | Manual only |
| 4 | Checklist | PDF is complete and contains no secrets. | Review every PDF page and screenshot. | Required sections are present and secret-free. | Activity 4 progress PDF | Manual only |
| 4 | Checklist | No real passwords/secrets in repository, tracker, or PDF. | Run approved secret scan and human review. | No credential or secret is present in submitted materials. | `docs/activity-4-5-6/evidence/activity4-secret-scan.md` | Template |
| 4 | Checklist | AI assistance and validation activities declared. | Compare declaration with actual use and validation evidence. | Declaration is complete and accurate. | Activity 4 progress PDF, AI usage declaration | Manual only |

## Activity 5

### Part A — Database health and activity

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 5 | A | Inspect PostgreSQL version for each target project. | Run the per-project health check and retain actual output. | Server version is recorded for each database or access failure is documented. | `db-maintenance/<group-XX>/health-evidence.txt` | Template |
| 5 | A | Record the database name examined. | Run the per-project health check and compare to inventory. | Output database name matches the identified project database. | `db-maintenance/<group-XX>/health-evidence.txt` | Template |
| 5 | A | Record database size and number of tables/relevant objects. | Run approved catalog/size checks; compare object counts to project schema. | Size and relevant object counts are recorded and interpreted. | `db-maintenance/<group-XX>/health-evidence.txt` | Template |
| 5 | A | Inspect current sessions/connections, including active/idle sessions where visible. | Run permitted activity/statistics checks. | Session and connection state is recorded; visibility limits are documented. | `db-maintenance/<group-XX>/health-evidence.txt` | Template |
| 5 | A | Inspect currently running queries and duration where permitted. | Query permitted activity views and retain reviewed/redacted results. | Running query metadata/duration is recorded or permission limitation is explicit. | `db-maintenance/<group-XX>/health-evidence.txt` | Template |
| 5 | A | Inspect available evidence of failed connections, errors, or unusual behavior. | Review accessible logs/monitoring source for a declared time range. | Real findings are recorded or source/time range/limitations are stated; no incidents are invented. | `db-maintenance/<group-XX>/log-review.md` | Template |
| 5 | A | Verify Activity 4 roles/accounts are present and match the access-control plan. | Inspect roles/memberships and compare with Activity 4 plan. | Differences are recorded; role state is supported by actual output. | `db-maintenance/<group-XX>/health-evidence.txt` | Template |
| 5 | A | Record account used for each check and the application role it serves. | Review evidence metadata for every check. | Each check identifies authorized account and corresponding application role. | `db-maintenance/<group-XX>/health-evidence.txt` | Template |

### Part B — Log review and issue identification

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 5 | B | Review available PostgreSQL logs for failed logins/connections. | Inspect the configured approved log source/time range. | Real events are recorded with timestamp or availability/access limitation is documented. | `db-maintenance/<group-XX>/log-review.md` | Template |
| 5 | B | Review logs for SQL errors and application-generated database errors. | Inspect configured logs and relevant approved application error source. | Each observed error has evidence; absence is scoped to reviewed source/time range. | `db-maintenance/<group-XX>/log-review.md` | Template |
| 5 | B | Review logs/activity for long-running queries. | Inspect available logs/activity with duration context. | Long-running findings are supported by output or documented as unavailable. | `db-maintenance/<group-XX>/log-review.md` | Template |
| 5 | B | Review logs/activity for blocked activity or lock waits. | Inspect available lock/log evidence. | Observed blockers are documented or the review limitation is stated. | `db-maintenance/<group-XX>/log-review.md` | Template |
| 5 | B | Review warnings/repeated errors affecting reliability. | Inspect configured logs for a defined time range. | Findings and their scope are recorded; no claim exceeds the reviewed evidence. | `db-maintenance/<group-XX>/log-review.md` | Template |
| 5 | B | Review permission-denied errors and determine whether Activity 4 restrictions are expected or indicate a missing privilege. | Compare actual denial with Activity 4 plan and retain evidence. | Each denial is classified as expected or needing owner follow-up, with role rationale. | `db-maintenance/<group-XX>/log-review.md` | Template |
| 5 | B | For each finding, record evidence, plausible explanation, impact, and next step. | Manually audit each finding row. | All four fields are present for every reported finding. | `db-maintenance/<group-XX>/log-review.md` | Template |
| 5 | B | If no relevant issue appears, state what source/time range was checked and limitations. | Manually review the no-finding statement against actual review notes. | Source, time range, and limitations are explicit; absence is not described as proof of perfect health. | `db-maintenance/<group-XX>/log-review.md` | Template |

### Part C — Routine maintenance

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 5 | C | Review table and index objects before choosing maintenance. | Inspect per-project catalog/statistics output and schema. | Table/index inventory and maintenance rationale are recorded. | `db-maintenance/<group-XX>/maintenance.sql`; `maintenance-evidence.txt` | Template |
| 5 | C | Run `ANALYZE` on an appropriate table or database. | Run approved maintenance command and retain command/output/exit status. | Statistics refresh completes or privilege/environment blocker is recorded. | `db-maintenance/<group-XX>/maintenance-evidence.txt` | Template |
| 5 | C | Run `VACUUM` on an appropriate table or explain/demonstrate a suitable approach. | Run approved standalone `VACUUM` or record justified environment-specific method. | VACUUM completes on an appropriate target or reason it cannot run is documented. | `db-maintenance/<group-XX>/maintenance-evidence.txt` | Template |
| 5 | C | Run `VACUUM (VERBOSE, ANALYZE)` where appropriate and safe. | Inspect the actual command and completion output. | Appropriate command completes outside a transaction, or justified alternative/limitation is recorded. | `db-maintenance/<group-XX>/maintenance-evidence.txt` | Template |
| 5 | C | Explain each maintenance command's purpose and confirm its appropriateness before execution. | Compare written rationale with table activity/size/environment and actual command. | Rationale states purpose and appropriateness before command; no unjustified operation is run. | `db-maintenance/<group-XX>/maintenance-evidence.txt`; `report.md` | Template |
| 5 | C | Do not use `VACUUM FULL` without explicit instructor approval. | Search executed commands and review approval evidence if applicable. | No `VACUUM FULL` is run without explicit approval. | `db-maintenance/<group-XX>/maintenance-evidence.txt` | Template |
| 5 | C | Use an account with sufficient approved privileges; do not switch to superuser merely to force success. | Inspect account/role metadata and operation result. | Authorized Activity 4 account is used; denied maintenance is recorded as a limitation and suitable role recommended. | `db-maintenance/<group-XX>/maintenance-evidence.txt` | Template |
| 5 | C | Confirm operation completion and document outcome. | Inspect command exit status/output and relevant after-state. | Completion is demonstrated by real output, or the failure/limitation is explicit. | `db-maintenance/<group-XX>/maintenance-evidence.txt` | Template |

### Part D — Query performance

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 5 | D | Select one meaningful application `SELECT` per project, preferably one used by a documented application role. | Trace the query to application/user-role documentation and record purpose. | Query and its role/purpose are identified for each project. | `db-maintenance/<group-XX>/query-plan.sql` | Template |
| 5 | D | Capture `EXPLAIN` output first. | Execute the query plan command and retain complete output. | A real plan for the selected query is saved before any optional `ANALYZE` plan. | `db-maintenance/<group-XX>/query-plan-evidence.txt` | Template |
| 5 | D | Use `EXPLAIN (ANALYZE, BUFFERS)` only for a safe SELECT in a test environment. | Manually verify query safety/environment and inspect command/output. | Optional execution plan runs only when safe/approved; otherwise omission and reason are documented. | `db-maintenance/<group-XX>/query-plan-evidence.txt` | Template |
| 5 | D | Interpret scan and join operations. | Review interpretation against actual plan nodes. | Scan type and applicable join methods are named correctly. | `db-maintenance/<group-XX>/query-plan-evidence.txt`; `report.md` | Template |
| 5 | D | Interpret estimated versus actual rows. | Compare plan estimates with actual row counts when available. | Discrepancies or unavailable actual counts are accurately described. | `db-maintenance/<group-XX>/query-plan-evidence.txt`; `report.md` | Template |
| 5 | D | Interpret timing and buffer use where available. | Compare reported execution time/buffers with plan output. | Timing and buffers are accurately recorded or marked unavailable for non-ANALYZE plans. | `db-maintenance/<group-XX>/query-plan-evidence.txt`; `report.md` | Template |
| 5 | D | Recommend a potential improvement or justify why the plan is reasonable. | Compare recommendation with data volume, query, and actual plan. | At least one evidence-based improvement or explicit reasoned justification is present. | `db-maintenance/<group-XX>/report.md` | Template |
| 5 | D | Do not create indexes merely to satisfy the activity; justify proposed index/query change and write/storage cost. | Inspect recommendations and any actual schema changes. | No unjustified index is created; proposals explain benefit and write/storage trade-off. | `db-maintenance/<group-XX>/report.md` | Template |

### Part E — Findings and maintenance report

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 5 | E | Prepare a concise report for every project. | Verify each confirmed project folder contains a completed report. | Every project has a report or a clearly documented unreachable/setup blocker. | `db-maintenance/<group-XX>/report.md` | Template |
| 5 | E | Report environment, database, accounts, and Activity 4 roles represented. | Compare report fields to inventory and actual check metadata. | Project/database, accounts, and role mapping are present and evidence-consistent. | `db-maintenance/<group-XX>/report.md` | Template |
| 5 | E | Report health/activity checks and evidence. | Cross-check report references against health output. | Checks, interpretations, and evidence references are present. | `db-maintenance/<group-XX>/report.md` | Template |
| 5 | E | Report log findings or scoped statement that no relevant issue was observed. | Cross-check report with log-review evidence. | Findings or actual review scope/limitations are reported accurately. | `db-maintenance/<group-XX>/report.md` | Template |
| 5 | E | Report maintenance commands, rationale, and outcomes. | Cross-check report with maintenance output. | Commands, reason selected, and actual outcomes are included. | `db-maintenance/<group-XX>/report.md` | Template |
| 5 | E | Report query plan, interpretation, and justified recommendation. | Cross-check report with plan output. | Selected query, plan interpretation, and justified recommendation are present. | `db-maintenance/<group-XX>/report.md` | Template |
| 5 | E | Report permission/logging/other limitations. | Compare report to observed errors and log/role access. | Each encountered limitation is described without bypassing restrictions. | `db-maintenance/<group-XX>/report.md` | Template |
| 5 | E | Prioritize recommendations as immediate, follow-up, or no action required. | Review each recommendation and its supporting evidence. | Priority is explicit and justified per project. | `db-maintenance/<group-XX>/report.md` | Template |
| 5 | E | Combine project reports into the group's PDF. | Reconcile PDF project coverage against inventory and repository reports. | Every project report is represented in the PDF. | Activity 5 progress PDF | Manual only |

### Part F — Repository, tracker, PDF

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 5 | F | Store work in this group's `db-maintenance/`, with one subfolder per project containing maintenance scripts, query-plan evidence, log notes, and report. | Inspect repository tree against inventory and each folder's contents. | Each project has the required materials in this repository. | `db-maintenance/` | Template |
| 5 | F | Use meaningful commits showing monitoring/maintenance progress. | Inspect scoped commit history. | Commit history shows meaningful progression for actual work. | Git commit history | Manual only |
| 5 | F | Do not commit passwords/secrets; use placeholders and local credential configuration. | Review scripts/tracked files and scan results. | No secrets are committed; real credentials remain local. | `docs/activity-4-5-6/evidence/activity5-secret-scan.md` | Template |
| 5 | F | Do not modify other groups' repositories; send findings/recommendations as owner feedback. | Inspect repo scope and dated communication record. | Work remains in own repo and feedback is sent to owners. | `db-maintenance/<group-XX>/report.md`; feedback record | Blocked |
| 5 | F | Keep this group's Activity 3 tracker row updated. | Manually inspect class tracker. | Own Activity 3 row reflects current progress. | Class Google Sheets tracker | Manual only |
| 5 | F | Add an Activity 5 Log row for every monitored project; edit only own rows. | Reconcile tracker tab with inventory. | Every target has one row; no other group's tracker rows are edited. | Class Google Sheets tracker, `Activity 5 Log` | Manual only |
| 5 | F / Tracker | Record exact Activity 5 tracker column: `Project`. | Inspect Activity 5 Log header and values. | Header `Project`; value gives group number/project name. | Class Google Sheets tracker, `Activity 5 Log` | Manual only |
| 5 | F / Tracker | Record exact Activity 5 tracker column: `Database inspected`. | Inspect tracker values against evidence. | Header `Database inspected`; value gives database name and PostgreSQL version. | Class Google Sheets tracker, `Activity 5 Log` | Manual only |
| 5 | F / Tracker | Record exact Activity 5 tracker column: `Account and role used`. | Inspect tracker values against evidence. | Header `Account and role used`; value identifies Activity 4 account and application role. | Class Google Sheets tracker, `Activity 5 Log` | Manual only |
| 5 | F / Tracker | Record exact Activity 5 tracker column: `Health check result`. | Inspect tracker values against real health evidence. | Header `Health check result`; value is Healthy, Issues found, or Not reachable with a short note. | Class Google Sheets tracker, `Activity 5 Log` | Manual only |
| 5 | F / Tracker | Record exact Activity 5 tracker column: `Maintenance performed`. | Inspect tracker value against command evidence. | Header `Maintenance performed`; value names ANALYZE/VACUUM/other action and date. | Class Google Sheets tracker, `Activity 5 Log` | Manual only |
| 5 | F / Tracker | Record exact Activity 5 tracker column: `Query analyzed`. | Inspect tracker value against plan evidence. | Header `Query analyzed`; value gives short query purpose and observed scan type. | Class Google Sheets tracker, `Activity 5 Log` | Manual only |
| 5 | F / Tracker | Record exact Activity 5 tracker column: `Recommendation priority`. | Inspect tracker value against report. | Header `Recommendation priority`; value is Immediate action, Follow-up action, or No action required. | Class Google Sheets tracker, `Activity 5 Log` | Manual only |
| 5 | F / Tracker | Record exact Activity 5 tracker column: `Evidence folder link`. | Open link and inspect target folder. | Header `Evidence folder link`; link resolves to that project's folder in this repository. | Class Google Sheets tracker, `Activity 5 Log` | Manual only |
| 5 | F / Tracker | Record exact Activity 5 tracker column: `Feedback sent to owners`. | Compare tracker entry to actual dated feedback. | Header `Feedback sent to owners`; value is Yes/No and date where sent. | Class Google Sheets tracker, `Activity 5 Log` | Manual only |
| 5 | F / Tracker | Record exact Activity 5 tracker column: `PDF progress document`. | Open link and inspect tracker rows. | Header `PDF progress document`; same PDF link appears on every row. | Class Google Sheets tracker, `Activity 5 Log` | Manual only |
| 5 | F / Tracker | Record exact Activity 5 tracker column: `Last updated`. | Inspect tracker values. | Header `Last updated`; date reflects most recent group update. | Class Google Sheets tracker, `Activity 5 Log` | Manual only |
| 5 | F / PDF | Include `Cover and links`: group number, members, repository link, tracker link. | Manually inspect PDF. | All specified details/links appear on cover. | Activity 5 progress PDF | Manual only |
| 5 | F / PDF | Include `Projects monitored`: every project, repository, database, accounts, and roles. | Reconcile PDF table with inventory. | Every project and all specified columns are present. | Activity 5 progress PDF | Manual only |
| 5 | F / PDF | Include `Health and activity evidence` with interpretation per project. | Compare PDF output/screenshots and interpretations to health evidence. | Every project's results and interpretation are supported by actual output. | Activity 5 progress PDF | Manual only |
| 5 | F / PDF | Include `Log findings`: evidence, explanation, impact, next step, or actual checked scope. | Cross-check PDF against log review. | All finding fields or scoped no-finding account is included. | Activity 5 progress PDF | Manual only |
| 5 | F / PDF | Include `Maintenance performed`: commands, rationale, and results. | Cross-check PDF against maintenance output. | Commands and real outcomes are reported per project. | Activity 5 progress PDF | Manual only |
| 5 | F / PDF | Include `Query performance analysis`: plan, interpretation, justified recommendation per project. | Cross-check PDF against query-plan evidence. | Each project has plan output and interpretation/recommendation. | Activity 5 progress PDF | Manual only |
| 5 | F / PDF | Include `Recommendations` prioritized per project as immediate, follow-up, or none. | Compare PDF priorities with project reports. | Every project's recommendations are explicitly prioritized and justified. | Activity 5 progress PDF | Manual only |
| 5 | F / PDF | Include `Limitations and permissions` and relate them to Activity 4 roles. | Compare PDF limits with observed denied access and role plan. | Permission/logging limits and role context are stated. | Activity 5 progress PDF | Manual only |
| 5 | F / PDF | Include `Feedback to owners`. | Compare PDF feedback statements with dated communications. | Actual findings/recommendations sent to each owner are represented. | Activity 5 progress PDF | Manual only |
| 5 | F / PDF | Include `AI usage declaration`: tools, tasks, and validation. | Review actual usage declaration. | Declaration is accurate and describes validation. | Activity 5 progress PDF | Manual only |
| 5 | F / PDF | Submit PDF with repository link and keep PDF/screenshots/logs free of secrets. | Open links and manually inspect all pages, screenshots, and log excerpts. | PDF is linked and complete; no credentials/secrets are visible. | Activity 5 progress PDF | Manual only |

### Activity 5 required deliverables

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 5 | Deliverable | Provide health/activity evidence with interpretation for each project. | Inspect real command output/screenshots and interpretations. | Each project's health/activity evidence is present and interpreted. | `db-maintenance/<group-XX>/health-evidence.txt` | Template |
| 5 | Deliverable | Provide log review notes and issue assessment or statement of what was checked. | Inspect per-project log notes and their evidence/scope. | Findings have required fields or review scope and limitations are stated. | `db-maintenance/<group-XX>/log-review.md` | Template |
| 5 | Deliverable | Provide maintenance script/command list with explanations and results. | Compare script/command list with real execution records. | Commands are stored in own repo and have explanations/results. | `db-maintenance/<group-XX>/maintenance.sql`; `maintenance-evidence.txt` | Template |
| 5 | Deliverable | Provide per-project query performance evidence and interpretation. | Inspect real execution plan and interpretation. | Selected query's plan and analysis are present for each project. | `db-maintenance/<group-XX>/query-plan-evidence.txt` | Template |
| 5 | Deliverable | Provide final report per project compiled into PDF. | Compare project reports with PDF. | Report and PDF cover required findings for every project. | `db-maintenance/<group-XX>/report.md`; Activity 5 progress PDF | Template |
| 5 | Deliverable | Provide Activity 5 progress PDF with repository link and tracker record. | Open and check PDF/link/tracker entry. | PDF documents all group progress and is linked/submitted as required. | Activity 5 progress PDF; class tracker | Manual only |
| 5 | Deliverable | Declare AI tools used and how generated suggestions were validated. | Review declaration against actual activity. | AI use and validation are accurately described. | Activity 5 progress PDF, AI usage declaration | Manual only |

### Activity 5 rubric

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 5 | Rubric | Database health/activity inspection — 20 points. | Evaluate per-project health evidence and interpretation. | Health/activity status is evidenced and correctly interpreted. | `db-maintenance/<group-XX>/health-evidence.txt` | Template |
| 5 | Rubric | Log review and issue interpretation — 15 points. | Evaluate findings and log-review scope/limitations. | Findings are evidence-grounded with explanation and appropriate response. | `db-maintenance/<group-XX>/log-review.md` | Template |
| 5 | Rubric | Appropriate maintenance operations and explanation — 20 points. | Evaluate pre-review, command choice, rationale, output, and result. | Maintenance is proportionate, justified, and verified. | `db-maintenance/<group-XX>/maintenance-evidence.txt` | Template |
| 5 | Rubric | Query execution-plan analysis and recommendations — 20 points. | Evaluate selected query, plan, interpretation, and recommendation. | Real plan is interpreted correctly and recommendation is justified. | `db-maintenance/<group-XX>/query-plan-evidence.txt` | Template |
| 5 | Rubric | Evidence, PDF progress documentation, actionable recommendations — 15 points. | Reconcile evidence, PDF, and prioritized recommendations. | PDF is evidence-backed and recommendations actionable/prioritized. | Activity 5 progress PDF | Manual only |
| 5 | Rubric | Own repository, tracker update, and version control — 5 points. | Inspect folder, commits, and Activity 5 Log. | Work, meaningful history, and tracker rows are present. | `db-maintenance/`; Git history; class tracker | Manual only |
| 5 | Rubric | AI transparency and validation — 5 points. | Review declaration and validation notes. | AI use and validation are disclosed accurately. | Activity 5 progress PDF, AI usage declaration | Manual only |

### Activity 5 submission checklist

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 5 | Checklist | Every other group's project and database identified from tracker. | Reconcile project inventory with tracker. | Every other-group target/database is identified; own group excluded. | `docs/activity-4-5-6/evidence/activity5-project-inventory.md` | Blocked |
| 5 | Checklist | Accounts/roles match Activity 4 plan and Activity 3 user-role documentation. | Compare actual account metadata with both source plans. | Each check uses an authorized role appropriate to its task. | `db-maintenance/<group-XX>/report.md` | Blocked |
| 5 | Checklist | Health/activity checks include evidence and interpretation. | Inspect output and report interpretation. | Evidence and interpretation are present for every project. | `db-maintenance/<group-XX>/health-evidence.txt` | Template |
| 5 | Checklist | Available logs reviewed; findings grounded in evidence. | Inspect log-source/time-range record and finding output. | Review is real and scoped; incidents are not invented. | `db-maintenance/<group-XX>/log-review.md` | Template |
| 5 | Checklist | Maintenance commands are appropriate, explained, and documented. | Review rationale and actual completion output. | Commands are justified and outcomes/limits recorded. | `db-maintenance/<group-XX>/maintenance-evidence.txt` | Template |
| 5 | Checklist | Query execution plan included and interpreted. | Inspect captured plan and interpretation. | Every project has a real plan and analysis. | `db-maintenance/<group-XX>/query-plan-evidence.txt` | Template |
| 5 | Checklist | Recommendations prioritized and justified. | Compare recommendation priority to evidence/report. | Priorities and rationale are explicit per project. | `db-maintenance/<group-XX>/report.md` | Template |
| 5 | Checklist | Scripts/evidence are in own repository and Activity 5 Log updated. | Inspect repo and tracker. | Project folders and one tracker row per monitored project exist. | `db-maintenance/`; class tracker, `Activity 5 Log` | Manual only |
| 5 | Checklist | PDF is complete and contains no secrets. | Review PDF sections and every screenshot/log excerpt. | Complete and secret-free PDF is ready for submission. | Activity 5 progress PDF | Manual only |
| 5 | Checklist | No real credentials or secrets appear in submitted files. | Run approved scanner and human review on repo, tracker, PDF, screenshots, ZIP. | No secrets remain in submitted artifacts. | `docs/activity-4-5-6/evidence/activity5-secret-scan.md` | Template |
| 5 | Checklist | AI use disclosed and generated suggestions validated. | Review AI declaration and validation notes. | Disclosure and validation are complete and accurate. | Activity 5 progress PDF, AI usage declaration | Manual only |

## Activity 6

### Part A — Backup planning

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 6 | A | Identify the database and database objects to back up for each project. | Compare backup plan scope with project schema/object inventory. | Database, schema, tables, sequences, and other in-scope objects are named. | `db-backup-recovery/<group-XX>/backup-plan.md` | Template |
| 6 | A | Select a backup method and justify its suitability. | Review method against PostgreSQL version, database size, requirements, and permissions. | Method and project-specific rationale are recorded; custom logical backup is used unless approved reason differs. | `db-backup-recovery/<group-XX>/backup-plan.md` | Template |
| 6 | A | Specify protected backup storage and which Activity 4 accounts/roles may access it. | Review local storage/access plan; verify path is outside Git. | Protected local storage and authorized readers/writers are identified; runtime account is not used. | `db-backup-recovery/<group-XX>/backup-plan.md` | Template |
| 6 | A | Define how backup usability will be verified. | Review planned archive listing, checksum, isolated restore, and object/data checks. | Verification plan includes archive inspection and successful separate restore testing. | `db-backup-recovery/<group-XX>/backup-plan.md` | Template |
| 6 | A | Propose real-deployment backup schedule. | Review schedule and project workload/data-loss rationale. | Schedule is specified and justified per project. | `db-backup-recovery/<group-XX>/backup-plan.md` | Template |
| 6 | A | Propose retention approach. | Review retention duration/count and storage constraints. | Retention is specified and justified per project. | `db-backup-recovery/<group-XX>/backup-plan.md` | Template |
| 6 | A | Specify RPO and acceptable data-loss window. | Review RPO against project requirements and backup schedule. | RPO is explicit and its rationale is project-appropriate. | `db-backup-recovery/<group-XX>/backup-plan.md` | Template |
| 6 | A | Specify RTO and acceptable service-restoration time. | Review RTO against recovery method and project requirements. | RTO is explicit and its rationale is project-appropriate. | `db-backup-recovery/<group-XX>/backup-plan.md` | Template |
| 6 | A | Plan recreation of Activity 4 roles, memberships, and privileges after restore because roles are cluster-wide. | Compare restore plan with Activity 4 scripts and cluster/database privilege scopes. | Role recreation/reapplication and verification sequence is documented; credentials remain secret. | `db-backup-recovery/<group-XX>/backup-plan.md` | Template |
| 6 | A | Use `pg_dump` logical backup and `pg_restore` for custom archive unless approved environment/permission exception is documented. | Inspect selected method and actual commands/exception approval. | Custom-format logical backup/restore is used, or a justified approved alternative is recorded. | `db-backup-recovery/<group-XX>/backup-plan.md` | Template |

### Part B — Backup creation and inspection

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 6 | B | Create a backup of each project database using an account with required access. | Inspect successful `pg_dump` output/exit status and account metadata. | A valid custom-format dump exists for each reachable project in protected storage. | Protected local dump; `db-backup-recovery/<group-XX>/checksums.txt` | Blocked |
| 6 | B | Record exact backup command without credential exposure. | Compare recorded command/options with script execution record. | Command and non-secret parameters are recorded; no password is in command/report. | `db-backup-recovery/<group-XX>/checksums.txt` | Template |
| 6 | B | Record backup filename. | Compare metadata record to protected file. | Filename matches the real backup. | `db-backup-recovery/<group-XX>/checksums.txt` | Template |
| 6 | B | Record backup file size. | Inspect file metadata. | Byte size is recorded for the real dump. | `db-backup-recovery/<group-XX>/checksums.txt` | Template |
| 6 | B | Record backup checksum. | Recompute SHA-256 from the protected file and compare. | Recorded checksum matches the file exactly. | `db-backup-recovery/<group-XX>/checksums.txt` | Template |
| 6 | B | Record backup date/time and errors/warnings. | Compare timestamp and command output with execution record. | Date/time and all relevant messages are recorded accurately without secrets. | `db-backup-recovery/<group-XX>/checksums.txt` | Template |
| 6 | B | Keep data-bearing backup in protected local storage; do not commit it. | Inspect path, Git index/worktree, and submission archive. | Dump is outside repository and ZIP; only non-data metadata/evidence is committed. | `db-backup-recovery/<group-XX>/checksums.txt`; Git status | Blocked |
| 6 | B | Inspect archive using `pg_restore --list` and retain output. | Run against the actual protected dump and inspect saved listing. | Actual archive listing is present and tied to the backup metadata. | `db-backup-recovery/<group-XX>/archive-listing.txt` | Template |
| 6 | B | Explain what the archive listing indicates. | Review report explanation against actual TOC entries. | Report describes observed object/entry types without claiming more than listing proves. | `db-backup-recovery/<group-XX>/report.md` | Template |
| 6 | B | Explain that a file on disk alone does not prove successful recovery. | Review report rationale and restore evidence. | Report explains why an isolated restore test is required and references it. | `db-backup-recovery/<group-XX>/report.md` | Template |

### Part C — Separate restore and verification

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 6 | C | Create a new, empty, distinct test database for each project. | Verify database identity/emptiness and instructor-approved creation evidence. | Restore target is separate, initially empty, and never the original database. | `db-backup-recovery/<group-XX>/restore-evidence.txt` | Blocked |
| 6 | C | Restore the backup into the separate test database. | Inspect `pg_restore` command, exit status, target name, and output. | Restore completes in the designated separate database; warnings are investigated. | `db-backup-recovery/<group-XX>/restore-evidence.txt` | Blocked |
| 6 | C | Investigate and document ownership/privilege options, warnings, and failures; do not suppress blindly. | Review actual restore flags/output and explanation for each warning. | Every option/warning/failure has an evidence-based explanation; no unexplained suppression. | `db-backup-recovery/<group-XX>/restore-evidence.txt` | Template |
| 6 | C | Verify expected tables and important database objects exist. | Run tailored restore verification queries and compare with source inventory. | Expected object counts/names match or differences are documented. | `db-backup-recovery/<group-XX>/restore-verify.sql`; `restore-evidence.txt` | Template |
| 6 | C | Verify expected sample records in selected tables. | Run project-specific row/sample checks against restored database. | Expected records/counts are present or discrepancies are explained. | `db-backup-recovery/<group-XX>/restore-evidence.txt` | Template |
| 6 | C | Verify primary keys, foreign keys, and important constraints. | Query restored catalog and compare with project schema. | Required constraints are present and definitions match, or differences are documented. | `db-backup-recovery/<group-XX>/restore-evidence.txt` | Template |
| 6 | C | Verify Activity 4 roles, memberships, and privileges are present or recreated. | Run Activity 4 role/grant/verification steps in approved environment; inspect results. | Roles/memberships/privileges are verified or documented as not included and safely recreated. | `db-backup-recovery/<group-XX>/restore-evidence.txt` | Template |
| 6 | C | Test one permitted operation after restore. | Run a safe permitted operation using its authorized account. | Expected permitted operation succeeds. | `db-backup-recovery/<group-XX>/restore-evidence.txt` | Template |
| 6 | C | Test one denied operation after restore. | Run a safe forbidden operation using the restricted account. | Expected denied operation fails without changing data. | `db-backup-recovery/<group-XX>/restore-evidence.txt` | Template |
| 6 | C | Verify a representative SELECT returns expected results. | Run documented application SELECT against restored database and compare expected output. | Query returns expected restored data or discrepancy is documented. | `db-backup-recovery/<group-XX>/restore-evidence.txt` | Template |
| 6 | C | Test application connection to restored database if feasible. | Manually point a test instance at the restored database using protected local config. | Connection succeeds, or infeasibility and reason are recorded; no `.env` is submitted. | `db-backup-recovery/<group-XX>/restore-evidence.txt` | Template |
| 6 | C | Document limitations, missing objects, and privilege differences. | Compare restore results with source and Activity 4 plan. | All observed differences/limitations are recorded; no unverified completeness claim. | `db-backup-recovery/<group-XX>/restore-evidence.txt` | Template |

### Part D — Controlled recovery simulation

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 6 | D | Use only the restored test database/disposable environment and disposable test data. | Verify database names, record identity, authorization, and command targets before/after. | Original database remains untouched; only disposable target/data is changed. | `db-backup-recovery/<group-XX>/recovery-simulation.md` | Blocked |
| 6 | D | Confirm a verified backup exists and preserve it before destructive test. | Match checksum/archive/restore verification and protected backup metadata. | Verified initial backup exists and remains unchanged throughout simulation. | `db-backup-recovery/<group-XX>/checksums.txt`; `recovery-simulation.md` | Blocked |
| 6 | D | Record incident description, intended scope, and state before incident. | Inspect incident plan and actual before-state query/output. | Target record and scope are identified; pre-loss state is evidenced. | `db-backup-recovery/<group-XX>/recovery-simulation.md` | Template |
| 6 | D | Simulate a small data-loss incident, such as deleting only the disposable record. | Inspect exact command/output and target database. | Only disposable test data in restored test environment is affected. | `db-backup-recovery/<group-XX>/recovery-simulation.md` | Template |
| 6 | D | Record state after simulated loss. | Inspect actual after-loss query/output. | Output demonstrates the planned disposable data loss. | `db-backup-recovery/<group-XX>/recovery-simulation.md` | Template |
| 6 | D | Recover into a fresh recovery database or use a carefully planned table-level method. | Inspect recovery target/method and execution evidence. | Recovery method is safe, isolated, and technically justified. | `db-backup-recovery/<group-XX>/recovery-simulation.md` | Template |
| 6 | D | Compare recovered data with recorded expected state and report outcome. | Compare actual recovered query/output with pre-loss expectation. | Record existence/key fields/related constraints are marked pass/fail based on output. | `db-backup-recovery/<group-XX>/recovery-simulation.md` | Template |
| 6 | D | Explain what differs if incident occurs after latest backup, using RPO. | Compare backup timestamp/schedule with proposed RPO. | Data-loss window is accurately explained relative to RPO. | `db-backup-recovery/<group-XX>/recovery-simulation.md` | Template |
| 6 | D | Do not drop tables or delete real application data; preserve original DB and initial backup. | Review commands and before/after database/backup identifiers. | No destructive operation targets original database or real data; initial backup stays unchanged. | `db-backup-recovery/<group-XX>/recovery-simulation.md` | Blocked |

### Part E — Recovery report

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 6 | E | Prepare a per-project backup, restore, and recovery report. | Verify report exists for each confirmed project. | Each project has a report or explicit blocker. | `db-backup-recovery/<group-XX>/report.md` | Template |
| 6 | E | Report backup/restore commands, removing placeholders only where safe and never exposing credentials. | Compare report commands with actual execution and scan for credentials. | Commands are accurate and contain no secrets. | `db-backup-recovery/<group-XX>/report.md` | Template |
| 6 | E | Report backup creation/inspection evidence: screenshots/output, filename, size, checksum, archive listing. | Cross-check report with real metadata/listing. | All specified backup facts are present and match the protected dump. | `db-backup-recovery/<group-XX>/report.md` | Template |
| 6 | E | Report restoration evidence and separate test database. | Cross-check report with restore output/target. | Restore target and outcome are evidenced. | `db-backup-recovery/<group-XX>/report.md` | Template |
| 6 | E | Report verification of objects, records, constraints, sequences, roles, privileges, operations, and representative query. | Compare every report claim with verification evidence. | All applicable checks/results are supported by actual output. | `db-backup-recovery/<group-XX>/report.md` | Template |
| 6 | E | Report recovery incident timeline, method, outcome, and comparison. | Compare report with simulation records. | Incident and recovery sequence and outcome are complete and evidence-consistent. | `db-backup-recovery/<group-XX>/report.md` | Template |
| 6 | E | Report limitations, errors, warnings, and how handled. | Cross-check report with command outputs and permission results. | All material limitations/errors are disclosed with handling. | `db-backup-recovery/<group-XX>/report.md` | Template |
| 6 | E | Evaluate whether method/frequency fit a real deployment; recommend readiness improvements. | Review evaluation against RPO/RTO, schedule, retention, workload. | Suitability and actionable improvement recommendations are explicit. | `db-backup-recovery/<group-XX>/report.md` | Template |
| 6 | E | Combine project reports into group's PDF. | Reconcile PDF projects with inventory/repository reports. | Every project report is represented. | Activity 6 progress PDF | Manual only |

### Part F — Repository, tracker, PDF

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 6 | F | Store plan, commands/scripts, checksums, verification queries, and report in own `db-backup-recovery/`, with one project subfolder each. | Inspect repository tree against confirmed inventory. | Each project folder has required non-data deliverables. | `db-backup-recovery/` | Template |
| 6 | F | Do not commit data-bearing backup files; store protected locally and record only filename, size, checksum. | Inspect Git index/worktree/ZIP and compare backup location with metadata record. | No dump is committed/submitted; metadata is recorded without backup data. | `.gitignore`; Git status; `db-backup-recovery/<group-XX>/checksums.txt` | Template |
| 6 | F | Use meaningful commits and do not commit passwords/secrets; use placeholders/local config. | Inspect commit history, tracked files, and secret-scan results. | History is meaningful and repository contains no real credentials. | Git history; `docs/activity-4-5-6/evidence/activity6-secret-scan.md` | Template |
| 6 | F | Do not modify other groups' repositories; send findings/recommendations as feedback. | Inspect repository scope and dated feedback record. | No other group's repository is modified; feedback is sent to owners. | `db-backup-recovery/<group-XX>/report.md`; feedback record | Blocked |
| 6 | F | Keep this group's Activity 3 tracker row updated. | Manually inspect class tracker. | Own Activity 3 row reflects current progress. | Class Google Sheets tracker | Manual only |
| 6 | F | Add an Activity 6 Log row for each project backed up; edit only own group's rows. | Reconcile tracker rows against inventory. | One row per project; no other group's rows are edited. | Class Google Sheets tracker, `Activity 6 Log` | Manual only |
| 6 | F / Tracker | Record exact Activity 6 tracker column: `Project`. | Inspect header/value. | Header `Project`; value identifies group number and backed-up project name. | Class Google Sheets tracker, `Activity 6 Log` | Manual only |
| 6 | F / Tracker | Record exact Activity 6 tracker column: `Database and backup file`. | Compare tracker value with real backup metadata. | Header `Database and backup file`; value includes database name, filename, size, checksum, not dump contents. | Class Google Sheets tracker, `Activity 6 Log` | Manual only |
| 6 | F / Tracker | Record exact Activity 6 tracker column: `Backup method`. | Compare tracker value with command and timestamp. | Header `Backup method`; value names method and backup date/time. | Class Google Sheets tracker, `Activity 6 Log` | Manual only |
| 6 | F / Tracker | Record exact Activity 6 tracker column: `Restore test result`. | Compare tracker result with restore evidence. | Header `Restore test result`; value is Success, Success with issues, or Failed, with short note. | Class Google Sheets tracker, `Activity 6 Log` | Manual only |
| 6 | F / Tracker | Record exact Activity 6 tracker column: `Access control after restore`. | Compare tracker result with role/privilege verification. | Header `Access control after restore`; value is Yes/No and reflects verification of Activity 4 roles/privileges. | Class Google Sheets tracker, `Activity 6 Log` | Manual only |
| 6 | F / Tracker | Record exact Activity 6 tracker column: `Recovery simulation result`. | Compare tracker result with simulation evidence. | Header `Recovery simulation result`; value is Recovered, Partly recovered, or Not recovered with short note. | Class Google Sheets tracker, `Activity 6 Log` | Manual only |
| 6 | F / Tracker | Record exact Activity 6 tracker column: `Proposed RPO and RTO`. | Compare tracker objectives with backup plan. | Header `Proposed RPO and RTO`; objectives match justified per-project plan. | Class Google Sheets tracker, `Activity 6 Log` | Manual only |
| 6 | F / Tracker | Record exact Activity 6 tracker column: `Evidence folder link`. | Open link and inspect folder. | Header `Evidence folder link`; link resolves to the project's folder in own repository. | Class Google Sheets tracker, `Activity 6 Log` | Manual only |
| 6 | F / Tracker | Record exact Activity 6 tracker column: `Feedback sent to owners`. | Compare tracker entry to dated owner message. | Header `Feedback sent to owners`; value is Yes/No and date where sent. | Class Google Sheets tracker, `Activity 6 Log` | Manual only |
| 6 | F / Tracker | Record exact Activity 6 tracker column: `PDF progress document`. | Open link and inspect rows. | Header `PDF progress document`; same PDF link appears on every row. | Class Google Sheets tracker, `Activity 6 Log` | Manual only |
| 6 | F / Tracker | Record exact Activity 6 tracker column: `Last updated`. | Inspect tracker values. | Header `Last updated`; date is the group's most recent update. | Class Google Sheets tracker, `Activity 6 Log` | Manual only |
| 6 | F / PDF | Include `Cover and links`: group number, members, repository link, tracker link. | Manually inspect PDF cover. | All specified identifiers and links appear. | Activity 6 progress PDF | Manual only |
| 6 | F / PDF | Include `Projects covered`: every project, repository, database, and accounts used. | Reconcile PDF table with inventory. | Each project and required fields are included. | Activity 6 progress PDF | Manual only |
| 6 | F / PDF | Include `Backup plan`: objects, method, storage, access, verification, schedule, retention, RPO/RTO per project. | Compare PDF with each backup plan. | All plan elements are present per project. | Activity 6 progress PDF | Manual only |
| 6 | F / PDF | Include `Backup creation and inspection`: commands, filename, size, checksum, archive listing evidence. | Cross-check PDF against actual metadata/listing. | All listed facts match real evidence; dump itself is not embedded. | Activity 6 progress PDF | Manual only |
| 6 | F / PDF | Include `Restoration and verification`: separate test DB and checks of objects, records, constraints, queries. | Compare PDF statements to restore evidence. | Restore and required verification are evidenced per project. | Activity 6 progress PDF | Manual only |
| 6 | F / PDF | Include `Access control after restore`: Activity 4 role/privilege recreation and tests. | Compare PDF description with role/grant and allowed/denied output. | Recreation and verification are documented accurately. | Activity 6 progress PDF | Manual only |
| 6 | F / PDF | Include `Recovery simulation`: incident scope, timeline, method, expected-state comparison. | Compare PDF to simulation evidence. | Before/after/recovered states and comparison are included. | Activity 6 progress PDF | Manual only |
| 6 | F / PDF | Include `Evaluation and recommendations`: suitability for real system and readiness improvements. | Compare evaluation to RPO/RTO and observed restore result. | Evaluation and actionable improvements are justified. | Activity 6 progress PDF | Manual only |
| 6 | F / PDF | Include `Limitations and errors`: warnings/permission limits and handling. | Compare PDF with restore and command logs. | Relevant limitations and their handling are stated. | Activity 6 progress PDF | Manual only |
| 6 | F / PDF | Include `Feedback to owners`. | Compare PDF with owner communication record. | Findings/recommendations sent to each owner are represented. | Activity 6 progress PDF | Manual only |
| 6 | F / PDF | Include `AI usage declaration`: tools, tasks, and command validation. | Compare declaration to actual AI use and validation records. | Declaration is accurate and explains how commands were checked. | Activity 6 progress PDF | Manual only |
| 6 | F / PDF | Submit PDF with repository link; keep screenshots/logs/PDF free of secrets. | Open links and inspect all pages/screenshots/log excerpts. | PDF is complete, linked, and contains no real secrets. | Activity 6 progress PDF | Manual only |

### Activity 6 required deliverables

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 6 | Deliverable | Per-project backup plan with schedule, retention, RPO/RTO, and Activity 4 role recreation. | Inspect each plan against required fields. | Complete justified plan for each target. | `db-backup-recovery/<group-XX>/backup-plan.md` | Template |
| 6 | Deliverable | Create and securely store backup files; document commands/checksums in own repo. | Verify protected dump, command record, checksum, and Git exclusion. | Real backup is protected and not committed; command/checksum evidence exists. | Protected local dump; `checksums.txt`; Git status | Blocked |
| 6 | Deliverable | Provide separate-test-database restore evidence and object/data/constraint/access-control verification. | Inspect restore output and verification results. | Restore and required checks are documented for each project. | `db-backup-recovery/<group-XX>/restore-evidence.txt` | Template |
| 6 | Deliverable | Provide per-project controlled recovery simulation report. | Inspect before/after/recovery evidence and outcome. | Simulation is isolated/disposable and outcome is evidenced. | `db-backup-recovery/<group-XX>/recovery-simulation.md` | Template |
| 6 | Deliverable | Provide final report per project compiled into PDF. | Compare report set and PDF. | PDF includes every project report and associated evidence. | `db-backup-recovery/<group-XX>/report.md`; Activity 6 progress PDF | Template |
| 6 | Deliverable | Provide Activity 6 PDF with repository link and tracker record. | Open PDF/link and inspect tracker row. | PDF is complete and linked/submitted. | Activity 6 progress PDF; class tracker | Manual only |
| 6 | Deliverable | Declare AI assistance and how commands were validated. | Compare declaration with executed command validation. | AI use and command validation are disclosed accurately. | Activity 6 progress PDF, AI usage declaration | Manual only |

### Activity 6 rubric

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 6 | Rubric | Backup plan, RPO/RTO, retention rationale — 15 points. | Evaluate per-project plan and justifications. | All required planning fields are justified. | `db-backup-recovery/<group-XX>/backup-plan.md` | Template |
| 6 | Rubric | Backup creation and archive inspection — 20 points. | Verify real `pg_dump`, checksum, and `pg_restore --list` output. | Backup and archive inspection have real evidence. | `checksums.txt`; `archive-listing.txt` | Blocked |
| 6 | Rubric | Restoration to a separate test database — 20 points. | Verify distinct target and successful restore evidence. | Restore is completed and documented in a separate test DB. | `restore-evidence.txt` | Blocked |
| 6 | Rubric | Verification of objects, data integrity, and access control — 15 points. | Inspect object/data/constraint/role/privilege and operation tests. | Required checks pass or deviations are explicitly documented. | `restore-evidence.txt` | Template |
| 6 | Rubric | Controlled recovery simulation and evaluation — 15 points. | Evaluate scope, before/after, method, outcome, and RPO impact. | Disposable-data simulation and comparison are complete. | `recovery-simulation.md` | Template |
| 6 | Rubric | Evidence and AI validation — 5 points. | Verify actual evidence and declaration/command validation. | Claims are backed by output and AI suggestions/commands validated. | Per-project evidence; AI usage declaration | Template |
| 6 | Rubric | Own repository, tracker, and PDF — 10 points. | Inspect repository/history, Activity 6 Log, and PDF. | Own-repo evidence, tracker rows, and PDF are complete. | `db-backup-recovery/`; Git history; class tracker; PDF | Manual only |
| 6 | Rubric note | A backup that was never restored must not receive full credit. | Check that the backup identified in the report has a corresponding successful or qualified separate-database restore test. | No full-credit claim is made for an un-restored backup. | `db-backup-recovery/<group-XX>/restore-evidence.txt`; Activity 6 progress PDF | Blocked |

### Activity 6 submission checklist

| Activity | Part | Requirement | How checked | Expected result | Evidence file | Status |
|---|---|---|---|---|---|---|
| 6 | Checklist | Backup plans identify database, storage, schedule, retention, RPO/RTO, and role recreation. | Inspect each completed plan against fields. | Every project plan covers all named items. | `db-backup-recovery/<group-XX>/backup-plan.md` | Template |
| 6 | Checklist | Backup created and archive listing inspected. | Verify real dump metadata and `pg_restore --list` output. | Valid protected backup and listing are evidenced. | `checksums.txt`; `archive-listing.txt` | Blocked |
| 6 | Checklist | Restore performed in a separate test database. | Verify restore target differs from original and restore output exists. | Successful/qualified restore is documented in separate DB. | `restore-evidence.txt` | Blocked |
| 6 | Checklist | Tables, records, constraints, access control, and representative query verified. | Inspect completed verification output. | Every listed category has an actual result. | `restore-verify.sql`; `restore-evidence.txt` | Template |
| 6 | Checklist | Recovery simulation used only disposable test data. | Inspect simulation targets and record identifiers. | Only clearly disposable test data is affected. | `recovery-simulation.md` | Blocked |
| 6 | Checklist | Original databases and backups preserved. | Compare original DB identifier and backup checksum before/after. | Original is untouched and initial backup unchanged. | `recovery-simulation.md`; `checksums.txt` | Blocked |
| 6 | Checklist | Evidence, limitations, and recommendations included. | Review report and evidence references. | Report explains evidence, limitations, and recommendations. | `db-backup-recovery/<group-XX>/report.md` | Template |
| 6 | Checklist | Backup files securely stored and not committed to any repository. | Inspect local storage location, Git tracking, and submission archive. | Data-bearing dumps are outside Git and ZIP. | Git status; `.gitignore`; `checksums.txt` | Blocked |
| 6 | Checklist | Scripts/evidence are in own repo and Activity 6 Log updated. | Inspect repository and tracker rows. | Project files are in own repo and tracker contains one row per project. | `db-backup-recovery/`; class tracker, `Activity 6 Log` | Manual only |
| 6 | Checklist | PDF is complete and contains no secrets. | Review all PDF pages/screenshots and required sections. | PDF is complete and secret-free. | Activity 6 progress PDF | Manual only |
| 6 | Checklist | No secrets/real credentials submitted. | Run approved secret scan and human review over submission surfaces. | No real secrets appear in scripts, reports, tracker, PDF, or screenshots. | `docs/activity-4-5-6/evidence/activity6-secret-scan.md` | Template |
| 6 | Checklist | AI use declared and commands validated. | Review AI declaration and command validation record. | AI use is disclosed and each generated command was checked before execution. | Activity 6 progress PDF, AI usage declaration | Manual only |

## Source and verification notes

- Sources read: `docs/activity-requirements/COMP018_Activity_4_Requirements.md`, `COMP018_Activity_5_Requirements.md`, `COMP018_Activity_6_Requirements.md`, and **Phase 1 only** of `docs/COPILOT_PROMPT.md`.
- The requirement extracts are text copied from official PDFs. The files are readable, page sections and checklist/rubric content are present, and no specific requirement was marked **NEEDS VERIFICATION**. The official PDFs remain authoritative if later consulted and found to differ.
- This matrix is a traceability plan, not evidence that project setup, privilege tests, maintenance, backups, restores, tracker updates, owner feedback, or PDF submission have been completed.
- The repository's current `group-XX` folders are templates only. Unknown project identities, tracker URL/data, permissions, and actual command output remain blockers; no values are inferred.
