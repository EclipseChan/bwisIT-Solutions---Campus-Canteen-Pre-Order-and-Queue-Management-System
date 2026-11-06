SELECT current_database() AS database_name,
       version() AS server_version,
       pg_size_pretty(pg_database_size(current_database())) AS database_size;

SELECT count(*) AS public_tables
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE';

SELECT count(*) AS public_sequences
FROM information_schema.sequences
WHERE sequence_schema = 'public';

SELECT state, count(*) AS sessions
FROM pg_stat_activity
WHERE datname = current_database()
GROUP BY state
ORDER BY state;

SELECT relname AS table_name,
       n_live_tup AS estimated_live_rows,
       n_dead_tup AS estimated_dead_rows,
       last_vacuum,
       last_autovacuum,
       last_analyze,
       last_autoanalyze
FROM pg_stat_user_tables
WHERE schemaname = 'public'
ORDER BY relname;

SELECT rolname, rolcanlogin, rolsuper, rolcreatedb, rolcreaterole
FROM pg_roles
WHERE rolname LIKE 'park_it_%'
ORDER BY rolname;

SELECT current_setting('log_destination') AS log_destination,
       current_setting('logging_collector') AS logging_collector,
       current_setting('log_directory') AS log_directory,
       current_setting('log_filename') AS log_filename;
