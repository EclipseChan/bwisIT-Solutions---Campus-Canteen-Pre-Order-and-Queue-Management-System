-- Campus Canteen schema, 7 tables, created in dependency order.
-- Safe to run more than once.

CREATE TABLE IF NOT EXISTS student (
    student_id     SERIAL PRIMARY KEY,
    full_name      VARCHAR(100) NOT NULL,
    email          VARCHAR(150) NOT NULL UNIQUE,
    password_hash  VARCHAR(255) NOT NULL,
    created_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS vendor (
    vendor_id       SERIAL PRIMARY KEY,
    vendor_name     VARCHAR(100) NOT NULL,
    contact_number  VARCHAR(20),
    is_active       BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS menu_item (
    item_id       SERIAL PRIMARY KEY,
    vendor_id     INT NOT NULL REFERENCES vendor(vendor_id),
    item_name     VARCHAR(100) NOT NULL,
    price         NUMERIC(8,2) NOT NULL CHECK (price >= 0),
    is_available  BOOLEAN NOT NULL DEFAULT TRUE
);

-- "order" is a reserved SQL word, hence customer_order.
CREATE TABLE IF NOT EXISTS customer_order (
    order_id     SERIAL PRIMARY KEY,
    student_id   INT NOT NULL REFERENCES student(student_id),
    vendor_id    INT NOT NULL REFERENCES vendor(vendor_id),
    order_date   TIMESTAMP NOT NULL DEFAULT NOW(),
    pickup_time  TIME NOT NULL,
    status       VARCHAR(20) NOT NULL DEFAULT 'pending'
                 CHECK (status IN ('pending','preparing','ready','completed','cancelled'))
);

CREATE TABLE IF NOT EXISTS order_item (
    order_item_id   SERIAL PRIMARY KEY,
    order_id        INT NOT NULL REFERENCES customer_order(order_id),
    item_id         INT NOT NULL REFERENCES menu_item(item_id),
    quantity        INT NOT NULL CHECK (quantity > 0),
    price_at_order  NUMERIC(8,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS queue_entry (
    queue_id      SERIAL PRIMARY KEY,
    order_id      INT NOT NULL UNIQUE REFERENCES customer_order(order_id),
    queue_number  INT NOT NULL,
    queue_date    DATE NOT NULL DEFAULT CURRENT_DATE,
    status        VARCHAR(20) NOT NULL DEFAULT 'waiting'
                  CHECK (status IN ('waiting','called','served')),
    UNIQUE (queue_number, queue_date)
);

CREATE TABLE IF NOT EXISTS notification (
    notification_id  SERIAL PRIMARY KEY,
    order_id         INT NOT NULL REFERENCES customer_order(order_id),
    message          TEXT NOT NULL,
    sent_at          TIMESTAMP NOT NULL DEFAULT NOW(),
    is_read          BOOLEAN NOT NULL DEFAULT FALSE
);
