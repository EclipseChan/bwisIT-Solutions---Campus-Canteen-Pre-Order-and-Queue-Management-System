-- TEMPLATE ONLY — tailor table/data checks to the target project.
-- No restore has been performed and no verification output exists.
-- Restored database: <DATABASE_NAME>_a6_restore_<YYYYMMDD>
-- Account / application role: <A4_RESTORE_ACCOUNT> / <APPLICATION_ROLE>

SELECT current_database() AS restored_database;

SELECT table_schema, count(*) AS base_table_count
FROM information_schema.tables
WHERE table_type = 'BASE TABLE'
  AND table_schema NOT IN ('information_schema', 'pg_catalog')
GROUP BY table_schema
ORDER BY table_schema;

SELECT n.nspname AS schema_name, c.relname AS table_name
FROM pg_class AS c
JOIN pg_namespace AS n ON n.oid = c.relnamespace
WHERE c.relkind IN ('r', 'p')
  AND n.nspname NOT IN ('information_schema', 'pg_catalog')
ORDER BY n.nspname, c.relname;

SELECT conrelid::regclass AS table_name, conname, contype,
       pg_get_constraintdef(oid) AS definition
FROM pg_constraint
WHERE connamespace NOT IN (
  'information_schema'::regnamespace,
  'pg_catalog'::regnamespace
)
ORDER BY conrelid::regclass::text, contype, conname;

SELECT schemaname, sequencename, last_value
FROM pg_sequences
WHERE schemaname NOT IN ('information_schema', 'pg_catalog')
ORDER BY schemaname, sequencename;

SELECT rolname, rolsuper, rolcreatedb, rolcreaterole, rolcanlogin
FROM pg_roles
WHERE rolname NOT LIKE 'pg\_%' ESCAPE '\'
ORDER BY rolname;

SELECT member.rolname AS member, parent.rolname AS granted_role
FROM pg_auth_members AS membership
JOIN pg_roles AS member ON member.oid = membership.member
JOIN pg_roles AS parent ON parent.oid = membership.roleid
ORDER BY 1, 2;

-- Add project-specific row counts, representative SELECT, and privilege checks
-- only after confirming the actual schema and Activity 4 documentation.
-- Test one allowed and one denied operation using approved accounts.
