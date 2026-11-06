-- Disposable test database only; the transaction rolls back the test row.
BEGIN;

SELECT count(*) AS visible_zones FROM public.parking_zone;

INSERT INTO public.parking_zone
    (zone_name, max_capacity, current_active_count)
VALUES
    ('activity4-transient-test', 2, 0);

UPDATE public.parking_zone
SET max_capacity = 3
WHERE zone_name = 'activity4-transient-test';

DELETE FROM public.parking_zone
WHERE zone_name = 'activity4-transient-test';

ROLLBACK;
