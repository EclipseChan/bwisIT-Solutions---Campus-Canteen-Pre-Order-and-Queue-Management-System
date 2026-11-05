\echo === version and uptime ===
SELECT version();
SELECT pg_postmaster_start_time() AS postmaster_start,
       now() - pg_postmaster_start_time() AS uptime;

\echo === database size ===
SELECT current_database() AS database,
       pg_size_pretty(pg_database_size(current_database())) AS size_pretty,
       pg_database_size(current_database()) AS size_bytes;

\echo === transaction and I/O counters for this database ===
SELECT datname, numbackends, xact_commit, xact_rollback, blks_read, blks_hit,
       tup_returned, tup_fetched, tup_inserted, tup_updated, tup_deleted,
       conflicts, temp_files, temp_bytes, deadlocks, stats_reset
FROM pg_stat_database WHERE datname = current_database();

\echo === current sessions on this database ===
SELECT usename, application_name, state, count(*) AS sessions
FROM pg_stat_activity WHERE datname = current_database()
GROUP BY usename, application_name, state ORDER BY usename, application_name, state;

\echo === transaction ID age (wraparound health) ===
SELECT datname, age(datfrozenxid) AS xid_age
FROM pg_database WHERE datname IN ('grp_brewposdb','postgres','template1') ORDER BY datname;

\echo === table statistics ===
SELECT relname, n_live_tup, n_dead_tup, n_tup_ins, n_tup_upd, n_tup_del,
       seq_scan, idx_scan, last_vacuum, last_autovacuum, last_analyze, last_autoanalyze
FROM pg_stat_user_tables ORDER BY relname;

\echo === index statistics ===
SELECT relname, indexrelname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes ORDER BY relname, indexrelname;

\echo === row counts ===
SELECT 'staff' AS table_name, count(*) FROM public.staff
UNION ALL SELECT 'menu_category', count(*) FROM public.menu_category
UNION ALL SELECT 'menu_item', count(*) FROM public.menu_item
UNION ALL SELECT 'order_ticket', count(*) FROM public.order_ticket
UNION ALL SELECT 'order_line_item', count(*) FROM public.order_line_item
ORDER BY 1;

\echo === relevant server settings ===
SELECT name, setting FROM pg_settings
WHERE name IN ('autovacuum','autovacuum_naptime','autovacuum_vacuum_threshold',
               'autovacuum_analyze_threshold','log_connections','log_disconnections',
               'log_statement','log_min_duration_statement','log_destination',
               'logging_collector','archive_mode','wal_level','max_connections')
ORDER BY name;

\echo === installed extensions ===
SELECT extname, extversion FROM pg_extension ORDER BY extname;

\echo === maintenance: ANALYZE VERBOSE ===
ANALYZE VERBOSE;

\echo === maintenance: VACUUM (VERBOSE, ANALYZE) ===
VACUUM (VERBOSE, ANALYZE);

\echo === table statistics after maintenance ===
SELECT relname, n_live_tup, n_dead_tup, seq_scan, idx_scan, last_vacuum, last_autovacuum, last_analyze, last_autoanalyze
FROM pg_stat_user_tables ORDER BY relname;

\echo === documented daily-sales query ===
SELECT COALESCE(SUM(l.quantity * l.sold_price), 0) AS net_sales,
       COUNT(DISTINCT t.order_id) AS completed_orders
FROM public.order_ticket t
JOIN public.order_line_item l ON l.order_id = t.order_id
WHERE t.order_timestamp >= CURRENT_DATE
  AND t.order_timestamp <  CURRENT_DATE + 1;

\echo === daily-sales query plan (EXPLAIN ANALYZE executes the read-only query) ===
EXPLAIN (ANALYZE, BUFFERS, FORMAT TEXT)
SELECT COALESCE(SUM(l.quantity * l.sold_price), 0) AS net_sales,
       COUNT(DISTINCT t.order_id) AS completed_orders
FROM public.order_ticket t
JOIN public.order_line_item l ON l.order_id = t.order_id
WHERE t.order_timestamp >= CURRENT_DATE
  AND t.order_timestamp <  CURRENT_DATE + 1;
