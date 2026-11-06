-- Run as canteen_readonly in the application database.
DO $$
BEGIN
    BEGIN
        INSERT INTO public.menu_item (vendor_id, item_name, price)
        VALUES (1, 'activity4-permission-test', 1.00);
        RAISE EXCEPTION 'FAIL: read-only unexpectedly inserted a record';
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'PASS: read-only INSERT is denied';
    END;

    BEGIN
        UPDATE public.menu_item SET price = price WHERE false;
        RAISE EXCEPTION 'FAIL: read-only unexpectedly updated a record';
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'PASS: read-only UPDATE is denied';
    END;

    BEGIN
        DELETE FROM public.menu_item WHERE false;
        RAISE EXCEPTION 'FAIL: read-only unexpectedly deleted a record';
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'PASS: read-only DELETE is denied';
    END;

    BEGIN
        TRUNCATE public.menu_item;
        RAISE EXCEPTION 'FAIL: read-only unexpectedly truncated a table';
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'PASS: read-only TRUNCATE is denied';
    END;

    BEGIN
        PERFORM student_id FROM public.student LIMIT 1;
        RAISE EXCEPTION 'FAIL: read-only unexpectedly accessed student records';
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'PASS: read-only access to unapproved student table is denied';
    END;
END
$$;
