# Activity 4 — Park-It access-control report

**Run date:** 2026-11-05  
**Environment:** Disposable local PostgreSQL 18.6 cluster, bound to `127.0.0.1:55439`; database `park_it_a4a6_test`. The repository's `schema.sql` and `seed.sql` were loaded into this isolated database. No pre-existing PostgreSQL service or peer database was changed.

## Scope and assumptions

The archive's access-control SQL belongs to CampusSafe, not Park-It, and was not run. Park-It has no app-specific access-control plan. For this isolated test only, roles were inferred from the Park-It `server.js`: its database routes operate on `parking_zone`; the other tables have no corresponding application routes in the supplied server file. Therefore the proposed runtime role is limited to that table, the reporting role can read that table, and the backup role can read the tables and sequences. This is a test policy, not an owner-approved production design.

## Results

| Check | Result |
|---|---|
| Application and schema setup | PASS — 5 public tables, 5 sequences, and one seeded parking zone loaded. |
| Group/login roles and memberships | PASS — three `NOLOGIN` groups and three `LOGIN` accounts with intended memberships. |
| Elevated role attributes | PASS — test logins are not superusers and have no `CREATEDB`, `CREATEROLE`, replication, or RLS-bypass attributes. |
| Runtime allowed operations | PASS — `park_it_app` selected, inserted, updated, and deleted a transient test zone inside a rolled-back transaction. |
| Runtime least privilege | PASS — no table access to `payment`; no `CREATE` on `public`; no access to `staff_user`. |
| Read-only role | PASS — can select `parking_zone`; INSERT, UPDATE, DELETE, and SELECT on `staff_user` were denied. |
| Backup role | PASS — read access to all application tables/sequences; it was subsequently able to create a custom-format dump. |
| Database/schema/sequence access | PASS — target database CONNECT and schema USAGE were granted; schema CREATE was denied. Runtime sequence access supported generated IDs. |
| Unrelated database access | PASS — the test roles were denied CONNECT to `postgres` and `template1` in the isolated cluster. |
| Default privileges | OPEN — no explicit default ACL entries were found for `public`; the grants cover current objects only. Future objects need reviewed grants or default-privilege rules. |

Expected denials were verified using real PostgreSQL errors. They were not counted as test failures.

## Evidence and scripts

- [Role creation and database grants](cluster-roles.sql)
- [Schema, table, and sequence grants](database-privileges.sql)
- [Allowed-operation transaction](allowed-operations.sql)
- [Supplemental psql output](activity4-results.txt)
- [Default ACL and schema checks](additional-checks.txt)
- [Server log excerpt](../activity5-park-it/activity5-server-log-summary.txt)

**Limitations:** Successful results apply only to this temporary role design and database. The project owners' intended roles and reporting requirements were not provided, so production-equivalent Activity 4 compliance remains unverified. Login connections used the temporary cluster's loopback-only `trust` authentication; password-based authentication was not tested.
