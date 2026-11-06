-- TEMPLATE ONLY — tailor to a real target table after reviewing its schema
-- and statistics. No maintenance command has been run.
-- Project: <GROUP_NUMBER> - <PROJECT_NAME>
-- Database: <DATABASE_NAME>
-- Account / application role: <A4_MAINTENANCE_ACCOUNT> / <APPLICATION_ROLE>
-- Selected table: <SCHEMA>.<TABLE_NAME>
-- Rationale and approval: <RATIONALE_AND_APPROVAL>
--
-- Run in an authorized test/maintenance window. VACUUM must not run inside
-- a transaction block. Do not use VACUUM FULL unless the instructor approves.

-- Pre-maintenance review (tailor schema filters to the target project):
SELECT schemaname, relname, n_live_tup, n_dead_tup, seq_scan, idx_scan,
       last_vacuum, last_autovacuum, last_analyze, last_autoanalyze
FROM pg_stat_user_tables
ORDER BY schemaname, relname;

SELECT schemaname, relname,
       pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_catalog.pg_statio_user_tables
ORDER BY pg_total_relation_size(relid) DESC;

SELECT schemaname, tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname NOT IN ('information_schema', 'pg_catalog')
ORDER BY schemaname, tablename, indexname;

-- Replace both identifiers with verified names before running:
ANALYZE <SCHEMA>.<TABLE_NAME>;

-- Run this as a standalone statement, not in a transaction:
VACUUM (VERBOSE, ANALYZE) <SCHEMA>.<TABLE_NAME>;
