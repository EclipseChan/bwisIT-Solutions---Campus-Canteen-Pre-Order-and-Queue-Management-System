# Campus Canteen Pre-Order and Queue Management System

COMP 018 Database Administration, Activity 3: System Development and Repository Deployment.

| | |
|---|---|
| Group | bwisIT Solutions (group number: TBD) |
| Members | TBD |
| Branch to test | `main` |
| Status | See the class tracker |

Students pre-order food from campus canteen stalls, choose a pickup time and get a queue number.
Stalls manage their menu and incoming orders. Administrators oversee stalls and sales.
The system implements the design approved in Activity 2: 7 PostgreSQL tables behind a
Spring Boot REST API.

| Layer | Technology |
|---|---|
| Database | PostgreSQL 18 (also tested on 16) |
| Backend | Java 25 (LTS), Spring Boot 3.4, Spring Data JPA, Spring Security with JWT |
| Client | None in this repository yet. The API is exercised with the smoke test and PowerShell or curl requests (see [docs/api-endpoints.md](docs/api-endpoints.md)) |

## What is in this repository

```
src/main/             Spring Boot API (Maven project, pom.xml at the root)
database/             init script, migrations, seed data, setup scripts, reset script
docs/                 database, roles, endpoints, troubleshooting
scripts/              run-backend scripts (load .env, start the API)
test-flow.ps1         end-to-end smoke test (needs the API running)
.env.example          settings template (placeholders only)
add_auth_columns.sql  same statements as database/migrations/002_auth_columns.sql
```

## 1. Prerequisites

| Tool | Needed | Check with |
|---|---|---|
| Git | any recent version | `git --version` |
| JDK | 25 (LTS) | `java -version` |
| Maven | 3.9 or newer | `mvn -v` |
| PostgreSQL | 16 or newer, with `psql` on PATH | `psql --version` |

You also need the password of the PostgreSQL superuser (`postgres`), chosen when PostgreSQL was
installed. The first run downloads Maven dependencies, so you need an internet connection.

## 2. Setup

Work from the repository root.

### Step 1: Clone

```
git clone <repository-url>
cd <repository-folder>
```

### Step 2: Create your settings file

- Windows PowerShell: `Copy-Item .env.example .env`
- Linux or macOS: `cp .env.example .env`

Edit `.env` and set:

- `DB_PASSWORD`: a password for the database login. Choose any password without double quotes.
  If a login named `canteen_admin` already exists on your PostgreSQL, use that login's current
  password instead, because setup never changes an existing login's password.
- `JWT_SECRET`: at least 32 random characters.

`.env` is ignored by Git and must never be committed.

### Step 3: Create the database, tables and sample data

- Windows: `powershell -ExecutionPolicy Bypass -File .\database\setup.ps1`
- Linux or macOS: `./database/setup.sh`

The script asks for the PostgreSQL superuser password, creates the login and database named in
`.env`, runs every file in `database/migrations/` in order, then loads `database/seed/`.
It is safe to run again. If `psql` is not on PATH on Windows, add
`-Psql "C:\Program Files\PostgreSQL\18\bin\psql.exe"`.

Expected last line: `Done. Database 'canteen_db' is ready.` Check the tables:

```
psql -U canteen_admin -d canteen_db -c "\dt"
```

You should see 7 tables: customer_order, menu_item, notification, order_item, queue_entry,
student, vendor.

### Step 4: Start the API (port 8080)

The API reads environment variables, not the `.env` file itself, so start it with the script
that loads `.env` first:

- Windows: `powershell -ExecutionPolicy Bypass -File .\scripts\run-backend.ps1`
- Linux or macOS: `./scripts/run-backend.sh`

Expected result: the console shows `Started CanteenApplication`. Then open
http://localhost:8080/api/vendors in a browser. It should list 3 stalls (Aling Nena's Silog,
Kuya Jun's Burgers, Merienda Corner). The fourth sample stall is switched off on purpose, so
it is hidden.

## 3. Sample accounts

All sample accounts use the demo password `Password123!`. It exists only in the sample data.

| Application role | Email | Notes |
|---|---|---|
| Administrator | admin@canteen.test | Stalls and canteen report |
| Vendor | nena@vendor.test | Has two active orders today |
| Vendor | jun@vendor.test | |
| Vendor | merienda@vendor.test | |
| Vendor | waffles@vendor.test | Stall is switched off, so it cannot log in |
| Student | maria@student.test | Has a pending order today |
| Student | juan@student.test | Has an order being prepared today |

## 4. Check that it works

### Automatic check

With the API running, in another terminal at the repository root:

```
powershell -ExecutionPolicy Bypass -File .\test-flow.ps1
```

It registers a new vendor and student, adds menu items, places two orders, moves one through
preparing, ready and completed, cancels the other, then prints the notifications and a sales
report. Expected result: it ends with `All steps ran.` in green. Run it before 23:59 Philippine
time, because its pickup time is 23:59.

### Check by role

Log in with `POST /api/auth/login` (`email`, `password`) and send the returned token as
`Authorization: Bearer <token>`. Endpoint list: [docs/api-endpoints.md](docs/api-endpoints.md).

| Log in as | Do this | Expected |
|---|---|---|
| maria@student.test | `GET /api/orders` | Her pending order with queue number 1 |
| maria@student.test | `POST /api/orders` for a stall, with a later pickup time | A queue number and total |
| nena@vendor.test | `GET /api/vendor/orders`, then `PATCH` a status to `preparing`, then `ready` | Orders move forward; going backwards is rejected with 409 |
| nena@vendor.test | Add, edit, hide and delete a menu item | The public menu `GET /api/vendors/{id}/menu` changes accordingly |
| nena@vendor.test | `GET /api/vendor/reports/sales` | Revenue and top items from completed orders |
| admin@canteen.test | `PATCH /api/admin/vendors/{id}/active` with `{"active": false}` | The stall disappears from `GET /api/vendors` |
| admin@canteen.test | `GET /api/admin/reports/sales` | Canteen-wide report with per-vendor breakdown |
| maria@student.test | `POST /api/orders/{id}/cancel` on a pending order | Status becomes cancelled; a preparing order cannot be cancelled (409) |

## 5. Application user roles

| Application role | What it can do | Database role it maps to |
|---|---|---|
| Student | Order, view and cancel (while pending) their own orders, read their notifications | No login of its own; uses the runtime account |
| Vendor | Manage their own menu, handle orders for their stall, view their sales | No login of its own; uses the runtime account |
| Administrator | Switch stalls on or off, view the canteen report | No login of its own; uses the runtime account |
| Application runtime | The account the API connects with | `canteen_admin` in this activity; `canteen_app` in group `canteen_app_grp` from Activity 4 |

Details: [docs/user-roles.md](docs/user-roles.md) and [docs/database-roles.md](docs/database-roles.md).

## 6. Configuration reference

| Variable | Meaning | Default |
|---|---|---|
| `DB_HOST` | Database server | localhost |
| `DB_PORT` | Database port | 5432 |
| `DB_NAME` | Database name | `canteen_db` in `.env.example` (the API's own fallback is `grpxx_canteendb`) |
| `DB_USER` | Database login | canteen_admin |
| `DB_PASSWORD` | Password of that login | none, required |
| `JWT_SECRET` | Signs login tokens, 32 or more characters | none, required |

To use another database name, change `DB_NAME` in `.env` before running the setup script.

## 7. Database

Seven tables: student, vendor, menu_item, customer_order, order_item, queue_entry and
notification. Scripts, migrations and seed data are in `database/` and can be run more than
once without errors or duplicates. ERD, columns, constraints and the changes from the approved
Activity 2 design: [docs/database.md](docs/database.md).

### Reset the data

To clear all data and reload the samples (tables stay):

```
psql -U canteen_admin -d canteen_db -f database/reset.sql
psql -U canteen_admin -d canteen_db -f database/seed/001_sample_data.sql
```

## 8. Common problems

| Problem | Fix |
|---|---|
| `psql` not recognized | Add the PostgreSQL `bin` folder to PATH and open a new terminal |
| `password authentication failed for user "canteen_admin"` | The password in `.env` does not match the existing login; see Step 2 |
| `Could not resolve placeholder 'DB_PASSWORD'` | Start the API with `scripts\run-backend.ps1` so `.env` is loaded |
| `Schema-validation: missing column` | Run the setup script again; it is safe to repeat |
| Requests fail with connection refused | The API is not running on port 8080 |
| Sample accounts cannot log in | The seed did not load; run the setup script again |

The full list is in [docs/troubleshooting.md](docs/troubleshooting.md).

## 9. Security notes

- No real credentials are committed. `.env` is ignored by Git; `.env.example` holds placeholders only.
- Passwords are stored as BCrypt hashes. The demo password applies only to the sample data.
- Login tokens last 2 hours.

## 10. For groups testing this project

- Use only this repository and its documentation, with your own local PostgreSQL. Please do not
  edit the repository to make it work; record problems in the tracker's testing log and tell us.
- Record in the log whether each of Steps 1 to 4 worked, and which roles from Section 4 you exercised.
- Expected result of each step is stated above, so any difference is worth reporting.

## 11. Documentation index

- [Database documentation](docs/database.md)
- [Application user roles](docs/user-roles.md)
- [Database user and role setup](docs/database-roles.md)
- [Backend endpoints](docs/api-endpoints.md)
- [Troubleshooting](docs/troubleshooting.md)

## 12. AI usage

AI tools (Claude by Anthropic) were used to generate and review code, scripts and
documentation. What was generated, and how the group validated it, is declared in the group's
PDF progress documentation.
