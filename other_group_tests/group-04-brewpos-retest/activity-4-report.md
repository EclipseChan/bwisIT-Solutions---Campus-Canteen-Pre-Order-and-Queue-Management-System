# Activity 4 — Access control

**Status: Passed with issues**  
**Run date:** 2026-11-05  
**Scope:** Review and execution of `database/05_create_app_role.sql` in a disposable database, followed by live privilege and authentication checks. No shared-server or production settings were changed.  
**Environment:** Isolated PostgreSQL 18.6 cluster on `127.0.0.1:55457`; database `grp_brewposdb`; admin `retest_admin`; application role `brewpos_app`; test-only passwords (not reproduced here).

## Results

| Check | Result |
|---|---|
| Role script executes | **PASS** — `DO` plus `ALTER ROLE`, `GRANT`, and `REVOKE` statements completed. |
| Script is re-runnable | **PASS** — second run emitted `NOTICE: Role brewpos_app already exists; non-superuser attributes verified` and completed without error. |
| Role attributes | **PASS** — `LOGIN=true`; `SUPERUSER`, `CREATEROLE`, `CREATEDB`, `REPLICATION`, `BYPASSRLS` all `false`; no connection limit; no password expiry. |
| Role/database settings | **PASS** — on `grp_brewposdb`: `search_path=public`, `statement_timeout=30s`, `lock_timeout=10s`. |
| Schema access | **PASS** — `public` USAGE granted; CREATE **denied**. |
| Table privileges | **PASS** — exactly as documented (matrix below). |
| Sequence privileges | **PASS** — USAGE and SELECT granted on all four sequences; UPDATE denied. |
| Allowed runtime writes | **PASS** — category/item CRUD and order/line inserts succeeded inside a rolled-back transaction; temporary rows were gone afterwards. |
| Historical-order immutability | **PASS** — `UPDATE`, `DELETE`, and `TRUNCATE` on `order_ticket` denied; `UPDATE`/`DELETE` on `order_line_item` denied. |
| Staff mutation | **PASS** — `INSERT`, `UPDATE`, and `DELETE` on `staff` denied; SELECT allowed. |
| DDL | **PASS** — `CREATE`, `ALTER`, and `DROP` denied (SQLSTATE `42501`). |
| Password authentication | **PASS** — correct password accepted; wrong password and missing password rejected; passwords stored as `SCRAM-SHA-256`; `pg_hba.conf` uses `scram-sha-256`. |
| Unrelated database CONNECT | **ISSUE (PostgreSQL default)** — `brewpos_app` can connect to `postgres` and `template1`. Explained below; not an application-granted privilege. |
| Default privileges | **ISSUE (operational)** — `pg_default_acl` has 0 rows; only existing objects are covered. See issue 2. |

### Table privilege matrix (`true` = granted)

| Table | SELECT | INSERT | UPDATE | DELETE | TRUNCATE |
|---|---|---|---|---|---|
| `menu_category` | yes | yes | yes | yes | no |
| `menu_item` | yes | yes | yes | yes | no |
| `order_ticket` | yes | yes | **no** | **no** | no |
| `order_line_item` | yes | yes | **no** | **no** | no |
| `staff` | yes | **no** | **no** | **no** | no |

### Sequence privilege matrix

| Sequence | USAGE | SELECT | UPDATE |
|---|---|---|---|
| `menu_category_category_id_seq` | yes | yes | no |
| `menu_item_item_id_seq` | yes | yes | no |
| `order_ticket_order_id_seq` | yes | yes | no |
| `staff_staff_id_seq` | yes | yes | no |

## Denials observed

All expected denials returned SQLSTATE `42501` (`insufficient_privilege`), including:

- `UPDATE`, `DELETE`, `TRUNCATE` on `order_ticket`
- `UPDATE`, `DELETE` on `order_line_item`
- `INSERT`, `UPDATE`, `DELETE` on `staff`
- `CREATE`, `ALTER`, `DROP` of schema objects

The application role could still read `staff` (2 rows) and `order_ticket` (7 rows), which the app needs.

## Allowed operations observed

Inside one transaction that was rolled back, `brewpos_app` created and updated a category and item, deleted them, then inserted an order with a line item. All statements succeeded and the rollback removed every temporary row. This matches the runtime workload: menu maintenance plus append-only order history.

## PostgreSQL defaults and test-cluster scope

- **Cross-database CONNECT is a PostgreSQL default, not an app grant.** New databases grant `CONNECT` and `TEMP` to `PUBLIC` unless changed. `postgres` and `template1` have no explicit `datacl`, so the default applies; `template0` has `datallowconn=false`. The role script does not grant cross-database access. It is therefore not evidence of an application defect. Hardening would require a deliberate `REVOKE CONNECT ... FROM PUBLIC` (or per-role/database grants), which was **not** applied because the prompt forbids changing shared-server global defaults and the supplied documentation does not require it.
- **No default privileges are defined.** `pg_default_acl` is empty, so the script's `GRANT ... ON ALL TABLES/SEQUENCES` covers only objects that exist when it runs. A future migration that adds a table or sequence will need an explicit grant (or `ALTER DEFAULT PRIVILEGES`), otherwise the app role will receive `42501`. This is an operational maintenance risk, not a current test failure.
- **Scope.** These results describe this disposable cluster only. Role attributes and role/database settings are cluster-global; they are not carried by a database dump and were not compared to production.

## Issues and blockers

1. **`brewpos_app` can connect to `postgres` and `template1`.** Verified with a correct password; the server log shows `connection authorized` for both. This is PostgreSQL's default `PUBLIC` CONNECT behaviour and lies outside the supplied role script. Severity is low for this exercise but worth documenting for any hardened deployment.
2. **No default privileges.** New tables/sequences will not be usable by `brewpos_app` until granted explicitly. The current schema is fully covered; future schema changes are not.
3. **Password handling.** The role script sets/expects a password externally. The test set one at runtime; no password appears in this report or its evidence. The stored verifier is SCRAM-SHA-256, not plaintext.
4. **Isolation.** The unrelated PostgreSQL services on ports 5432 and 5433 were not touched.

## Verdict

The supplied role script enforces the intended least-privilege model for existing objects and correctly blocks historical-order and staff mutation. The two issues are PostgreSQL defaults/operational scope, not functional access-control failures, so the activity is **Passed with issues**.

## Evidence

- Role and privilege introspection: [`evidence/activity4-introspection.log`](evidence/activity4-introspection.log)
- Idempotent re-run: [`evidence/activity4-role-rerun.log`](evidence/activity4-role-rerun.log)
- Allowed operations (rolled back): [`evidence/activity4-allowed.log`](evidence/activity4-allowed.log)
- Expected denials (`42501`): [`evidence/activity4-denied.log`](evidence/activity4-denied.log)
- Authentication, cross-database connections, `pg_hba.conf`, server log: [`evidence/activity4-auth-and-connections.log`](evidence/activity4-auth-and-connections.log)
- SQL used: [`evidence/activity4-introspection.sql`](evidence/activity4-introspection.sql), [`evidence/activity4-allowed.sql`](evidence/activity4-allowed.sql), [`evidence/activity4-denied.sql`](evidence/activity4-denied.sql)
