# BrewPOS — Local Setup (this machine)

This project is already provisioned and running.

## Open the app

**http://localhost:8081**

## Start / stop

- **Start:** double-click `start-brewpos.cmd`
- **Stop:** double-click `stop-brewpos.cmd`

The start script starts the local database first, builds the JAR if needed, then
starts BrewPOS. Both processes run in the background.

Equivalent PowerShell (if you prefer a terminal):

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\start-brewpos.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\stop-brewpos.ps1
```

## Local database

BrewPOS uses a **self-contained PostgreSQL 18 cluster** stored in `.pgdata/`.
It runs on **port 5433** so the existing PostgreSQL service on port 5432 was left
untouched.

| Item | Value |
|---|---|
| Database | `grp_brewposdb` |
| Schema | `public` |
| Host / port | `localhost:5433` |
| Application user | `brewpos_app` |
| Application password | in `.env` (`DB_PASSWORD`) |
| Admin user | `postgres` |
| Admin password | see `.pgdata/ADMIN_CREDENTIALS.txt` |

Configuration is in the project-root `.env`:

```dotenv
DB_URL=jdbc:postgresql://localhost:5433/grp_brewposdb
DB_USERNAME=brewpos_app
DB_PASSWORD=...
SERVER_PORT=8081
```

## Seed data

`database/schema.sql`, `database/seed.sql`, and `database/05_create_app_role.sql`
were applied. The app starts with:

- Staff: **Demo Cashier** and **Demo Manager**
- Categories: **Coffee**, **Non-Coffee**, **Pastries**
- 10 active menu items + 1 inactive item
- 5 sample orders (today and yesterday) for Orders and Daily Sales

## Useful commands

Rebuild the JAR:

```powershell
cmd /c "mvnw.cmd -DskipTests package"
```

Run the app in the foreground (instead of the background script):

```powershell
java -jar target\brewpos-0.0.1-SNAPSHOT.jar
```

Logs:

- App: `brewpos-app.log` / `brewpos-app.err.log`
- Database: `.pgdata\server.log`

If port 8081 is busy, change `SERVER_PORT` in `.env` and restart.
