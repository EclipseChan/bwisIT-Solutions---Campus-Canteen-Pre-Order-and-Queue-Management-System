<#
Creates the database owned by canteen_admin, runs migrations and sample data
as that account, then applies access-control scripts 03-06.
Usage (from the repository root):
  powershell -ExecutionPolicy Bypass -File .\database\setup.ps1
If psql is not on PATH, add:  -Psql "C:\Program Files\PostgreSQL\18\bin\psql.exe"
#>
param([string]$Psql = "psql")

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

if (-not (Test-Path .env)) { throw "Missing .env. Run: Copy-Item .env.example .env and edit it." }
if (-not (Get-Command $Psql -ErrorAction SilentlyContinue)) {
    throw "psql not found. Add the PostgreSQL bin folder to PATH or pass -Psql with the full path."
}

# Read KEY=VALUE lines as plain text.
$cfg = @{}
Get-Content .env | ForEach-Object {
    if ($_ -match '^\s*#' -or $_ -notmatch '=') { return }
    $k, $v = $_ -split '=', 2
    $cfg[$k.Trim()] = $v
}
$dbHost = if ($cfg.DB_HOST) { $cfg.DB_HOST } else { "localhost" }
$dbPort = if ($cfg.DB_PORT) { $cfg.DB_PORT } else { "5432" }
$dbName = if ($cfg.DB_NAME) { $cfg.DB_NAME } else { "canteen_db" }
$dbAdminUser = if ($cfg.DB_ADMIN_USER) { $cfg.DB_ADMIN_USER } else { "canteen_admin" }
$dbAdminPassword = $cfg.DB_ADMIN_PASSWORD
if ($dbAdminUser -ne "canteen_admin") { throw "DB_ADMIN_USER must be canteen_admin." }
if (-not $dbAdminPassword) { throw "DB_ADMIN_PASSWORD is empty in .env." }
if ($cfg.DB_USER -ne "canteen_app") { throw "DB_USER must be canteen_app for the application." }
if (-not $cfg.DB_PASSWORD) { throw "DB_PASSWORD is empty in .env." }

$env:PGOPTIONS = "-c client_min_messages=warning"
$secure = Read-Host "Password of the PostgreSQL superuser (postgres)" -AsSecureString
$superPw = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))

function Invoke-Psql($user, $password, $database, $file, $extra = @()) {
    $env:PGPASSWORD = $password
    & $Psql -h $dbHost -p $dbPort -U $user -d $database -v ON_ERROR_STOP=1 -q @extra -f $file
    if ($LASTEXITCODE -ne 0) { throw "psql failed on $file" }
}

try {
    Write-Host "Creating database '$dbName' owned by '$dbAdminUser' if missing..."
    Invoke-Psql "postgres" $superPw "postgres" "database\init\001_create_role_and_database.sql" `
        @("-v", "dbname=$dbName", "-v", "dbuser=$dbAdminUser")

    foreach ($f in Get-ChildItem database\migrations\*.sql | Sort-Object Name) {
        Write-Host "Migration: $($f.Name)"
        Invoke-Psql $dbAdminUser $dbAdminPassword $dbName $f.FullName
    }
    foreach ($f in Get-ChildItem database\seed\*.sql | Sort-Object Name) {
        Write-Host "Seed:      $($f.Name)"
        Invoke-Psql $dbAdminUser $dbAdminPassword $dbName $f.FullName
    }
    foreach ($name in @(
        "03-database-privileges.sql",
        "04-schema-and-table-privileges.sql",
        "05-sequence-privileges.sql",
        "06-default-privileges.sql"
    )) {
        Write-Host "Access control: $name"
        Invoke-Psql "postgres" $superPw $dbName "db-access-control\$name"
    }
    Write-Host "Done. Database '$dbName' is ready. Review and run db-access-control\07-security-restrictions.sql separately." -ForegroundColor Green
}
finally {
    Remove-Item Env:PGOPTIONS -ErrorAction SilentlyContinue
    Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
}
