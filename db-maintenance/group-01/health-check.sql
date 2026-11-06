-- TEMPLATE ONLY — no command output or health result has been collected.
-- Project: <GROUP_NUMBER> - <PROJECT_NAME>
-- Database: <DATABASE_NAME>
-- Account: <A4_ACCOUNT>
-- Application role served: <APPLICATION_ROLE>
-- Tailor the schema filter to the target project's documented schema.

SELECT version() AS postgresql_version;
SELECT current_database() AS database_name;
SELECT pg_size_pretty(pg_database_size(current_database())) AS database_size;

SELECT table_schema, count(*) AS base_table_count
FROM information_schema.tables
WHERE table_type = 'BASE TABLE'
  AND table_schema NOT IN ('information_schema', 'pg_catalog')
GROUP BY table_schema
ORDER BY table_schema;

SELECT schemaname, count(*) AS index_count
FROM pg_indexes
WHERE schemaname NOT IN ('information_schema', 'pg_catalog')
GROUP BY schemaname
ORDER BY schemaname;

SELECT datname, numbackends, xact_commit, xact_rollback,
       blks_read, blks_hit,
       round(100.0 * blks_hit / nullif(blks_hit + blks_read, 0), 2) AS cache_hit_pct,
       deadlocks, conflicts, temp_files, temp_bytes
FROM pg_stat_database
WHERE datname = current_database();

-- Activity text can contain sensitive literal values. Do not save raw query text;
-- review only permitted metadata and redact before adding evidence.
SELECT pid, usename, application_name, state, wait_event_type, wait_event,
       now() - query_start AS duration, query_start
FROM pg_stat_activity
WHERE datname = current_database()
ORDER BY query_start NULLS LAST;

SELECT rolname, rolsuper, rolcreatedb, rolcreaterole, rolcanlogin,
       rolreplication, rolbypassrls
FROM pg_roles
WHERE rolname NOT LIKE 'pg\_%' ESCAPE '\'
ORDER BY rolname;

SELECT member.rolname AS member, parent.rolname AS granted_role
FROM pg_auth_members AS membership
JOIN pg_roles AS member ON member.oid = membership.member
JOIN pg_roles AS parent ON parent.oid = membership.roleid
ORDER BY 1, 2;
