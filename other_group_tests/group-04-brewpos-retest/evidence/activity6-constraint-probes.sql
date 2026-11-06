\set VERBOSITY terse
\echo probe=invalid_staff_role_expect_CHECK_violation
BEGIN;
INSERT INTO public.staff (full_name, role) VALUES ('Constraint Probe','SUPERUSER');
ROLLBACK;

\echo probe=duplicate_category_expect_UNIQUE_violation
BEGIN;
INSERT INTO public.menu_category (category_name) VALUES ('Coffee');
ROLLBACK;

\echo probe=orphan_order_line_expect_FOREIGN_KEY_violation
BEGIN;
INSERT INTO public.order_line_item (order_id, item_id, quantity, sold_price) VALUES (1, 999999, 1, 1.00);
ROLLBACK;

\echo probe=negative_price_expect_CHECK_violation
BEGIN;
INSERT INTO public.menu_item (category_id, item_name, price, is_active) VALUES (1, 'Probe Item', -1.00, TRUE);
ROLLBACK;

\echo probe=zero_quantity_expect_CHECK_violation
BEGIN;
INSERT INTO public.order_line_item (order_id, item_id, quantity, sold_price) VALUES (1, 1, 0, 1.00);
ROLLBACK;

\echo probe=valid_write_expect_success
BEGIN;
INSERT INTO public.menu_category (category_name) VALUES ('Restore Write Probe') RETURNING category_id AS new_id;
ROLLBACK;

\echo probe=write_probe_rows_after_rollback
SELECT count(*) AS restore_write_probe_rows FROM public.menu_category WHERE category_name='Restore Write Probe';
