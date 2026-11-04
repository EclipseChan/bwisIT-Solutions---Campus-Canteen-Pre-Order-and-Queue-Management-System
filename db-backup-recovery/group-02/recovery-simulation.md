# Controlled Recovery Simulation

**TEMPLATE ONLY — no incident has been simulated. Perform only on disposable restored/recovery databases; never modify the original database or destroy the initial backup.**

## Project

- Group/project: <GROUP_NUMBER> - <PROJECT_NAME>
- Database: <DATABASE_NAME>
- Restored test database: <DATABASE_NAME>_a6_restore_<YYYYMMDD>
- Fresh recovery database: <DATABASE_NAME>_a6_recovery_<YYYYMMDD>
- Protected backup filename/checksum: <FILE_NAME> / <SHA256>

## Incident scope

- Disposable test record/table/key: <TABLE> / <PRIMARY_KEY> / <IDENTIFIER>
- Why the record is disposable: <EXPLANATION>
- Original database untouched: <VERIFY>
- Initial backup preserved: <VERIFY>

## State before the incident

Exact query and actual output: <NOT_COLLECTED>

## Simulated loss

Exact command/statement and actual output: <NOT_RUN>

## State after the simulated loss

Exact query and actual output: <NOT_COLLECTED>

## Recovery method

<METHOD_AND_REASON>

## State after recovery

Exact query and actual output: <NOT_COLLECTED>

## Comparison

| Check | Expected | Recovered | Result |
|---|---|---|---|
| Record exists | <EXPECTED> | <ACTUAL> | <PASS_OR_FAIL> |
| Key fields match | <EXPECTED> | <ACTUAL> | <PASS_OR_FAIL> |
| Related rows/constraints intact | <EXPECTED> | <ACTUAL> | <PASS_OR_FAIL> |

## RPO implications

<WHAT_WOULD_DIFFER_IF_THE_INCIDENT_OCCURRED_AFTER_THE_LATEST_BACKUP>

## Limitations

<ACTUAL_WARNINGS_ERRORS_PERMISSION_LIMITS_OR_NONE_OBSERVED_WITH_SCOPE>
