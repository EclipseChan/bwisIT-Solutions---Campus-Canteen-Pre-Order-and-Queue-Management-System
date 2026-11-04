# Activity 6 Backup, Restore, and Recovery Report

**TEMPLATE ONLY — no project has been identified; no backup, restore, or recovery has been performed.**

## Project and environment

- Group/project/repository: <GROUP_NUMBER> - <PROJECT_NAME> / <REPOSITORY_URL>
- Database/schema/PostgreSQL version: <DATABASE_NAME> / <SCHEMA> / <VERSION>
- Activity 4 account/application role: <ACCOUNT> / <ROLE>
- Owner authorization and date: <REFERENCE>

## Backup creation and inspection

- Method, command, date/time, client/server versions: <ACTUAL_DETAILS>
- Protected dump filename, size, SHA-256: <ACTUAL_METADATA_ONLY>
- Archive-list interpretation (tables, sequences, constraints, indexes, ACLs/TOC entries): <ACTUAL_INTERPRETATION>
- Why a dump file alone does not prove recoverability: <EXPLANATION>
- Evidence: [checksums.txt](checksums.txt), [archive-listing.txt](archive-listing.txt)

## Restoration and verification

- Separate test database and setup approval: <ACTUAL_DETAILS>
- Restore command, output, warnings: <ACTUAL_REDACTED_OUTPUT>
- Objects, records, constraints, sequences: <ACTUAL_RESULTS>
- Activity 4 role recreation, memberships, privileges: <ACTUAL_RESULTS>
- Permitted and denied operations: <ACTUAL_RESULTS>
- Representative application SELECT and optional application connection: <ACTUAL_RESULTS>
- Evidence: [restore-verify.sql](restore-verify.sql), [restore-evidence.txt](restore-evidence.txt)

## Controlled recovery simulation

<ACTUAL_INCIDENT_SCOPE_BEFORE_AFTER_RECOVERY_COMPARISON_AND_RPO_IMPLICATIONS>

Evidence: [recovery-simulation.md](recovery-simulation.md)

## Limitations and errors

<ACTUAL_LIMITATIONS_AND_HOW_HANDLED>

## Recommendations and evaluation

<RECOVERY_READINESS_RECOMMENDATIONS_AND_WHETHER_METHOD_FREQUENCY_MEET_PROJECT_RPO_RTO>

## Owner feedback

Sent to <OWNER_OR_BLOCKED>; date: <DATE>; reference: <FEEDBACK_REFERENCE>.

Do not include credentials or data-bearing backup files. This report becomes evidence only after every statement is supported by actual authorized output.
