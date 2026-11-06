# Access-control test plan

Run these checks only against a local or disposable database. Seed the database
first (`database/seed/001_sample_data.sql`). Set `DB_HOST`, `DB_PORT`, and
`DB_NAME` to the application database and set `PGPASSWORD` to the matching
local account password in the shell; do not put passwords in command arguments
or commit them.

The SQL result files are executable checks. Their `PASS` notices are meaningful
only when the scripts complete with exit code 0. No result is implied by this
plan; execution results must be recorded separately.

## Windows PowerShell

At the repository root, load connection values from `.env` and set the
connection password for the test session:

```powershell
Get-Content .env | ForEach-Object {
  if ($_ -match '^\s*#' -or $_ -notmatch '=') { return }
  $name, $value = $_ -split '=', 2
  Set-Item -Path "Env:$($name.Trim())" -Value $value
}
$env:PGPASSWORD = $env:DB_PASSWORD
$env:PGHOST = $env:DB_HOST
$env:PGPORT = $env:DB_PORT
$env:PGDATABASE = $env:DB_NAME
```

Allowed runtime read, insert, update (all data changes are rolled back):

```powershell
psql -U canteen_app -v ON_ERROR_STOP=1 -f .\db-access-control\tests\runtime-allowed.sql
```

Denied runtime delete/protected-catalog access and unrelated database check:

```powershell
psql -U canteen_app -v ON_ERROR_STOP=1 -f .\db-access-control\tests\runtime-denied.sql
```

Allowed read-only queries and denied insert/update/delete/unapproved-table access:

```powershell
$env:PGPASSWORD = $env:DB_READONLY_PASSWORD
psql -U canteen_readonly -v ON_ERROR_STOP=1 -f .\db-access-control\tests\readonly-allowed.sql
psql -U canteen_readonly -v ON_ERROR_STOP=1 -f .\db-access-control\tests\readonly-denied.sql
```

## Non-SQL denied-operation checks

These are expected to fail with a permission error. Test database creation
while connected to the application database so the result checks `CREATEDB`,
not merely denied CONNECT to the `postgres` maintenance database:

```powershell
$env:PGPASSWORD = $env:DB_PASSWORD
psql -h $env:DB_HOST -p $env:DB_PORT -U canteen_app -d $env:DB_NAME `
  -v ON_ERROR_STOP=1 -c "CREATE DATABASE activity4_must_be_denied;"
psql -h $env:DB_HOST -p $env:DB_PORT -U canteen_app -d postgres -c "SELECT 1"
```

The first must fail specifically with a `permission denied to create database`
error. The second tests connection to the unrelated `postgres` database and
must fail for lack of CONNECT. A successful command is a failure of the
access-control configuration. Drop `activity4_must_be_denied` only if a
misconfigured role unexpectedly created it.

The read-only denial script also attempts TRUNCATE inside a PL/pgSQL exception
block; the expected privilege error is caught and reported as a `PASS`.

## Role and privilege checks

```powershell
$env:PGPASSWORD = $env:DB_ADMIN_PASSWORD
psql -h $env:DB_HOST -p $env:DB_PORT -U canteen_admin -d $env:DB_NAME `
  -v ON_ERROR_STOP=1 -f .\db-access-control\08-privilege-verification.sql
```

Review the rows for:

- all three login roles are non-superusers and cannot create databases;
- only `canteen_admin` has `CREATEROLE`;
- `canteen_app` and `canteen_readonly` inherit only their intended group role;
- all application relations are owned by `canteen_admin`, never `canteen_app`;
- the runtime has DELETE on `menu_item`, not other tables;
- read-only has only the explicit reporting columns and no write/TRUNCATE privileges;
- runtime sequence UPDATE and read-only sequence access are false;
- the unrelated database CONNECT result is false after script 07 is applied.

## Expected outcome matrix

| Test | Expected |
|---|---|
| Runtime reads authorized menu records | ALLOWED |
| Runtime inserts an authorized order | ALLOWED |
| Runtime updates an authorized order | ALLOWED |
| Runtime deletes from unauthorized `student` table | DENIED |
| Read-only reads approved menu and sales records | ALLOWED |
| Read-only inserts, updates, or deletes | DENIED |
| Read-only truncates a table | DENIED |
| Runtime creates a database | DENIED |
| Runtime connects to unrelated `postgres` database | DENIED |
| Runtime reads protected `pg_authid` table | DENIED |
| Read-only accesses unapproved `student` table | DENIED |
