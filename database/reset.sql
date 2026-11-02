-- Deletes all rows and restarts the ID counters. Tables stay.
-- Run seed/001_sample_data.sql afterwards to reload the samples.
TRUNCATE notification, queue_entry, order_item, customer_order, menu_item, vendor, student
    RESTART IDENTITY CASCADE;
