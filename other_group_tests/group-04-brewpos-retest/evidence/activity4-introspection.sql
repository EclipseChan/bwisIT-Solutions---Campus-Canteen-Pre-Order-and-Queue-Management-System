\echo === role attributes ===
SELECT rolname, rolcanlogin, rolsuper, rolcreaterole, rolcreatedb, rolreplication, rolbypassrls, rolconnlimit, rolvaliduntil
FROM pg_roles WHERE rolname = 'brewpos_app';

\echo === role/database settings ===
SELECT d.datname, s.setconfig
FROM pg_db_role_setting s
LEFT JOIN pg_database d ON d.oid = s.setdatabase
WHERE s.setrole = (SELECT oid FROM pg_roles WHERE rolname = 'brewpos_app');

\echo === schema privileges ===
SELECT has_schema_privilege('brewpos_app','public','USAGE') AS schema_usage,
       has_schema_privilege('brewpos_app','public','CREATE') AS schema_create;

\echo === table privilege matrix (true = granted) ===
SELECT t.tablename,
       has_table_privilege('brewpos_app','public.'||t.tablename,'SELECT') AS sel,
       has_table_privilege('brewpos_app','public.'||t.tablename,'INSERT') AS ins,
       has_table_privilege('brewpos_app','public.'||t.tablename,'UPDATE') AS upd,
       has_table_privilege('brewpos_app','public.'||t.tablename,'DELETE') AS del,
       has_table_privilege('brewpos_app','public.'||t.tablename,'TRUNCATE') AS trunc
FROM pg_tables t WHERE t.schemaname = 'public' ORDER BY t.tablename;

\echo === sequence privileges ===
SELECT s.sequencename,
       has_sequence_privilege('brewpos_app','public.'||s.sequencename,'USAGE') AS usage,
       has_sequence_privilege('brewpos_app','public.'||s.sequencename,'SELECT') AS sel,
       has_sequence_privilege('brewpos_app','public.'||s.sequencename,'UPDATE') AS upd
FROM pg_sequences s WHERE s.schemaname = 'public' ORDER BY s.sequencename;

\echo === database connect privileges (all databases in this disposable cluster) ===
SELECT datname, datallowconn, datacl,
       has_database_privilege('brewpos_app',datname,'CONNECT') AS can_connect,
       has_database_privilege('brewpos_app',datname,'TEMP') AS can_temp
FROM pg_database ORDER BY datname;

\echo === configured default privileges (expect none) ===
SELECT count(*) AS default_acl_rows FROM pg_default_acl;
SELECT defaclrole::regrole AS owner_role, defaclnamespace::regnamespace AS schema, defaclobjtype AS object_type, defaclacl AS acl
FROM pg_default_acl;

\echo === password storage ===
SHOW password_encryption;
SELECT rolname, left(rolpassword, 13) AS password_prefix,
       rolpassword LIKE 'SCRAM-SHA-256$%' AS is_scram_sha_256
FROM pg_authid WHERE rolname = 'brewpos_app';
SHOW hba_file;

\echo === role membership ===
SELECT r.rolname AS member_role, g.rolname AS granted_role, m.admin_option
FROM pg_auth_members m
JOIN pg_roles r ON r.oid = m.member
JOIN pg_roles g ON g.oid = m.roleid
WHERE r.rolname = 'brewpos_app';
