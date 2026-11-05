EXPLAIN (ANALYZE, BUFFERS)
SELECT zone_id, zone_name, max_capacity, current_active_count
FROM public.parking_zone
ORDER BY zone_id;
