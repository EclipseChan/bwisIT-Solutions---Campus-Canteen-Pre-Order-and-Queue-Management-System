\set VERBOSITY verbose
\echo === read access (should succeed) ===
SELECT count(*) AS staff_rows FROM public.staff;
SELECT count(*) AS order_rows FROM public.order_ticket;

\echo === expected denials: historical order mutation ===
UPDATE public.order_ticket SET payment_method='ONLINE' WHERE order_id=10;
DELETE FROM public.order_ticket WHERE order_id=10;
UPDATE public.order_line_item SET quantity=99 WHERE order_id=10;
DELETE FROM public.order_line_item WHERE order_id=10;
TRUNCATE public.order_ticket;

\echo === expected denials: staff changes ===
INSERT INTO public.staff (full_name,role) VALUES ('Retest Intruder','CASHIER');
UPDATE public.staff SET full_name='Retest Intruder' WHERE staff_id=1;
DELETE FROM public.staff WHERE staff_id=1;

\echo === expected denials: DDL ===
CREATE TABLE public.retest_should_fail (id integer);
ALTER TABLE public.menu_item ADD COLUMN retest_should_fail integer;
DROP TABLE public.order_ticket;
