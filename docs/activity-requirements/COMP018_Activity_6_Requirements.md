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
