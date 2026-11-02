# Application user roles

A role is what a person can do after logging in. It is not the same as a PostgreSQL account:
no end user has a database login, and the API connects through one runtime account
(see [database-roles.md](database-roles.md)).

Roles travel inside the JWT (valid 2 hours). Route protection is in `SecurityConfig`.

| Application role | Where it is stored | What it can do | Endpoints |
|---|---|---|---|
| Public (no login) | none | Register, log in, browse active stalls and their menus | `/api/auth/register/**`, `/api/auth/login`, `GET /api/vendors/**` |
| Student | `student.role = 'STUDENT'` | Place orders, view own orders, cancel while pending, read own notifications | `/api/orders/**`, `/api/notifications/**` |
| Vendor | `vendor` row with email and password; must have `is_active = true` to log in | Manage own menu (add, edit, hide, delete), see and advance orders for their stall, view own sales report | `/api/vendor/**` |
| Administrator | `student.role = 'ADMIN'` | List all stalls, switch stalls on or off, view the canteen-wide sales report | `/api/admin/**` |
| Application runtime | PostgreSQL login `canteen_admin` (this activity) | The account the API itself uses to reach the database | not a person |

Any logged-in user can call `GET /api/auth/me`.

## Notes

- There is no endpoint to create an administrator. Register a normal student account, then run
  `UPDATE student SET role = 'ADMIN' WHERE email = '...';` and log in again.
- Order status only moves forward: pending, preparing, ready, completed. A vendor can also
  cancel any order before it is completed. A student can cancel only while it is pending.
- A deleted menu item that already appears in past orders is marked unavailable instead, so
  sales history is kept.

## Sample accounts

All use the demo password `Password123!`, which exists only in the seed data.

| Role | Email | Notes |
|---|---|---|
| Administrator | admin@canteen.test | |
| Vendor | nena@vendor.test | Two active orders today |
| Vendor | jun@vendor.test | |
| Vendor | merienda@vendor.test | |
| Vendor | waffles@vendor.test | Stall is switched off, so it cannot log in |
| Student | maria@student.test | Pending order today |
| Student | juan@student.test | Order being prepared today |
