# COMP018 Activities 4-6 - Extracted Requirements

> Combined text extract for AI context. The PDFs remain authoritative.

# COMP018 Activity 4 Requirements

> Text extracted from the official PDF for AI/tool context. The PDF remains the authoritative source. Formatting may be simplified.
> Lines are wrapped for readability; the wording is unchanged.

## Page 1

COMP 018 - DATABASE ADMINISTRATION ACTIVITY 4 Database Users, Roles, Privileges, and Access Control Securing a
Database Environment Course COMP 018 - Database Administration Activity Type Group Activity Database Platform
PostgreSQL Core Skill Role and privilege management Activity Overview Each group will set up the Activity 3
applications of all the other groups, which it finds through the class Google Sheets tracker. For each
project, they must set up its PostgreSQL database, identify the different database access requirements, create
appropriate database roles and login accounts, assign privileges, and test whether access restrictions work as
intended. The main principle is least privilege: every database account should receive only the permissions
necessary for its intended responsibilities. Students must not use a PostgreSQL superuser or a single
unrestricted account for ordinary application access. I. Learning Objectives 1. Configure PostgreSQL databases
for existing applications. 2. Differentiate database login roles, group roles, and administrative accounts. 3.
Create database users and assign them to appropriate group roles. 4. Apply GRANT and REVOKE commands to manage
database privileges. 5. Restrict access to databases, schemas, tables, sequences, and other required objects.
6. Test permitted and denied operations using different database accounts. 7. Document the database
access-control structure and justify its security decisions. 8. Record the work in a PDF progress document and
share the group's results through its own repository and the class Google Sheets tracker. II. Activity
Instructions Part A - Database Setup and Assessment Use the Activity 3 projects of all the other groups, as
listed in the Google Sheets tracker (not your own project). Do not modify any owning group's repository; keep
your own work in your group's repository (see Part F). 1. Open the Google Sheets tracker and clone the
repository of every other group, then review each project's README, PDF progress documentation, user roles
documentation, and database documentation. 2. Set up each application and its own PostgreSQL database using
the documented procedures, keeping the databases separate. 3. Identify the database name, schemas, tables,
sequences, views, and other database objects used by each application. COMP 018 - Database Administration |
Activity 4 - Page 1

## Page 2

COMP 018 - DATABASE ADMINISTRATION 4. Review each application's database operations and its user roles
documentation (from Activity 3) to determine which users or system components need access. 5. Prepare a
database access-control plan for each project before creating users and assigning privileges. Document any
missing setup instructions or database inconsistencies encountered during this process, and report them to the
owning group. If a project cannot be set up, record the blocking problem, report it to the owners, and
continue with the remaining projects. Part B - Identify Users, Group Roles, and Privileges Determine the
different types of database access required by the application. Database role Intended responsibilities
Example permissions Database administrator Provision and maintain the database environment Administrative
privileges appropriate to the task Application runtime Perform normal application operations Required SELECT,
INSERT, UPDATE, and DELETE permissions Read-only user View records for reporting or inspection SELECT on
approved tables or views Data entry user Add new records and view relevant data INSERT and SELECT on approved
tables Auditor Inspect records without modifying them Read-only access to approved data These are examples,
not mandatory roles for every project. Identify appropriate roles based on each application's requirements and
its documented user roles from Activity 3. A role's name does not enforce its intended responsibilities;
implement and verify the actual PostgreSQL privileges. Part C - Create Database Roles and Login Accounts Use
PostgreSQL role management commands to implement your access-control plan. Your implementation must include: ●
Group roles - roles representing common sets of database privileges, generally created with NOLOGIN. ● Login
roles - individual database accounts that can authenticate to PostgreSQL. ● Role membership - assign login
roles to appropriate group roles. ● Database access - grant only the necessary database-level permissions. ●
Schema access - grant the required schema privileges. ● Object-level access - configure table, sequence, view,
and other necessary privileges. Illustrative SQL example (adapt names and privileges to each project): --
Create group roles CREATE ROLE app_runtime_grp NOLOGIN; CREATE ROLE app_readonly_grp NOLOGIN; -- Create login
roles CREATE ROLE app_runtime LOGIN PASSWORD 'use-a-secure-password'; CREATE ROLE report_user LOGIN PASSWORD
'use-a-secure-password'; -- Assign group roles GRANT app_runtime_grp TO app_runtime; GRANT app_readonly_grp TO
report_user; -- Grant database connection access GRANT CONNECT ON DATABASE project_db COMP 018 - Database
Administration | Activity 4 - Page 2

## Page 3

COMP 018 - DATABASE ADMINISTRATION TO app_runtime_grp, app_readonly_grp; -- Grant schema access GRANT USAGE ON
SCHEMA public TO app_runtime_grp, app_readonly_grp; -- Grant table privileges GRANT SELECT, INSERT, UPDATE,
DELETE ON ALL TABLES IN SCHEMA public TO app_runtime_grp; GRANT SELECT ON ALL TABLES IN SCHEMA public TO
app_readonly_grp; This is an illustrative starting point, not a complete security configuration. Run
database-level grants while connected to the appropriate administrative database, and schema/object grants
while connected to the target database. ● PostgreSQL roles are cluster-wide, while database and schema
privileges are scoped to their respective resources. ● CONNECT does not grant access to tables. ● USAGE on a
schema does not automatically grant access to its tables. ● Table privileges do not automatically grant
privileges on sequences used by operations such as inserts with generated identifiers. ● Privileges on
existing objects do not automatically cover every future object. Review default privileges when necessary. ●
Do not grant SUPERUSER, CREATEDB, CREATEROLE, or other elevated attributes unless specifically justified for
an administrative account. Never commit actual passwords to any repository, tracker sheet, or PDF document.
Use secure, local configuration for credentials. Part D - Implement the Principle of Least Privilege Review
default privileges and access permissions of each database you set up. Your group must ensure that: 1. The
application does not use a PostgreSQL superuser account for normal operations. 2. Application accounts cannot
access unrelated application databases merely because they were given broad privileges. 3. Users cannot modify
tables or records outside their assigned responsibilities. 4. Read-only accounts cannot insert, update, or
delete records. 5. Accounts do not receive unnecessary database creation or role-management privileges. 6.
Publicly available privileges and inherited role memberships are reviewed and restricted where appropriate. Do
not assume that creating a separate username is sufficient. Examine the privileges the account actually
inherits and the operations it can perform. Part E - Test and Verify Access Control Test each login account in
every project database using a PostgreSQL client such as psql or an appropriate database administration tool.
Test operation Expected result Application runtime reads an authorized table Allowed COMP 018 - Database
Administration | Activity 4 - Page 3

## Page 4

COMP 018 - DATABASE ADMINISTRATION Test operation Expected result Application runtime inserts an authorized
record Allowed, if required Read-only user retrieves approved records Allowed Read-only user updates a record
Denied Ordinary application user creates a new database Denied User accesses an unrelated database without
permission Denied, subject to other applicable access paths User accesses a table without the required
privileges Denied Adapt these tests to the privileges your group actually implements. For every test, record
the account used, SQL statement or operation, expected result, and actual result, with a screenshot or output
as evidence for the PDF progress documentation. If an unauthorized operation succeeds, investigate the cause.
Check direct grants, inherited roles, object ownership, PUBLIC privileges, and other applicable permissions
before considering the configuration complete. Part F - Repository, Tracker, and Progress Documentation As in
Activity 3, there is no centralized repository. Each group keeps its Activity 4 work in its own project
repository and records its status in the class Google Sheets tracker. The group then submits a PDF that
documents all of its progress. Step 1 - Keep your work in your own repository 1. Create a folder such as
db-access-control/ in your group's own repository, with one subfolder per project you set up (for example,
db-access-control/group-03/) containing that project's SQL scripts, access-control plan, and test evidence. 2.
Use meaningful commits so the repository history shows how the roles and privileges were developed. 3. Do not
commit passwords or secrets. Use placeholders in scripts and keep real credentials in local configuration. 4.
Do not change any other group's repository. Send recommended fixes to each owning group as feedback instead.
Step 2 - Update the Google Sheets tracker Keep your group's Activity 3 row up to date. In addition, add a tab
named Activity 4 Log to the tracker with one row for every project your group sets up, using the columns
below. Edit only your own group's rows. Activity 4 Log column What to enter Project Group number and project
name of the application you set up. Repository cloned Repository URL and the branch or tag used. Database
setup result Success, Success with issues, or Failed, with a short note. Access-control folder link Link to
that project's subfolder in your own repository. Access-control status Not started, Planning, Roles created,
Privileges tested, or Completed. Feedback sent to owners Yes or No, with the date feedback was sent to the
owning group. PDF progress document Link to your group's PDF progress documentation (same link on every row).
COMP 018 - Database Administration | Activity 4 - Page 4

## Page 5

COMP 018 - DATABASE ADMINISTRATION Activity 4 Log column What to enter Last updated Date of the most recent
update by your group. Step 3 - Submit the PDF progress documentation Continue the PDF progress document from
Activity 3 by adding the sections below, or submit a separate PDF for this activity. Submit it together with
the link to your repository. Section Contents Cover and links Group number, members, repository link, and
tracker link. Projects set up Table of every project cloned, its repository link, its database objects, and
its setup result. Access-control plan For each project, a table of each login account, group role, application
role served, responsibility, and required privileges. SQL scripts summary Overview of the scripts for roles,
memberships, grants, and restrictions, with the folder link. Verification results For each project, a table of
each test: account, statement, expected result, actual result, and evidence. Issues and fixes Unexpected
results found, their cause, and how they were corrected. Feedback to owners Setup problems and security
recommendations sent to each owning group. AI usage declaration AI tools used, tasks performed with them, and
how the output was validated. The PDF must not contain real passwords or other secrets. Check screenshots to
confirm that no credentials are visible. III. Required Deliverables ● Database setup evidence - Proof that
each project's database was successfully initialized. ● Access-control plan - For each project, a table
describing each login account, group role, application role served, responsibility, and required privilege. ●
SQL scripts - Scripts for creating roles, assigning memberships, granting privileges, and applying necessary
restrictions, stored in the group's own repository. ● Privilege verification report - Test results for each
project demonstrating both permitted and denied operations. ● Database security documentation - Explanation of
the access-control structure and rationale for assigned privileges. ● Progress documentation (PDF) - A PDF
recording all of the group's Activity 4 progress, submitted with the repository link and recorded in the
Google Sheets tracker. ● AI usage declaration - AI tools used, if any, and how generated SQL and security
configuration were validated. Do not submit real passwords or other secrets in scripts, the repository, the
tracker, or the PDF. IV. Assessment Rubric Criteria Points Database setup and assessment 5 COMP 018 - Database
Administration | Activity 4 - Page 5

## Page 6

COMP 018 - DATABASE ADMINISTRATION Criteria Points Access-control planning and role design 10 Correct creation
of roles and login accounts 15 Appropriate privilege assignment and least privilege 25 Successful verification
of allowed and denied operations 20 Documentation and technical justification 10 Own repository, tracker
update, and PDF progress documentation 10 AI usage transparency and validation 5 TOTAL 100 A configuration
that merely creates users without testing their effective permissions should not receive full credit. The PDF
progress documentation must be supported by the evidence and commit history in the group's own repository. V.
Submission Checklist ☐ All other groups' projects run with their own PostgreSQL databases. ☐ Database objects
and access requirements have been identified for each project. ☐ Group roles and login roles are properly
defined. ☐ Role memberships and database privileges are documented. ☐ Schema, table, and sequence permissions
have been reviewed. ☐ Unnecessary elevated privileges have been avoided. ☐ Allowed and denied operations have
been tested. ☐ SQL scripts and test evidence are included in the submission and the group's repository. ☐ The
scripts are in the group's own repository, and the Activity 4 Log in the tracker is updated. ☐ The PDF
progress documentation is complete and contains no secrets. ☐ No real passwords or secrets appear in any
repository, tracker, or PDF. ☐ AI assistance and validation activities are declared. Expected Outcome By the
end of Activity 4, each group should have working PostgreSQL databases for the projects it set up, each with a
documented access-control structure, properly assigned user and group roles, and verified restrictions on
database operations. These environments become the foundation for Activity 5 on database health, logs,
maintenance, and performance. COMP 018 - Database Administration | Activity 4 - Page 6


---

# COMP018 Activity 5 Requirements

> Text extracted from the official PDF for AI/tool context. The PDF remains the authoritative source. Formatting may be simplified.
> Lines are wrapped for readability; the wording is unchanged.

## Page 1

COMP 018 - DATABASE ADMINISTRATION ACTIVITY 5 Database Maintenance and Monitoring Monitoring Database Health,
Maintaining Reliability, and Analyzing Performance Course COMP 018 - Database Administration Activity Type
Group Activity Database Platform PostgreSQL Core Skill Monitoring, maintenance, and performance analysis
Activity Overview Your group will monitor and maintain the PostgreSQL databases of the projects it set up in
Activity 4, which are the Activity 3 projects of all the other groups, found through the class Google Sheets
tracker. Each database should reflect the application setup from Activity 3 and the access-control
configuration from Activity 4. For each project, your task is to assess its condition, inspect database
activity and available logs, perform appropriate routine maintenance, and evaluate the performance of a
selected query. This activity emphasizes practical database administration. Students must collect evidence,
interpret their observations, explain possible issues, and recommend appropriate actions. Do not make changes
without understanding their purpose and potential impact. Results are documented in the group's PDF progress
documentation, kept alongside its own project repository and recorded in the Google Sheets tracker. I.
Learning Objectives By the end of this activity, students should be able to: 1. Inspect PostgreSQL database
status, connections, sessions, and activity. 2. Examine available logs and identify potential errors or
warning signs. 3. Perform appropriate routine maintenance operations and explain their purpose. 4. Analyze a
query execution plan and identify possible performance concerns. 5. Relate monitoring and maintenance findings
to the roles, accounts, and privileges set up in Activity 4. 6. Document observations, maintenance actions,
test results, and recommendations. 7. Keep the work in the group's own repository, record its status in the
class Google Sheets tracker, and submit a PDF progress document. II. General Instructions ● Continue using the
other groups' projects that you cloned and set up in Activities 3 and 4, together with the access-control
configuration from Activity 4. Find each repository and its user roles documentation in the Google Sheets
tracker. ● Use a local or instructor-approved test environment. Do not run potentially disruptive commands on
production systems. ● Use an authorized database account from the Activity 4 access-control plan, choosing the
account whose role fits each task (for example, a read-only or auditor account for inspection). Do not bypass
the privileges established in Activity 4. ● Capture screenshots or command output as evidence and explain what
each result means. COMP 018 - Database Administration | Activity 5 - Page 1

## Page 2

COMP 018 - DATABASE ADMINISTRATION ● AI tools may be used for explanations or troubleshooting, but your group
must validate suggestions and explain the commands it runs. ● Never include real passwords, API keys, or other
secrets in your report, repository, tracker, or PDF. ● Work through every other group's project listed in the
tracker (not your own). If a project's database cannot be reached or set up, record the blocking problem and
continue with the others. ● Keep your work in your group's own repository (for example, a db-maintenance/
folder with one subfolder per project). Do not modify any other group's repository; send recommendations to
the owning group as feedback. III. Activity Tasks Part A - Database Health and Activity Inspection For each
project, connect to its PostgreSQL database and collect evidence about its current state. Use psql or an
approved database administration tool. Inspect and document the following: ● PostgreSQL version and the name
of the database being examined. ● Database size and the number of tables or other relevant objects. ● Current
sessions and connections, including active or idle sessions where visible. ● Currently running queries and
their duration, where permissions allow. ● Available evidence of failed connections, errors, or unusual
behavior. ● The Activity 4 roles and login accounts present in the database, confirming that they still match
the access-control plan (record any difference). ● The account used for each check and the application role it
serves. Possible commands and queries (adapt them to your environment): SELECT version(); SELECT
current_database(); SELECT pg_size_pretty(pg_database_size(current_database())); SELECT datname, numbackends
FROM pg_stat_database WHERE datname = current_database(); SELECT pid, usename, state, wait_event_type,
wait_event, query_start, query FROM pg_stat_activity WHERE datname = current_database() ORDER BY query_start
NULLS LAST; Note: Monitoring views may show limited information depending on the account's privileges. Record
permission limitations rather than attempting to bypass them. Part B - Logs and Issue Identification Inspect
the PostgreSQL logs available in your configured environment. Log location and access depend on the
installation and configuration; logs may be viewed through the server's configured log destination or an
administrator-approved service/tool. Look for evidence such as: ● Failed login or connection attempts. ● SQL
errors or application-generated database errors. ● Long-running queries or signs of blocked activity, if
logged or observable. COMP 018 - Database Administration | Activity 5 - Page 2

## Page 3

COMP 018 - DATABASE ADMINISTRATION ● Warnings or repeated errors that may affect reliability. ●
Permission-denied errors that may come from the Activity 4 restrictions, and whether they are expected or show
a missing privilege. For each finding, record the evidence, a plausible explanation, the impact if left
unresolved, and a recommended next step. If no relevant issue appears in the available logs, state what you
checked and what limitations applied. Do not invent incidents. Part C - Routine Maintenance Perform and
document suitable maintenance operations in each test database. Before running a command, explain its purpose
and confirm that it is appropriate for the environment. Required maintenance work: ● Review table and index
objects and identify whether statistics or maintenance may be needed. ● Run ANALYZE on an appropriate table or
the database to refresh planner statistics. ● Run VACUUM on an appropriate table, or explain and demonstrate
the suitable VACUUM approach for your environment. ● Confirm that the operation completed and document the
result. Example commands: ANALYZE; VACUUM (VERBOSE, ANALYZE) public.example_table; Replace
public.example_table with a real table in each project's database. Run VACUUM as a standalone command, not
inside a transaction block. Do not use VACUUM FULL for this activity unless your instructor explicitly
approves it; it can require an exclusive lock and additional disk space. Maintenance needs depend on database
activity, table size, autovacuum configuration, and the environment. Use an account whose privileges allow the
operation; do not switch to a superuser merely to make a command work. If the Activity 4 privileges do not
allow maintenance, record the limitation and recommend a suitable maintenance role instead. Part D - Query
Performance Analysis For each project, select one meaningful SELECT query used by the application, ideally one
run by a documented application role (see its user roles documentation). Capture its execution plan, interpret
the main operations, and identify at least one potential improvement or explain why the plan appears
reasonable. Use EXPLAIN first. EXPLAIN ANALYZE executes the query, so use it only for a safe SELECT query in
the test environment. EXPLAIN SELECT * FROM public.example_table WHERE example_column = 'sample_value'; --
Optional, only for a safe SELECT query in the test environment: EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM
public.example_table WHERE example_column = 'sample_value'; Discuss the scan type (for example, sequential
scan or index scan), estimated versus actual rows if EXPLAIN ANALYZE was used, execution time where available,
and whether an index or query rewrite may help. Do not create an index merely to satisfy the activity; justify
any proposed change and consider the write/storage cost of indexes. COMP 018 - Database Administration |
Activity 5 - Page 3

## Page 4

COMP 018 - DATABASE ADMINISTRATION Part E - Findings and Maintenance Report Prepare a concise report for each
project that includes: ● Environment and database inspected, with the accounts used and the Activity 4 roles
they represent. ● Health and activity checks performed, with evidence. ● Log findings or a statement that no
relevant issue was observed in the available logs. ● Maintenance commands run, why they were selected, and
their outcomes. ● Query plan, interpretation, and any justified performance recommendation. ● Limitations
encountered, including permission or logging limitations. ● Prioritized recommendations: immediate action,
follow-up action, or no action required. Combine the project reports into the group's PDF progress
documentation (see Part F). Part F - Repository, Tracker, and Progress Documentation As in Activities 3 and 4,
there is no centralized repository. Each group keeps its Activity 5 work in its own project repository and
records its status in the class Google Sheets tracker. The group then submits a PDF that documents all of its
progress. Step 1 - Keep your work in your own repository 1. Create a folder such as db-maintenance/ in your
group's own repository, with one subfolder per project (for example, db-maintenance/group-03/) containing that
project's maintenance script, query plan evidence, log notes, and report. 2. Use meaningful commits so the
repository history shows how the monitoring and maintenance work progressed. 3. Do not commit passwords or
secrets. Use placeholders in scripts and keep real credentials in local configuration. 4. Do not change any
other group's repository. Send findings and recommendations to each owning group as feedback instead. Step 2 -
Update the Google Sheets tracker Keep your group's Activity 3 row up to date. In addition, add a tab named
Activity 5 Log to the tracker with one row for every project your group monitors, using the columns below.
Edit only your own group's rows. Activity 5 Log column What to enter Project Group number and project name of
the database monitored. Database inspected Database name and PostgreSQL version. Account and role used The
Activity 4 account used and the application role it serves. Health check result Healthy, Issues found, or Not
reachable, with a short note. Maintenance performed ANALYZE, VACUUM, or other action, with the date. Query
analyzed Short description of the query and the scan type observed. Recommendation priority Immediate action,
Follow-up action, or No action required. Evidence folder link Link to that project's subfolder in your own
repository. Feedback sent to owners Yes or No, with the date feedback was sent to the owning group. PDF
progress document Link to your group's PDF progress documentation (same link on every row). Last updated Date
of the most recent update by your group. COMP 018 - Database Administration | Activity 5 - Page 4

## Page 5

COMP 018 - DATABASE ADMINISTRATION Step 3 - Submit the PDF progress documentation Continue the PDF progress
document from Activities 3 and 4 by adding the sections below, or submit a separate PDF for this activity.
Submit it together with the link to your repository. Section Contents Cover and links Group number, members,
repository link, and tracker link. Projects monitored Table of every project, its repository link, database
name, and the accounts and roles used. Health and activity evidence For each project, command output or
screenshots with interpretation. Log findings Evidence, explanation, impact, and next step for each finding,
or what was checked if nothing was found. Maintenance performed Commands run, why they were chosen, and their
results. Query performance analysis Execution plan, interpretation, and any justified recommendation for each
project. Recommendations Prioritized actions for each project: immediate, follow-up, or none. Limitations and
permissions Permission or logging limitations met, and how they relate to the Activity 4 roles. Feedback to
owners Findings and recommendations sent to each owning group. AI usage declaration AI tools used, tasks
performed with them, and how the output was validated. The PDF must not contain real passwords or other
secrets. Check screenshots and logs to confirm that no credentials are visible. IV. Required Deliverables ●
Health and activity inspection evidence - For each project database, command output or screenshots with
interpretation. ● Log review notes and issue assessment - Findings with evidence, explanation, impact, and
next step, or a statement of what was checked. ● Maintenance script or command list - Commands run with
explanations and results, stored in the group's own repository. ● Query performance analysis - Execution-plan
evidence and interpretation for a selected query in each project. ● Final maintenance and monitoring report -
A report for each project, compiled into the PDF progress documentation. ● Progress documentation (PDF) - A
PDF recording all of the group's Activity 5 progress, submitted with the repository link and recorded in the
Google Sheets tracker. ● AI usage declaration - AI tools used and how generated suggestions were validated. V.
Assessment Rubric Criteria Points Database health and activity inspection 20 Log review and issue
interpretation 15 Appropriate maintenance operations and explanation 20 Query execution-plan analysis and
recommendations 20 COMP 018 - Database Administration | Activity 5 - Page 5

## Page 6

COMP 018 - DATABASE ADMINISTRATION Criteria Points Evidence, PDF progress documentation, and actionable
recommendations 15 Own repository, tracker update, and version control practices 5 AI transparency and
validation 5 Total 100 Credit depends on evidence from the real databases and on the commit history in the
group's own repository, not on the number of commands run. VI. Submission Checklist ☐ Every other group's
project and database were identified from the tracker. ☐ The roles and accounts used match the Activity 4
access-control plan and the Activity 3 user roles documentation. ☐ Health and activity checks include evidence
and interpretation. ☐ Available logs were reviewed and findings are grounded in evidence. ☐ Maintenance
commands are appropriate, explained, and documented. ☐ A query execution plan is included and interpreted. ☐
Recommendations are prioritized and justified. ☐ The scripts and evidence are in the group's own repository,
and the Activity 5 Log in the tracker is updated. ☐ The PDF progress documentation is complete and contains no
secrets. ☐ No real credentials or secrets appear in submitted files. ☐ AI usage is disclosed and generated
suggestions were validated. Important Notes The goal is not to produce the largest number of commands. The
goal is to demonstrate sound DBA judgment: observe the database, verify evidence, explain what it means,
choose a proportionate action, verify the result, and document what should happen next. Document every project
the same way so that the group's PDF progress documentation, repository, and tracker entries show what was
observed, what was done, and what should happen next. COMP 018 - Database Administration | Activity 5 - Page 6


---

# COMP018 Activity 6 Requirements

> Text extracted from the official PDF for AI/tool context. The PDF remains the authoritative source. Formatting may be simplified.
> Lines are wrapped for readability; the wording is unchanged.

## Page 1

COMP 018 - DATABASE ADMINISTRATION ACTIVITY 6 Database Backup, Restoration, and Recovery Planning for Data
Loss and Recovering a Working Database Course COMP 018 - Database Administration Activity Type Group Activity
Database Platform PostgreSQL Core Skill Backup, restoration, and recovery Activity Overview Your group will
work with the PostgreSQL databases of the projects it set up in Activity 4, which are the Activity 3 projects
of all the other groups, found through the class Google Sheets tracker. After setting up each database,
configuring access controls, and performing maintenance and monitoring in the previous activities, your next
responsibility is to plan for data loss and demonstrate that the database can be backed up and restored. For
each project, you will create a backup, restore it into a separate test database or isolated environment,
verify the restored data and objects, and simulate a small recovery incident using disposable test data. All
destructive operations must be performed only in the designated test environment. Results are documented in
the group's PDF progress documentation, kept alongside its own project repository and recorded in the Google
Sheets tracker. I. Learning Objectives 1. Explain why database backups and restoration tests are essential to
database administration. 2. Choose an appropriate logical backup and restore method for a PostgreSQL database.
3. Create and securely store a backup using PostgreSQL tools. 4. Restore a backup into a separate test
database and verify its completeness. 5. Simulate a controlled data-loss incident and recover the affected
data from a backup. 6. Document recovery steps, evidence, limitations, and recommendations. 7. Account for the
roles and privileges from Activity 4 when planning and verifying a restore. 8. Keep the work in the group's
own repository, record its status in the class Google Sheets tracker, and submit a PDF progress document. II.
General Instructions ● Continue with the other groups' projects and databases used in Activities 3-5, finding
each repository and its user roles documentation in the Google Sheets tracker. ● Use only a local or
instructor-approved test environment. Never simulate data loss on a production database or another group's
only copy. ● Before any destructive test, confirm that a verified backup exists and that the target is the
disposable test database. ● Do not include real credentials or secrets in scripts, screenshots, reports, the
repository, the tracker, or the PDF. COMP 018 - Database Administration | Activity 6 - Page 1

## Page 2

COMP 018 - DATABASE ADMINISTRATION ● Use an account from the Activity 4 access-control plan that suits backup
and restore tasks, not the application runtime account. If no suitable role exists, document the need and
create a dedicated backup role in your own local setup without granting broader privileges than necessary. ●
Work through every other group's project listed in the tracker (not your own). If a project cannot be backed
up or restored, record the blocking problem and continue with the others. ● Keep your work in your group's own
repository (for example, a db-backup-recovery/ folder with one subfolder per project). Do not modify any other
group's repository, and do not commit backup files that contain data; commit scripts and notes only. ● AI
tools may be used for explanations and troubleshooting, but commands must be checked and their effects
understood before execution. III. Activity Tasks Part A - Backup Planning Prepare a short backup plan before
running commands. Include: ● Which database and objects need to be backed up. ● The selected backup method and
why it is appropriate. ● Where the backup file will be stored and which Activity 4 roles or accounts should
have access to it. ● How the group will verify that the backup is usable. ● A proposed backup schedule and
retention approach for a real deployment. ● A simple recovery objective: how much data loss may be acceptable
(Recovery Point Objective, RPO) and how quickly the service should be restored (Recovery Time Objective, RTO).
● How the Activity 4 roles, memberships, and privileges will be recreated after a restore, because roles are
cluster-wide and are not contained in a single-database dump. For this classroom activity, use a logical
backup with pg_dump and restore it with pg_restore when using the custom archive format. If your environment
or permissions require another approved method, document the reason. Part B - Create and Inspect a Backup For
each project, create a backup of its database. Use a PostgreSQL account with the required access. The
following examples are templates; replace placeholders with your actual database name, username, and file
path. pg_dump -U <username> -h localhost -p 5432 -Fc -d <database_name> -f <database_name>_activity6.dump
Record the command used, backup file name, file size, checksum (for example, from sha256sum), date/time, and
any errors. Do not place a password directly in the command or commit it to the repository. Use a secure
prompt or an approved credential method. Keep the backup file in a protected local location and do not commit
it to any repository. Inspect the archive contents: pg_restore --list <database_name>_activity6.dump Explain
what the listing indicates and why a backup file existing on disk is not, by itself, proof of successful
recovery. Part C - Restore to a Separate Test Database For each project, create a new, empty test database
with a distinct name. Do not restore over the original database. Restore the backup into the test database
using the appropriate PostgreSQL tools. createdb -U <admin_username> -h localhost -p 5432
<restore_test_database> COMP 018 - Database Administration | Activity 6 - Page 2

## Page 3

COMP 018 - DATABASE ADMINISTRATION pg_restore -U <admin_username> -h localhost -p 5432 -d
<restore_test_database> <database_name>_activity6.dump If the archive includes ownership or privilege settings
that do not fit the test environment, use an instructor-approved restore approach and document the options
used. Do not blindly add options that suppress errors; investigate and explain any warnings or failures. After
restoration, verify at least the following: ● Expected tables and important database objects exist. ● Expected
sample records are present in selected tables. ● Primary keys, foreign keys, and other important constraints
are present. ● The Activity 4 roles, memberships, and privileges are in place or have been recreated from your
Activity 4 scripts, and one permitted and one denied operation behave as expected. ● A representative SELECT
query returns expected results. ● The application can connect to the restored database if application-level
verification is feasible. ● Any limitations, missing objects, or permission differences are documented. Part D
- Controlled Recovery Simulation Using only the restored test database, select a small set of disposable test
records or create a clearly identified test record. Record the original state, then simulate a simple incident
such as deleting that test record. Recover by restoring the backup into a fresh recovery database or by using
a carefully planned table-level recovery procedure. Compare the recovered state with your recorded expected
state. Recommended safe approach: keep the original database untouched, preserve the initial backup, and
restore into a second disposable database for comparison. Do not drop tables or delete real application data.
● Describe the simulated incident and its intended scope. ● Show the state before the incident and after the
simulated loss. ● Explain the recovery method and why it was selected. ● Verify whether the expected record or
data was recovered. ● Identify what would be different if the incident occurred after the most recent backup.
Part E - Recovery Evaluation and Report Submit a report for each project explaining the backup and restore
process, the verification results, and the recovery simulation. Include a brief evaluation of whether the
backup method and frequency would be sufficient for a real system with different data-loss and downtime
requirements. ● Backup and restore commands used, with placeholders removed from the report only where safe;
never disclose credentials. ● Screenshots or command output showing backup creation and archive inspection. ●
Evidence of restoration into the separate test database. ● Verification results for objects, records,
constraints, and representative queries. ● Incident simulation timeline and recovery outcome. ● Limitations,
errors encountered, and recommendations for improving recovery readiness. Combine the project reports into the
group's PDF progress documentation (see Part F). Part F - Repository, Tracker, and Progress Documentation As
in Activities 3 to 5, there is no centralized repository. Each group keeps its Activity 6 work in its own
project repository and records its status in the class Google Sheets tracker. The group then submits a PDF
that documents all of its progress. COMP 018 - Database Administration | Activity 6 - Page 3

## Page 4

COMP 018 - DATABASE ADMINISTRATION Step 1 - Keep your work in your own repository 1. Create a folder such as
db-backup-recovery/ in your group's own repository, with one subfolder per project (for example,
db-backup-recovery/group-03/) containing that project's backup plan, commands or scripts, checksums,
verification queries, and report. 2. Do not commit backup files that contain data. Store them in a protected
local location and record only the file name, size, and checksum. 3. Use meaningful commits and do not commit
passwords or secrets. Use placeholders in scripts and keep real credentials in local configuration. 4. Do not
change any other group's repository. Send findings and recommendations to each owning group as feedback
instead. Step 2 - Update the Google Sheets tracker Keep your group's Activity 3 row up to date. In addition,
add a tab named Activity 6 Log to the tracker with one row for every project your group backs up, using the
columns below. Edit only your own group's rows. Activity 6 Log column What to enter Project Group number and
project name of the database backed up. Database and backup file Database name, backup file name, size, and
checksum (not the file itself). Backup method For example, pg_dump custom format, with the date and time of
the backup. Restore test result Success, Success with issues, or Failed, with a short note. Access control
after restore Yes or No: Activity 4 roles and privileges verified in the restored database. Recovery
simulation result Recovered, Partly recovered, or Not recovered, with a short note. Proposed RPO and RTO The
recovery objectives your group proposed for a real deployment. Evidence folder link Link to that project's
subfolder in your own repository. Feedback sent to owners Yes or No, with the date feedback was sent to the
owning group. PDF progress document Link to your group's PDF progress documentation (same link on every row).
Last updated Date of the most recent update by your group. Step 3 - Submit the PDF progress documentation
Continue the PDF progress document from Activities 3 to 5 by adding the sections below, or submit a separate
PDF for this activity. Submit it together with the link to your repository. Section Contents Cover and links
Group number, members, repository link, and tracker link. Projects covered Table of every project, its
repository link, database name, and the accounts used. Backup plan Objects, method, storage, access,
verification, schedule, retention, RPO, and RTO for each project. Backup creation and inspection Commands,
file name, size, checksum, and archive listing evidence. Restoration and verification Evidence of restoration
to the separate test database and the checks of objects, records, constraints, and queries. Access control
after restore How the Activity 4 roles and privileges were recreated and tested. Recovery simulation Incident
scope, timeline, recovery method, and comparison with the expected state. COMP 018 - Database Administration |
Activity 6 - Page 4

## Page 5

COMP 018 - DATABASE ADMINISTRATION Section Contents Evaluation and recommendations Whether the method and
frequency would suit a real system, and how to improve recovery readiness. Limitations and errors Errors,
warnings, and permission limits met, and how they were handled. Feedback to owners Findings and
recommendations sent to each owning group. AI usage declaration AI tools used, tasks performed with them, and
how commands were validated. The PDF must not contain real passwords or other secrets. Check screenshots and
logs to confirm that no credentials are visible. IV. Required Deliverables ● Backup plan - Proposed schedule,
retention, RPO, and RTO for each project, including how Activity 4 roles will be recreated. ● Backup files and
commands - The backup files, stored securely and not committed, with the documented backup commands and
checksums in the group's own repository. ● Restore verification evidence - Evidence of restoration into a
separate test database and verification of objects, data, constraints, and access control. ● Controlled
recovery simulation report - The incident, recovery method, and outcome for each project. ● Final backup,
restoration, and recovery report - A report for each project, compiled into the PDF progress documentation. ●
Progress documentation (PDF) - A PDF recording all of the group's Activity 6 progress, submitted with the
repository link and recorded in the Google Sheets tracker. ● AI usage declaration - AI assistance used and how
commands were validated. V. Assessment Rubric Criteria Points Backup plan, RPO/RTO, and retention rationale 15
Backup creation and archive inspection 20 Restoration to a separate test database 20 Verification of objects,
data integrity, and access control 15 Controlled recovery simulation and evaluation 15 Evidence and AI
validation 5 Own repository, tracker update, and PDF progress documentation 10 Total 100 A backup that was
never restored should not receive full credit. The PDF progress documentation must be supported by the
evidence and commit history in the group's own repository. VI. Submission Checklist ☐ Backup plans for every
other group's project identify database, storage, schedule, retention, RPO, RTO, and how Activity 4 roles are
recreated. ☐ Backup was created and its archive listing was inspected. COMP 018 - Database Administration |
Activity 6 - Page 5

## Page 6

COMP 018 - DATABASE ADMINISTRATION ☐ Restore was performed in a separate test database. ☐ Tables, records,
constraints, access control, and a representative query were verified. ☐ Recovery simulation used only
disposable test data. ☐ The original databases and backups were preserved. ☐ Evidence, limitations, and
recommendations are included. ☐ Backup files were stored securely and were not committed to any repository. ☐
The scripts and evidence are in the group's own repository, and the Activity 6 Log in the tracker is updated.
☐ The PDF progress documentation is complete and contains no secrets. ☐ No secrets or real credentials were
submitted. ☐ AI use is declared and commands were validated. Important Safety Reminder A backup is not proven
reliable until restoration has been tested. Keep the original database and backup unchanged during this
activity. Never run destructive recovery tests on a production system or on the only copy of a group's
project. Do not commit backup files that contain data to any repository. COMP 018 - Database Administration |
Activity 6 - Page 6
