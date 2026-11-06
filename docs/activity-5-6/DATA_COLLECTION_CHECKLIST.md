# Activity 5/6 Data Collection Checklist

**Status:** TEMPLATE — the class tracker URL and other-group project inventory are not yet available. Collect only non-secret identifiers and authorized operating instructions. Never request or record passwords, tokens, complete credential-bearing connection strings, or `.env` contents.

## From the class tracker

- [ ] Every other group's group number and project name.
- [ ] The repository URL for each project.
- [ ] The database name for each project, if the tracker records it.
- [ ] Owner/contact name or approved contact method for each project.
- [ ] Tracker's Activity 5/6 status, evidence links, and project reachability notes, if present.
- [ ] The tracker URL and the exact Activity 5 Log / Activity 6 Log column requirements.
- [ ] Any instructor directions that limit which groups or environments may be inspected.

## From each group's README

- [ ] Confirm the project identity and repository URL.
- [ ] Database platform and supported PostgreSQL version(s).
- [ ] Database name and schema(s), if documented.
- [ ] Approved setup, connection, and test-environment instructions.
- [ ] Documented backup, restore, logging, or maintenance constraints.
- [ ] The repository branch or documented project version to which the findings apply.

## From each group's user-roles documentation

- [ ] Activity 4 database account names (names only; no passwords).
- [ ] Application role served by each account and its intended purpose.
- [ ] Which account is authorized for read-only inspection, maintenance, backup, and restore.
- [ ] Allowed and denied operations and any stated privilege boundaries.
- [ ] Approved local credential-delivery method (environment variable, `.pgpass`, or interactive prompt); never collect the credential itself.

## From each group's database setup files

- [ ] Database and schema creation names and object scope.
- [ ] PostgreSQL version assumptions and any extension requirements.
- [ ] Role creation, membership, migration, seed, and privilege application order.
- [ ] Table, sequence, constraint, and index definitions needed to tailor verification queries.
- [ ] Whether setup scripts create, alter, reset, or drop objects; identify any destructive operations.
- [ ] Existing health, maintenance, backup, restore, or logging scripts and their documented usage.
- [ ] Required non-secret connection parameter names and approved local credential method.

## From each group's Activity 4 documentation

- [ ] Role/account-to-application-role mapping.
- [ ] Granted and denied privileges, including database creation/connect restrictions.
- [ ] Privilege-verification test cases and expected outcomes.
- [ ] Permission limitations relevant to `pg_stat_activity`, logs, maintenance, backup, or restore.
- [ ] Approved account to own a separate disposable restore/recovery database.
- [ ] Whether an instructor-approved setup/`CREATEDB` account is available.
- [ ] Any restrictions on changing logging configuration or generating safe test events.

## Confirm before connecting

- [ ] Owner/instructor authorization and project reachability confirmed.
- [ ] Account name, application role, and intended operation confirmed from documentation.
- [ ] Database name and server version confirmed without recording secrets.
- [ ] Separate test database creation method approved; original database will not be overwritten.
- [ ] Protected backup location outside every repository selected.
- [ ] Any inaccessible project is marked blocked, with the reason, rather than represented as inspected.
