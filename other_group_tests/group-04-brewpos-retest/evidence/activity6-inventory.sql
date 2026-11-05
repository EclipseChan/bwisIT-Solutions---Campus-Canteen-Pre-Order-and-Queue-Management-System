\echo === key counts (post-backup marker excluded from categories) ===
SELECT 'staff='||(SELECT count(*) FROM public.staff)||
       ' categories='||(SELECT count(*) FROM public.menu_category WHERE category_name <> 'Post-Backup Marker')||
       ' items='||(SELECT count(*) FROM public.menu_item)||
       ' orders='||(SELECT count(*) FROM public.order_ticket)||
       ' lines='||(SELECT count(*) FROM public.order_line_item) AS counts;

\echo === normalized schema inventory ===
SELECT 'tables='||COALESCE(string_agg(tablename, ',' ORDER BY tablename),'') FROM pg_tables WHERE schemaname='public';
SELECT 'indexes='||COALESCE(string_agg(indexname, ',' ORDER BY indexname),'') FROM pg_indexes WHERE schemaname='public';
SELECT 'constraints='||COALESCE(string_agg(conname||':'||contype::text, ',' ORDER BY conname),'')
FROM pg_constraint c JOIN pg_namespace n ON n.oid=c.connamespace WHERE n.nspname='public';
SELECT 'sequences='||COALESCE(string_agg(sequencename||'='||last_value, ',' ORDER BY sequencename),'')
FROM pg_sequences WHERE schemaname='public';
SELECT 'columns_md5='||md5(COALESCE(string_agg(table_name||'.'||column_name||':'||data_type||':'||is_nullable, ',' ORDER BY table_name, ordinal_position),''))
FROM information_schema.columns WHERE table_schema='public';

\echo === data fingerprints (post-backup marker excluded) ===
SELECT 'staff_md5='||md5(COALESCE(string_agg(staff_id||':'||full_name||':'||role, ',' ORDER BY staff_id),'')) FROM public.staff;
SELECT 'menu_category_md5='||md5(COALESCE(string_agg(category_id||':'||category_name, ',' ORDER BY category_id),'')) FROM public.menu_category WHERE category_name <> 'Post-Backup Marker';
SELECT 'menu_item_md5='||md5(COALESCE(string_agg(item_id||':'||item_name||':'||price||':'||is_active, ',' ORDER BY item_id),'')) FROM public.menu_item;
SELECT 'order_ticket_md5='||md5(COALESCE(string_agg(order_id||':'||payment_method||':'||staff_id||':'||order_timestamp, ',' ORDER BY order_id),'')) FROM public.order_ticket;
SELECT 'order_line_item_md5='||md5(COALESCE(string_agg(order_id||':'||item_id||':'||quantity||':'||sold_price, ',' ORDER BY order_id, item_id),'')) FROM public.order_line_item;
SELECT 'sales_total='||COALESCE(SUM(quantity*sold_price),0) FROM public.order_line_item;
