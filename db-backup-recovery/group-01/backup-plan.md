# Backup Plan

**TEMPLATE ONLY — no project has been identified and no backup has been created.**

## Scope and method

- Group/project/repository: <GROUP_NUMBER> - <PROJECT_NAME> / <REPOSITORY_URL>
- Database and schema/object scope: <DATABASE_NAME> / <SCHEMA_TABLES_SEQUENCES_OTHER_OBJECTS>
- PostgreSQL server / `pg_dump` version: <SERVER_VERSION> / <CLIENT_VERSION>
- Method: PostgreSQL logical backup with `pg_dump` custom archive (`-Fc`), subject to target compatibility.
- Rationale: custom format supports `pg_restore` archive inspection and selective restore; validate suitability against the actual project and PostgreSQL versions.
- Activity 4 backup account and application role: <A4_BACKUP_ACCOUNT> / <APPLICATION_ROLE>
- Account must not be the application runtime account. Document the minimum privileges and permission limitations.

## Storage, access, and verification

- Protected local directory outside all repositories: <APPROVED_LOCAL_PATH>
- Authorized storage readers/writers: <AUTHORIZED_PEOPLE_OR_ROLES>
- Credential handling: <APPROVED_LOCAL_METHOD_ONLY; NEVER RECORD CREDENTIALS>
- Verification: archive listing; SHA-256; restore into a new empty test database; verify objects, data, constraints, sequences, roles/privileges, and representative permitted/denied behavior.
- Dump files contain data. Keep them outside Git and outside the submission ZIP.

## Schedule, retention, objectives

- Proposed schedule: <JUSTIFIED_SCHEDULE>
- Retention: <JUSTIFIED_RETENTION>
- RPO and rationale: <RPO_AND_PROJECT_SPECIFIC_RATIONALE>
- RTO and rationale: <RTO_AND_PROJECT_SPECIFIC_RATIONALE>
- Classroom activity retention/disposal: <APPROVED_POLICY>

## Role recreation and restore

Database roles are cluster-wide and are not contained in a single-database dump. After restore, recreate/reapply Activity 4 roles, memberships, database/schema/table/sequence/default privileges, security restrictions, and verification tests using the owning project's documented scripts and an instructor-approved setup account. Record limitations; do not bypass privileges.

## Execution record

- Backup date/time and timezone: <NOT_RUN>
- Backup filename, size, SHA-256: <NOT_CREATED>
- Archive listing: [archive-listing.txt](archive-listing.txt) — template only.
- Restore test/recovery result: <NOT_RUN>
- Errors or limitations: <NOT_RUN>
