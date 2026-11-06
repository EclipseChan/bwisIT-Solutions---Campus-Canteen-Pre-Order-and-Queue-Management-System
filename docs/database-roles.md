# Database users and roles

Activity 4's PostgreSQL access-control implementation is in
[db-access-control/README.md](../db-access-control/README.md). It documents the
role design, grants, SQL execution order, credential setup, verification
queries, and executable test plan.

## Database identity

The database configured by default is `canteen_db`; the application schema is
`public`. It has seven tables and their `SERIAL` sequences. Student, vendor,
and application administrator accounts are application records, not database
roles.

## PostgreSQL accounts

| PostgreSQL account | Type | Use |
|---|---|---|
| `canteen_admin` | LOGIN, `CREATEROLE`, no `CREATEDB`/`SUPERUSER` | Owns database and objects; setup, migrations, maintenance |
| `canteen_app` | LOGIN, member of `canteen_app_grp` | Spring Boot runtime only |
| `canteen_readonly` | LOGIN, member of `canteen_readonly_grp` | Approved menu and sales reporting reads |
| `canteen_app_grp` | NOLOGIN group | App-only table/sequence grants |
| `canteen_readonly_grp` | NOLOGIN group | Column-limited SELECT grants, no writes |

The API uses `DB_USER` and `DB_PASSWORD` from the process environment. The
default account is `canteen_app`; it must not use `canteen_admin`. The setup
scripts use `DB_ADMIN_USER` and `DB_ADMIN_PASSWORD` for database creation and
migrations. `.env.example` contains placeholders only, and `.env` is ignored
by Git.

## Permission decisions based on current code

All seven tables are read by application workflows. Runtime inserts occur in
`student`, `vendor`, `menu_item`, `customer_order`, `order_item`, `queue_entry`,
and `notification`. Updates are used for `vendor` (administrator enable/disable),
`menu_item`, `customer_order`, `queue_entry`, and `notification`; student and
order-item records are not updated by current application code. Deletion is
only performed for `menu_item`; historical menu items are marked unavailable
and foreign keys prevent removing items referenced by orders.

The read-only role is intended for reports, not account inspection. It can
read only report-required columns of `vendor`, `menu_item`, `customer_order`,
and `order_item`. Student/vendor password hashes, student data, queues, and
notifications are not available to it. No default table SELECT is added for
future tables.

The complete privilege matrix and limitations are kept in
[db-access-control/README.md](../db-access-control/README.md). Run its
verification script and tests against the configured PostgreSQL cluster before
claiming the permissions are active.
