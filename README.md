# Campus Canteen Pre-Order and Queue Management System

COMP 018 Database Administration, Activity 3: System Development and Repository Deployment.

| | |
|---|---|
| Group | bwisIT Solutions (group number: TBD) |
| Members | TBD |
| Repository branch to test | main |
| Status | See the class tracker |

Students pre-order food from campus canteen stalls, choose a pickup time and get a digital queue number they can follow live. Stalls manage their menu and incoming orders. Administrators oversee stalls and sales. The system implements the design approved in Activity 2: 7 PostgreSQL tables, a Spring Boot REST API and a React web client.

| Layer | Technology |
|---|---|
| Database | PostgreSQL 18 (also tested on 16) |
| Backend | Java 21, Spring Boot 3.4, Spring Data JPA, Spring Security with JWT |
| Frontend | React 18 with Vite 5 |

## What is in this repository

```
backend/       Spring Boot API
frontend/      React web client
database/      setup scripts, migrations, seed data, reset script
docs/          database, roles, testing and troubleshooting documentation
scripts/       end-to-end smoke test
.env.example   settings template (placeholders only)
```

## 1. Prerequisites

Check each tool in a terminal before starting.

| Tool | Needed | Check with |
|---|---|---|
| Git | any recent version | `git --version` |
| JDK | 21 | `java -version` |
| Maven | 3.9 or newer (the VS Code "Extension Pack for Java" also includes it) | `mvn -v` |
| Node.js | 20 or newer | `node -v` |
| PostgreSQL | 16 or newer, with `psql` on PATH | `psql --version` |

You also need the password of the PostgreSQL superuser (`postgres`), chosen when PostgreSQL was installed. The first run downloads dependencies, so you need an internet connection.

## 2. Setup

Work from the repository root unless a step says otherwise.

### Step 1: Clone
```
git clone <repository-url>
cd <repository-folder>
```

### Step 2: Create your settings file
- Windows PowerShell: `Copy-Item .env.example .env`
- Linux or macOS: `cp .env.example .env`

Open `.env` and set:
- `DB_PASSWORD`: a password for the database login. Choose any password. If a login named `canteen_admin` already exists on your PostgreSQL, use that login's current password instead, because setup does not change an existing login's password. You can reset it as `postgres` with `ALTER ROLE canteen_admin PASSWORD 'new-password';`.
- `JWT_SECRET`: at least 32 random characters.

Leave the other values unless you need to change them (see the configuration table below). The `.env` file is ignored by Git and must never be committed.

### Step 3: Create the database, tables and sample data
- Windows: `powershell -ExecutionPolicy Bypass -File .\database\setup.ps1`
- Linux or macOS: `./database/setup.sh`

The script asks for the PostgreSQL superuser password. It creates the login role and database named in `.env`, runs every file in `database/migrations/` in order, then loads `database/seed/`. It is safe to run again. If `psql` is not on PATH on Windows, add `-Psql "C:\Program Files\PostgreSQL\18\bin\psql.exe"`.

Expected result: the last line reads `Done. Database 'canteen_db' is ready.` Check the tables:
```
psql -U canteen_admin -d canteen_db -c "\dt"
```
You should see 7 tables: customer_order, menu_item, notification, order_item, queue_entry, student, vendor.

### Step 4: Start the backend (port 8080)
```
cd backend
mvn spring-boot:run
```
In VS Code you can instead open the `backend` folder and run `CanteenApplication`. The first start takes a few minutes while dependencies download.

Expected result: the console shows `Started CanteenApplication`. Then open http://localhost:8080/api/vendors in a browser. It should list 3 stalls (Aling Nena's Silog, Kuya Jun's Burgers, Merienda Corner). The fourth sample stall is switched off on purpose, so it is hidden.

### Step 5: Start the frontend (port 5173)
In a second terminal:
```
cd frontend
npm install
npm run dev
```
Open http://localhost:5173. Requests to `/api` are forwarded to the backend automatically.

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
With the backend running, in another terminal at the repository root:
```
powershell -ExecutionPolicy Bypass -File .\scripts\test-flow.ps1
```
It registers a new vendor and student, adds menu items, places two orders, moves one through preparing, ready and completed, cancels the other, then prints the notifications and a sales report. Expected result: it ends with `All steps ran.` in green. Run it before 23:59 Philippine time, because its pickup time is 23:59.

### Manual check by role
Use a private browser window for the second user.

| Log in as | Do this | Expected |
|---|---|---|
| maria@student.test | Order food from a stall, choose a later pickup time, press Place order | A ticket with a queue number; the order appears in My orders and Notifications |
| nena@vendor.test | Orders tab: press Start preparing, then Mark ready | Buttons move the order forward; going backwards is not offered |
| maria@student.test | Wait about 5 seconds | Ticket status updates by itself, and a new notification appears |
| nena@vendor.test | Menu tab: add an item, edit its price, hide it, delete it | The student's menu changes accordingly |
| nena@vendor.test | Sales report tab | Revenue, top items and daily sales from completed orders |
| admin@canteen.test | Stalls tab: switch a stall off | The stall disappears from the student's stall list |
| maria@student.test | Cancel a pending order | Status becomes cancelled; a preparing order cannot be cancelled |

A sample order for today is loaded when the seed runs. If you ran setup on an earlier day, run the reset below to get fresh "today" orders.

## 5. Application user roles

| Application role | What it can do | Database role it maps to |
|---|---|---|
| Student | Order, view and cancel (while pending) their own orders, read their notifications | No login of its own; uses the runtime account `canteen_app` |
| Vendor | Manage their own menu, handle orders for their stall, view their sales | No login of its own; uses `canteen_app` |
| Administrator | Switch stalls on or off, view the canteen report | No login of its own; uses `canteen_app` |
| Application runtime | The account the API connects with | `canteen_app` in group `canteen_app_grp` |

In this activity the API connects as `canteen_admin` (the database owner). The separate group roles and logins are documented now and will be created in Activity 4. Details: [docs/user-roles.md](docs/user-roles.md) and [docs/database-roles.md](docs/database-roles.md).

## 6. Configuration reference

| Variable | Meaning | Default |
|---|---|---|
| `DB_HOST` | Database server | localhost |
| `DB_PORT` | Database port | 5432 |
| `DB_NAME` | Database name | canteen_db |
| `DB_USER` | Database login | canteen_admin |
| `DB_PASSWORD` | Password of that login | none, required |
| `JWT_SECRET` | Signs login tokens, 32 or more characters | none, required |

To use another database name, change `DB_NAME` in `.env` before running the setup script.

## 7. Database

Seven tables: student, vendor, menu_item, customer_order, order_item, queue_entry and notification. Setup scripts, migrations and seed data are in `database/`. All of them can be run more than once without errors or duplicates. The ERD, columns, constraints, indexes and the changes from the approved Activity 2 design are in [docs/database.md](docs/database.md).

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
| `Could not resolve placeholder 'DB_PASSWORD'` | Backend cannot see `.env`: start it from the `backend` folder and check the file name is exactly `.env` |
| `Schema-validation: missing column` | Run the setup script again; it is safe to repeat |
| Web page loads but every action fails | The backend is not running on port 8080 |
| Sample accounts cannot log in | The seed did not load; run the setup script again |

The full list is in [docs/troubleshooting.md](docs/troubleshooting.md).

## 9. Security notes
- No real credentials are committed. `.env` is ignored by Git; `.env.example` holds placeholders only.
- Passwords are stored as BCrypt hashes. The demo password applies only to the sample data.
- Login tokens last 2 hours.

## 10. For groups testing this project
- Use only this repository and its documentation, with your own local PostgreSQL. Please do not edit the repository to make it work; record problems in the tracker's testing log and tell us.
- Record in the log whether each of Steps 1 to 5 worked, and which roles from Section 4 you exercised.
- Expected result of each step is stated above, so any difference is worth reporting.

## 11. Documentation index
- [Database documentation](docs/database.md)
- [Application user roles](docs/user-roles.md)
- [Database user and role setup](docs/database-roles.md)
- [Testing and CRUD evidence](docs/testing.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Backend endpoints](backend/README.md)

## 12. AI usage
AI tools (Claude by Anthropic) were used to generate and review code, scripts and documentation. What was generated, and how the group validated it, is declared in the group's PDF progress documentation.