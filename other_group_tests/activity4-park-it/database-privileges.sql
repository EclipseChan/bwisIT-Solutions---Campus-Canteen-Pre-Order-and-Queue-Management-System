-- Disposable test database only; grants are based on provisional role assumptions.
BEGIN;

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;

GRANT USAGE ON SCHEMA public
    TO park_it_app_grp, park_it_readonly_grp, park_it_backup_grp;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.parking_zone
    TO park_it_app_grp;
GRANT USAGE, SELECT ON SEQUENCE public.parking_zone_zone_id_seq
    TO park_it_app_grp;
GRANT SELECT ON TABLE public.parking_zone TO park_it_readonly_grp;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO park_it_backup_grp;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO park_it_backup_grp;

COMMIT;
