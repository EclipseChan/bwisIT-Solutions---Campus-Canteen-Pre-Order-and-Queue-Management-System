-- Run as canteen_readonly in the application database.
SELECT item_id, vendor_id, item_name, price, is_available
FROM public.menu_item
ORDER BY item_id
LIMIT 5;

SELECT o.order_id, o.vendor_id, o.order_date, o.status,
       oi.item_id, oi.quantity, oi.price_at_order
FROM public.customer_order o
JOIN public.order_item oi ON oi.order_id = o.order_id
ORDER BY o.order_date DESC
LIMIT 5;
