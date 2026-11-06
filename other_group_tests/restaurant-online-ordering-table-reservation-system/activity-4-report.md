# Activity 4 — Access Control

**Status: Passed with issues**  
**Run date:** 2026-11-05  
**Test scope:** Review the supplied database role design and test allowed/denied access, least privilege, and data integrity.

## Environment and method

The project identifies itself as Binary Sisters' Restaurant Online Ordering & Table Reservation System. Its documented schema and role scripts were applied to a newly initialized PostgreSQL 18.6 cluster bound only to `127.0.0.1` on a temporary port. The existing PostgreSQL service was not used. The role matrix and CRUD suite were rerun from the supplied ZIP on 2026-11-05; see [retest evidence](activity4-evidence/retest-summary.txt).

Migrations `000`–`004`, seed data, and the role/grant scripts completed successfully in that isolated cluster. The seeded database contained eight tables, four views, seven sequences, 19 indexes, four user triggers, and two extensions.

## Results

- The supplied `database/roles/04_verify_privileges.sql` matrix reported **26 PASS, 0 FAIL**. Runtime, read-only, maintenance, backup, and DBA roles had their intended allowed/denied operations. No application role had `SUPERUSER`, `CREATEDB`, or `CREATEROLE`; group roles were `NOLOGIN`; no `PUBLIC` table grants remained.
- Direct database logins confirmed the runtime role can read menu data but cannot delete orders. The reporting role can read its approved view but cannot read customer password columns.
- The supplied `tests/crud_tests.sql` suite reported **25 PASS, 0 FAIL**, exit code 0. It ended with `ROLLBACK`; the seeded table counts remained unchanged.
- In the ZIP retest, the role matrix again reported **26 PASS, 0 FAIL**, and the CRUD suite reported **25 PASS, 0 FAIL**. The PHP connection check reached all eight tables using the runtime role; its details are in the [Activity 3 retest evidence](activity3-evidence/php-retest.txt).

Commands were run from the extracted project root, with `127.0.0.1:51584` pointing only to the retest cluster:

```powershell
psql -X -h 127.0.0.1 -p 51584 -U postgres -d grp_binarysisters_projectdb -v ON_ERROR_STOP=1 -f database/roles/04_verify_privileges.sql
psql -X -h 127.0.0.1 -p 51584 -U postgres -d grp_binarysisters_projectdb -v ON_ERROR_STOP=1 -f tests/crud_tests.sql
```

The direct login tests used PostgreSQL `trust` authentication on the isolated loopback-only cluster. They verify database role privileges, **not password authentication**. PHP-to-database connectivity was verified in the retest with temporary CLI extension overrides, but customer/staff authorization and end-to-end application flows were not tested.

## Issues and blockers

- The archive's `database/setup.ps1 -WithRoles` calls the absent `database/roles/03_set_passwords.psql` and does not check that command's exit code. The role tests therefore created and exercised login roles under local `trust` authentication; password configuration/authentication was not verified, and no credentials were used or recorded.
- The seeded data and role design were tested locally only. Production role configuration and real login authentication remain unverified.

## Evidence

- [Database provisioning and seeded inventory](activity4-evidence/database-provisioning-inventory.txt)
- [Role privilege matrix](activity4-evidence/privilege-matrix.txt)
- [CRUD and integrity test results](activity4-evidence/crud-tests.txt)
- [Runtime allowed read](activity4-evidence/runtime-login-allowed.txt)
- [Runtime denied delete](activity4-evidence/runtime-login-denied.txt)
- [Reporter allowed view read](activity4-evidence/report-login-allowed.txt)
- [Reporter denied credential read](activity4-evidence/report-login-denied.txt)
- [Missing role-password setup evidence](activity3-evidence/install-prerequisite-review.txt)
- [Role matrix and CRUD ZIP retest summary](activity4-evidence/retest-summary.txt)
