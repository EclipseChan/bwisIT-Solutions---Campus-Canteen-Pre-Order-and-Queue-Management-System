-- Sample data for testing. Every account uses the demo password Password123!
-- (stored as a BCrypt hash, same encoder the API uses).
-- Safe to run more than once: users and menu items are keyed by email / name,
-- and today's sample orders are only added if they are not there yet.

-- Accounts. The administrator is a student row with role ADMIN.
INSERT INTO student (full_name, email, password_hash, role) VALUES
    ('Canteen Admin',  'admin@canteen.test', '$2a$10$Dd4c/DygMs67cbKZBnJaZuwylEUDVxrMoauTh1BazaJ.mfh0Kc6y.', 'ADMIN'),
    ('Maria Santos',   'maria@student.test', '$2a$10$Dd4c/DygMs67cbKZBnJaZuwylEUDVxrMoauTh1BazaJ.mfh0Kc6y.', 'STUDENT'),
    ('Juan Dela Cruz', 'juan@student.test',  '$2a$10$Dd4c/DygMs67cbKZBnJaZuwylEUDVxrMoauTh1BazaJ.mfh0Kc6y.', 'STUDENT')
ON CONFLICT (email) DO NOTHING;

-- Vendors. The fourth stall is switched off on purpose: it must not appear
-- in the public stall list and cannot log in.
INSERT INTO vendor (vendor_name, contact_number, email, password_hash, is_active)
SELECT v.vendor_name, v.contact_number, v.email, '$2a$10$Dd4c/DygMs67cbKZBnJaZuwylEUDVxrMoauTh1BazaJ.mfh0Kc6y.', v.is_active
FROM (VALUES
    ('Aling Nena''s Silog', '09171234567', 'nena@vendor.test',      TRUE),
    ('Kuya Jun''s Burgers', '09181234567', 'jun@vendor.test',       TRUE),
    ('Merienda Corner',     '09191234567', 'merienda@vendor.test',  TRUE),
    ('Waffle Corner',       '09201234567', 'waffles@vendor.test',   FALSE)
) AS v(vendor_name, contact_number, email, is_active)
WHERE NOT EXISTS (SELECT 1 FROM vendor x WHERE x.email = v.email);

-- Menus.
INSERT INTO menu_item (vendor_id, item_name, price)
SELECT ve.vendor_id, m.item_name, m.price
FROM (VALUES
    ('nena@vendor.test',     'Tapsilog',        85.00),
    ('nena@vendor.test',     'Longsilog',       75.00),
    ('nena@vendor.test',     'Tosilog',         80.00),
    ('jun@vendor.test',      'Cheeseburger',    65.00),
    ('jun@vendor.test',      'Double Burger',   95.00),
    ('jun@vendor.test',      'Fries',           40.00),
    ('merienda@vendor.test', 'Siomai (4 pcs)',  45.50),
    ('merienda@vendor.test', 'Banana Cue',      20.00),
    ('merienda@vendor.test', 'Iced Tea',        30.00),
    ('waffles@vendor.test',  'Plain Waffle',    50.00)
) AS m(vendor_email, item_name, price)
JOIN vendor ve ON ve.email = m.vendor_email
WHERE NOT EXISTS (
    SELECT 1 FROM menu_item x WHERE x.vendor_id = ve.vendor_id AND x.item_name = m.item_name);

-- Two active orders today at Aling Nena's: Maria's is pending, Juan's is being prepared.
DO $$
DECLARE
    nena   INT := (SELECT vendor_id  FROM vendor  WHERE email = 'nena@vendor.test');
    maria  INT := (SELECT student_id FROM student WHERE email = 'maria@student.test');
    juan   INT := (SELECT student_id FROM student WHERE email = 'juan@student.test');
    tapsi  INT := (SELECT item_id FROM menu_item WHERE vendor_id = nena AND item_name = 'Tapsilog');
    longsi INT := (SELECT item_id FROM menu_item WHERE vendor_id = nena AND item_name = 'Longsilog');
    oid    INT;
    qn     INT;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM customer_order
                   WHERE vendor_id = nena AND student_id = maria AND order_date::date = CURRENT_DATE) THEN
        INSERT INTO customer_order (student_id, vendor_id, pickup_time, status)
        VALUES (maria, nena, '12:00', 'pending') RETURNING order_id INTO oid;
        INSERT INTO order_item (order_id, item_id, quantity, price_at_order) VALUES (oid, tapsi, 2, 85.00);
        SELECT COALESCE(MAX(queue_number), 0) + 1 INTO qn FROM queue_entry WHERE queue_date = CURRENT_DATE;
        INSERT INTO queue_entry (order_id, queue_number, status) VALUES (oid, qn, 'waiting');
        INSERT INTO notification (order_id, message)
        VALUES (oid, 'Order #' || oid || ' placed. Your queue number is ' || qn || '.');
    END IF;

    IF NOT EXISTS (SELECT 1 FROM customer_order
                   WHERE vendor_id = nena AND student_id = juan AND order_date::date = CURRENT_DATE) THEN
        INSERT INTO customer_order (student_id, vendor_id, pickup_time, status)
        VALUES (juan, nena, '12:30', 'preparing') RETURNING order_id INTO oid;
        INSERT INTO order_item (order_id, item_id, quantity, price_at_order) VALUES (oid, longsi, 1, 75.00);
        SELECT COALESCE(MAX(queue_number), 0) + 1 INTO qn FROM queue_entry WHERE queue_date = CURRENT_DATE;
        INSERT INTO queue_entry (order_id, queue_number, status) VALUES (oid, qn, 'waiting');
        INSERT INTO notification (order_id, message)
        VALUES (oid, 'Order #' || oid || ' placed. Your queue number is ' || qn || '.'),
               (oid, 'Order #' || oid || ' is being prepared.');
    END IF;
END $$;
