-- Run as canteen_app in the application database. Each expected denial is
-- caught independently so the whole test file can complete.
DO $$
BEGIN
    BEGIN
        DELETE FROM public.student WHERE false;
        RAISE EXCEPTION 'FAIL: runtime unexpectedly has DELETE on student';
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'PASS: runtime DELETE on student is denied';
    END;

    BEGIN
        PERFORM * FROM pg_catalog.pg_authid LIMIT 1;
        RAISE EXCEPTION 'FAIL: runtime unexpectedly read pg_authid';
    EXCEPTION WHEN insufficient_privilege THEN
        RAISE NOTICE 'PASS: runtime access to protected pg_authid is denied';
    END;

    IF has_database_privilege(current_user, 'postgres', 'CONNECT') THEN
        RAISE EXCEPTION 'FAIL: runtime has CONNECT on unrelated postgres database';
    END IF;
    RAISE NOTICE 'PASS: runtime lacks CONNECT on unrelated postgres database';
END
$$;
