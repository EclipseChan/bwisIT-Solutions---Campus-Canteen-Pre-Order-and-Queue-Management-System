# Troubleshooting

| Problem | Fix |
|---|---|
| `psql` is not recognized | Add the PostgreSQL `bin` folder (for example `C:\Program Files\PostgreSQL\18\bin`) to PATH and open a new terminal, or pass `-Psql "<full path to psql.exe>"` to `setup.ps1` |
| `Missing .env` | Copy `.env.example` to `.env` and set `DB_ADMIN_PASSWORD`, `DB_PASSWORD`, `DB_READONLY_PASSWORD`, and `JWT_SECRET`. Make sure the file is not named `.env.txt` |
| `password authentication failed for user "postgres"` during setup | Wrong superuser password. Use the one chosen when PostgreSQL was installed |
| `password authentication failed for user "canteen_admin"` | `DB_ADMIN_PASSWORD` does not match the password entered for `canteen_admin` in `01-create-roles.sql`; use an interactive `psql` session and `\password canteen_admin` to reset it, then update `.env` |
| `password authentication failed for user "canteen_app"` | Check `DB_PASSWORD` and confirm `canteen_app` belongs to `canteen_app_grp` |
| `Could not resolve placeholder 'DB_PASSWORD'` or `'JWT_SECRET'` | The API reads environment variables, not `.env`. Start it with `scripts\run-backend.ps1` (or `scripts/run-backend.sh`), which loads `.env` first |
| `database "..." does not exist` | `DB_NAME` in `.env` differs from the database that was created. Run the setup script again |
| `Schema-validation: missing column` or `missing table` | Run the setup script again. It is safe to repeat |
| `connection refused` on port 5432 | The PostgreSQL service is stopped. Windows: `Start-Service postgresql-x64-18` in an Administrator PowerShell |
| `Port 8080 was already in use` | Another program uses 8080. Stop it, then start the API again |
| Sample accounts cannot log in | The seed did not load. Run the setup script again. `waffles@vendor.test` is switched off on purpose |
| Sample orders are missing today | They are created for the day the seed runs. Run `database/seed/001_sample_data.sql` again, or reset first (README, "Reset the data") |
| Smoke test says connection refused | The API is not running on port 8080 |
| Passwords with `"` fail on Windows | Use passwords without double quotes in the local `.env` file |
