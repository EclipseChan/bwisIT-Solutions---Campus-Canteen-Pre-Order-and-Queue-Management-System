\echo === counts ===
SELECT 'staff' AS table_name, count(*) FROM staff
UNION ALL SELECT 'menu_category', count(*) FROM menu_category
UNION ALL SELECT 'menu_item', count(*) FROM menu_item
UNION ALL SELECT 'order_ticket', count(*) FROM order_ticket
UNION ALL SELECT 'order_line_item', count(*) FROM order_line_item ORDER BY 1;
\echo === orders 10 and 11 ===
SELECT order_id, order_timestamp, payment_method, staff_id FROM order_ticket WHERE order_id IN (10,11) ORDER BY order_id;
SELECT t.order_id, m.item_name, l.quantity, l.sold_price, (l.quantity*l.sold_price) AS line_total
FROM order_line_item l JOIN menu_item m ON m.item_id=l.item_id JOIN order_ticket t ON t.order_id=l.order_id
WHERE t.order_id IN (10,11) ORDER BY t.order_id, m.item_name;
\echo === Hojicha menu row ===
SELECT i.item_id, i.item_name, c.category_name, i.price, i.is_active FROM menu_item i JOIN menu_category c ON c.category_id=i.category_id WHERE i.item_name='Hojicha Latte';
\echo === daily sales ===
SELECT COALESCE(SUM(l.quantity*l.sold_price),0) AS net_sales, COUNT(DISTINCT t.order_id) AS completed_orders
FROM order_ticket t JOIN order_line_item l ON l.order_id=t.order_id
WHERE t.order_timestamp >= CURRENT_DATE AND t.order_timestamp < CURRENT_DATE + 1;
SELECT payment_method, COUNT(DISTINCT order_id) AS orders, SUM(qty*price) AS sales FROM (
  SELECT t.order_id, t.payment_method, l.quantity AS qty, l.sold_price AS price
  FROM order_ticket t JOIN order_line_item l ON l.order_id=t.order_id
  WHERE t.order_timestamp >= CURRENT_DATE AND t.order_timestamp < CURRENT_DATE + 1
) x GROUP BY payment_method ORDER BY payment_method;
