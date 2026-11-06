# Activity 6 — Backup and recovery

**Status: Passed with issues**  
**Run date:** 2026-11-05  
**Scope:** Custom-format logical dump outside the repository; archive inspection; restore into a **new** disposable database; schema/data comparison; post-backup marker check; constraint and ACL checks. Backup scheduling, retention, encryption, and off-site storage are out of scope.  
**Environment:** Isolated PostgreSQL 18.6 cluster `127.0.0.1:55457`; source `grp_brewposdb`; restore target `grp_brewposdb_restore`. The source database was never overwritten.

## Results

| Check | Result |
|---|---|
| Custom-format dump | **PASS** — `pg_dump -Fc`; exit 0; **17,199 bytes**; SHA-256 `5EB39D9FA0BE9B5FD7BC9C274906B087C2FB8401EC9587844AD47D379581F25C`. |
| Dump location | **PASS** — written outside the repository and **deleted after size/hash capture**; only metadata retained. |
| Archive inspection | **PASS** — 55 TOC entries, gzip compression, dump version `1.16-0`, format `CUSTOM`, dumped from/with PostgreSQL 18.6. |
| Cluster-global role scan | **PASS (documented limitation)** — no `CREATE/ALTER/DROP ROLE` statements; only object `GRANT`s for `brewpos_app`. |
| Restore | **PASS** — `pg_restore --verbose` into a newly created empty DB; exit 0. |
| Schema/data comparison | **PASS** — normalized inventories identical: tables, indexes, constraints, sequences (names and `last_value`), column metadata, per-table data MD5, row counts, and total sales. |
| Post-backup marker | **PASS** — marker present in source (1 row, 5 categories), absent in restore (0 rows, 4 categories). |
| Restored privileges | **PASS** — table/sequence matrices match Activity 4; app role can read restored data (`staff=2`, `orders=7`). |
| Restored constraints | **PASS** — invalid staff role, duplicate category, orphan line, negative price, and zero quantity all rejected; a valid write succeeded and was rolled back. |

### Restored data snapshot

`staff=2`, `menu_category=4`, `menu_item=12`, `order_ticket=7`, `order_line_item=12`; total sales `1811.00`. These are the Activity 3 test values present at dump time, not the older 2/3/11/5/9 counts from the prior run.

### Marker test

A `menu_category` row named `Post-Backup Marker` was inserted **after** the dump completed:

| Database | Marker rows | Categories |
|---|---:|---:|
| Source `grp_brewposdb` | 1 | 5 |
| Restore `grp_brewposdb_restore` | 0 | 4 |

This demonstrates the restore reflects the dump's point-in-time snapshot, not later source changes.

### Role and privilege scope

The archive is a **database-only** dump. It contains:

- `GRANT USAGE ON SCHEMA public TO brewpos_app`
- `GRANT SELECT,INSERT,DELETE,UPDATE` on `menu_category` and `menu_item`
- `GRANT SELECT,INSERT` on `order_ticket` and `order_line_item`
- `GRANT SELECT` on `staff`
- `GRANT SELECT,USAGE` on the four ID sequences

It does **not** contain `CREATE ROLE`, role memberships, role attributes, or role/database settings; those are cluster-global. Here `brewpos_app` already existed, so the ACL replay succeeded. On a fresh cluster without that role, the `GRANT` statements would fail until the role is created separately. This limitation is documented rather than hidden.

## Issues and limitations

1. **Cluster-global objects are not backed up.** Roles, memberships, role attributes, and `pg_db_role_setting` entries are outside a database dump. A disaster-recovery runbook must recreate `brewpos_app` (or an equivalent) before restoring, or restore will report missing-role errors. Activity 4 settings (`search_path`, timeouts) are also cluster-scoped and were not carried over.
2. **No backup automation was tested.** This was a single manual dump. Scheduling, retention, encryption at rest/in transit, off-site copies, monitoring of dump failures, and restore drills were not supplied and cannot be inferred from one run.
3. **Same cluster/version restore.** The restore was tested on the same PostgreSQL 18.6 cluster. Cross-version or cross-platform restore was not exercised.
4. **The data-bearing dump was intentionally deleted.** Only its size, SHA-256, archive inventory, and comparison evidence remain. The hash identifies the artifact but cannot restore it; a real backup must be retained in an approved backup store.
5. **Ownership.** The restore was performed as `retest_admin`; the archive's object ACLs were replayed for `brewpos_app`. A production restore may need explicit ownership mapping.

## Verdict

The custom dump was created, inspected, restored into a separate database without touching the source, matched the source snapshot, excluded a post-backup marker, preserved ACLs/constraints, and was removed after its metadata was recorded. The remaining issues are inherent limitations of database-only dumps and untested operational backup policy, so the activity is **Passed with issues**.

## Evidence

- Dump size/SHA-256 and deletion: [`evidence/activity6-dump-metadata.log`](evidence/activity6-dump-metadata.log)
- Archive inventory (55 TOC entries): [`evidence/activity6-archive-list.log`](evidence/activity6-archive-list.log)
- Role/ACL scan of the archive: [`evidence/activity6-role-and-grant-scan.log`](evidence/activity6-role-and-grant-scan.log)
- Restore log: [`evidence/activity6-restore.log`](evidence/activity6-restore.log)
- Source vs restore comparison: [`evidence/activity6-comparison.log`](evidence/activity6-comparison.log)
- Source/restore inventories: [`evidence/activity6-source-inventory.log`](evidence/activity6-source-inventory.log), [`evidence/activity6-restore-inventory.log`](evidence/activity6-restore-inventory.log)
- Post-backup marker: [`evidence/activity6-marker.log`](evidence/activity6-marker.log)
- Restored privileges/role scope: [`evidence/activity6-restore-privileges.log`](evidence/activity6-restore-privileges.log)
- Constraint probes: [`evidence/activity6-constraint-probes.log`](evidence/activity6-constraint-probes.log)
- Pre-dump cleanup: [`evidence/activity6-pre-dump-cleanup.log`](evidence/activity6-pre-dump-cleanup.log)
