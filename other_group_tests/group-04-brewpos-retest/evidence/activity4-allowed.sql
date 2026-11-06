\echo === allowed runtime operations (all rolled back) ===
BEGIN;
INSERT INTO public.menu_category (category_name) VALUES ('Retest Temp Category') RETURNING category_id AS new_category_id;
INSERT INTO public.menu_item (category_id,item_name,price,is_active)
  SELECT category_id,'Retest Temp Item',1.00,TRUE FROM public.menu_category WHERE category_name='Retest Temp Category'
  RETURNING item_id AS new_item_id;
UPDATE public.menu_item SET price=2.00 WHERE item_name='Retest Temp Item' RETURNING item_name, price;
INSERT INTO public.menu_category (category_name) VALUES ('Retest Delete Category') RETURNING category_id AS delete_category_id;
DELETE FROM public.menu_category WHERE category_name='Retest Delete Category';
INSERT INTO public.menu_item (category_id,item_name,price,is_active)
  SELECT category_id,'Retest Delete Item',1.00,TRUE FROM public.menu_category WHERE category_name='Retest Temp Category'
  RETURNING item_id AS delete_item_id;
DELETE FROM public.menu_item WHERE item_name='Retest Delete Item';
INSERT INTO public.order_ticket (staff_id,payment_method) VALUES (1,'CASH') RETURNING order_id AS new_order_id;
INSERT INTO public.order_line_item (order_id,item_id,quantity,sold_price)
  SELECT t.order_id,m.item_id,1,m.price
  FROM public.order_ticket t CROSS JOIN public.menu_item m
  WHERE t.order_id=(SELECT max(order_id) FROM public.order_ticket)
    AND m.item_name='Retest Temp Item';
SELECT t.order_id, t.payment_method, m.item_name, l.quantity, l.sold_price
FROM public.order_ticket t
JOIN public.order_line_item l ON l.order_id=t.order_id
JOIN public.menu_item m ON m.item_id=l.item_id
WHERE t.order_id=(SELECT max(order_id) FROM public.order_ticket);
ROLLBACK;

\echo === after rollback: temporary rows must be gone ===
SELECT count(*) AS temp_category_rows FROM public.menu_category WHERE category_name='Retest Temp Category';
SELECT count(*) AS temp_item_rows FROM public.menu_item WHERE item_name IN ('Retest Temp Item','Retest Delete Item');
SELECT count(*) AS seeded_orders FROM public.order_ticket;
