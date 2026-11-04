# Campus Canteen Pre-Order and Queue Management System

COMP 018 Database Administration, Activity 3: System Development and Repository Deployment.

| | |
|---|---|
| Group | bwisIT Solutions (group number: TBD) |
| Members | Joshua Borreta, Martin Lawrence Bola, Joaquin Phillip Juatchon, Karl Raphael Marcos, Sancho Pacheco Jr, Euan Joseph Vera Cruz |
| Branch to test | `main` |
| Status | See the class tracker |

Students pre-order food from campus canteen stalls, choose a pickup time and get a queue number.
Stalls manage their menu and incoming orders. Administrators oversee stalls and sales.
The system implements the design approved in Activity 2: 7 PostgreSQL tables behind a
Spring Boot REST API.

| Layer | Technology |
|---|---|
| Database | PostgreSQL 18 (also tested on 16) |
| Backend | Java 21, Spring Boot 3.4, Spring Data JPA, Spring Security with JWT |
| Client | React 18 with Vite, in `frontend/` (optional, see Step 5). The API can also be exercised with the smoke test and PowerShell or curl requests (see [docs/api-endpoints.md](docs/api-endpoints.md)) |

## What is in this repository

```
src/main/             Spring Boot API (Maven project, pom.xml at the root)
database/             init script, migrations, seed data, setup scripts, reset script
docs/                 database, roles, endpoints, troubleshooting
scripts/              run-backend scripts (load .env, start the API)
frontend/             React web client for students, vendors and administrators (optional)
test-flow.ps1         end-to-end smoke test (needs the API running)
.env.example          settings template (placeholders only)
add_auth_columns.sql  same statements as database/migrations/002_auth_columns.sql
```

## 1. Prerequisites

| Tool | Needed | Check with |
|---|---|---|
| Git | any recent version | `git --version` |
| JDK | 21 | `java -version` |
| Maven | 3.9 or newer | `mvn -v` |
| PostgreSQL | 16 or newer, with `psql` on PATH | `psql --version` |
| Node.js | 18 or newer (LTS), only for the web client | `node -v` |

You also need the password of the PostgreSQL superuser (`postgres`), chosen when PostgreSQL was
installed. The first run downloads Maven dependencies, so you need an internet connection.

Use JDK 21. `pom.xml` sets `java.version` to 21, and newer JDKs (for example 25) have not been tested
with this project. If a newer JDK is your default, install JDK 21 next to it and select it as shown in
Step 4. Do not edit `java.version` to match another JDK.

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

- `DB_ADMIN_PASSWORD`: maintenance and migration password for `canteen_admin`.
- `DB_PASSWORD`: runtime password for `canteen_app`.
- `DB_READONLY_PASSWORD`: reporting password for `canteen_readonly`.
- `JWT_SECRET`: at least 32 random characters.

`.env` is ignored by Git and must never be committed.

### Step 3: Create roles, database, tables and sample data

Create the PostgreSQL roles as a superuser. The psql script asks for each role
password with a hidden prompt; enter the same values configured in `.env`.

- Windows PowerShell:

  ```
  psql -U postgres -d postgres -v ON_ERROR_STOP=1 -f .\db-access-control\01-create-roles.sql
  psql -U postgres -d postgres -v ON_ERROR_STOP=1 -f .\db-access-control\02-role-memberships.sql
  ```

- Linux/macOS:

  ```
  psql -h "$DB_HOST" -p "$DB_PORT" -U postgres -d postgres -v ON_ERROR_STOP=1 -f db-access-control/01-create-roles.sql
  psql -h "$DB_HOST" -p "$DB_PORT" -U postgres -d postgres -v ON_ERROR_STOP=1 -f db-access-control/02-role-memberships.sql
  ```

- Windows: `powershell -ExecutionPolicy Bypass -File .\database\setup.ps1`
- Linux or macOS: `./database/setup.sh`

The setup script asks for the PostgreSQL superuser password, creates the
database owned by `canteen_admin`, runs migrations and sample data as that
account, then applies access-control scripts 03-06. It does not run the app as
the owner. If `psql` is not on PATH on Windows, add
`-Psql "C:\Program Files\PostgreSQL\18\bin\psql.exe"` (use your own install path; keep the quotes if it contains spaces).
Type the superuser password by hand: pasting into the hidden prompt can capture the wrong text and give
`password authentication failed for user "postgres"`.

Review every database on the PostgreSQL cluster before running
`db-access-control/07-security-restrictions.sql`. It revokes `PUBLIC CONNECT`
cluster-wide and can affect other applications; see
[docs/database-roles.md](docs/database-roles.md).
Check the tables:

```
psql -U canteen_admin -d canteen_db -c "\dt"
```

You should see 7 tables: customer_order, menu_item, notification, order_item, queue_entry,
student, vendor.

### Step 4: Start the API (port 8080)

If JDK 21 is not your default, select it in the terminal you will run the API from (Windows PowerShell).
Use your actual folder names; a wrong folder fails silently and the older JDK is used instead. This lasts
only for that window, so repeat it in every new terminal:

```
$env:JAVA_HOME = "C:\Program Files\Eclipse Adoptium\jdk-21.0.13.9-hotspot"
$env:Path = "$env:JAVA_HOME\bin;$env:Path"
java -version
mvn -v
```

Both commands should report 21. If Maven is not installed and winget cannot find it, download the Maven
binary archive from maven.apache.org, extract it, and add its `bin` folder to `$env:Path` the same way.

The API reads environment variables, not the `.env` file itself, so start it with the script
that loads `.env` first:

- Windows: `powershell -ExecutionPolicy Bypass -File .\scripts\run-backend.ps1`
- Linux or macOS: `./scripts/run-backend.sh`

Expected result: the console shows `Started CanteenApplication`. Then open
http://localhost:8080/api/vendors in a browser. It should list 3 stalls (Aling Nena's Silog,
Kuya Jun's Burgers, Merienda Corner). The fourth sample stall is switched off on purpose, so
it is hidden.

### Step 5 (optional): Start the web client (port 5173)

A small React client in `frontend/` with a view for each role. It needs Node.js 18 or newer and the API
from Step 4 running. In a second terminal, from the repository root:

```
cd frontend
npm install
npm run dev
```

`npm install` is needed only once. Open http://localhost:5173 and log in with a sample account. The port is
fixed because the API only accepts browser requests from http://localhost:5173 and http://localhost:3000.
On Windows PowerShell, if `npm` is blocked with "running scripts is disabled", use `npm.cmd` instead
(for example `npm.cmd install`) or run `Set-ExecutionPolicy -Scope Process Bypass` first. Details: [frontend/README.md](frontend/README.md).

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

### Check in the web client

With the API and the client running, log in at http://localhost:5173:

| Log in as | Do this | Expected |
|---|---|---|
| maria@student.test | Order food: view a menu, set quantities and a pickup time, place the order | A queue number; the order appears under My orders |
| nena@vendor.test | Orders tab: mark an order preparing, ready, then completed | The status moves forward each time |
| maria@student.test | Refresh My orders and Notifications | The new status and a notification (the client does not update live) |
| admin@canteen.test | Stalls tab: switch a stall off; Sales tab | The stall disappears from the student list; per-stall report shown |

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
| Application runtime | The account the API connects with | `canteen_app`, member of `canteen_app_grp` |

Details: [docs/user-roles.md](docs/user-roles.md) and [docs/database-roles.md](docs/database-roles.md).

## 6. Configuration reference

| Variable | Meaning | Default |
|---|---|---|
| `DB_HOST` | Database server | localhost |
| `DB_PORT` | Database port | 5432 |
| `DB_NAME` | Database name | `canteen_db` |
| `DB_USER` | Runtime database login | `canteen_app` |
| `DB_PASSWORD` | Runtime login password | Set locally in `.env` |
| `DB_ADMIN_USER` | Maintenance and migration login | `canteen_admin` |
| `DB_ADMIN_PASSWORD` | Maintenance login password | Set locally in `.env` |
| `DB_READONLY_PASSWORD` | Read-only reporting login password | Set locally in `.env` |
| `JWT_SECRET` | Signs login tokens, 32 or more characters | none, required |

To use another database name, change `DB_NAME` in `.env` before running the setup script.

## 7. Database

Seven tables: student, vendor, menu_item, customer_order, order_item, queue_entry and
notification. Scripts, migrations and seed data are in `database/`; access-control scripts
are in `db-access-control/`. ERD, columns, constraints and the changes from the approved
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
| `password authentication failed for user "canteen_admin"` | `DB_ADMIN_PASSWORD` does not match the password entered for the role; see Step 2 |
| `Could not resolve placeholder 'DB_PASSWORD'` | Start the API with `scripts\run-backend.ps1` so `.env` is loaded |
| `Schema-validation: missing column` | Run the setup script again; it is safe to repeat |
| Requests fail with connection refused | The API is not running on port 8080 |
| Sample accounts cannot log in | The seed did not load; run the setup script again |
| `release version 25 not supported` | `java.version` in `pom.xml` was changed to 25; set it back to 21 |
| `java -version` still shows another JDK | The JDK 21 folder name is wrong or was set in a different window; see Step 4 |
| `npm` is blocked or not recognized | Use `npm.cmd`, or `Set-ExecutionPolicy -Scope Process Bypass`; open a new window after installing Node |
| Web client shows "Failed to fetch" | The API is not running on port 8080, or the client is not on port 5173 |
| `Port 5173 is already in use` | Close the other frontend terminal; the port must stay 5173 |

The full list is in [docs/troubleshooting.md](docs/troubleshooting.md).

## 9. Security notes

- No real credentials are committed. `.env` is ignored by Git; `.env.example` holds placeholders only.
- Passwords are stored as BCrypt hashes. The demo password applies only to the sample data.
- Login tokens last 2 hours.
- Browser requests are accepted only from http://localhost:5173 and http://localhost:3000.
- The API listens on all network interfaces by default; keep it on a local or trusted network while developing.

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
- [Web client](frontend/README.md)

## 12. AI usage

AI tools (Claude by Anthropic) were used to help guide the development process. What it was used for is to be declared in the PDF progress tracker.
