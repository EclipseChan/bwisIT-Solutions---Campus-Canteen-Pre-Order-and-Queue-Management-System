-- Run as canteen_app in the seeded application database.
BEGIN;

DO $$
DECLARE
    student_key integer;
    vendor_key integer;
    new_order_key integer;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM public.menu_item LIMIT 1) THEN
        RAISE EXCEPTION 'No menu records available for the read test';
    END IF;
    RAISE NOTICE 'PASS: runtime can read menu records';

    SELECT student_id INTO student_key FROM public.student LIMIT 1;
    SELECT vendor_id INTO vendor_key FROM public.vendor LIMIT 1;
    IF student_key IS NULL OR vendor_key IS NULL THEN
        RAISE EXCEPTION 'Seed at least one student and vendor before running this test';
    END IF;

    INSERT INTO public.customer_order (student_id, vendor_id, pickup_time)
    VALUES (student_key, vendor_key, CURRENT_TIME)
    RETURNING order_id INTO new_order_key;
    RAISE NOTICE 'PASS: runtime inserted an order';

    UPDATE public.customer_order
    SET status = 'preparing'
    WHERE order_id = new_order_key;
    RAISE NOTICE 'PASS: runtime updated its test order';
END
$$;

ROLLBACK;
