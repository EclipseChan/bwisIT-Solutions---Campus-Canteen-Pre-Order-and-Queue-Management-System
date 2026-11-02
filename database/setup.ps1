<#
Creates the database login and database from .env, runs every migration in
order, then loads the sample data. Safe to run again.
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
$dbUser = if ($cfg.DB_USER) { $cfg.DB_USER } else { "canteen_admin" }
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
    Write-Host "Creating login '$dbUser' and database '$dbName' if missing..."
    Invoke-Psql "postgres" $superPw "postgres" "database\init\001_create_role_and_database.sql" `
        @("-v", "dbname=$dbName", "-v", "dbuser=$dbUser", "-v", "dbpass=$($cfg.DB_PASSWORD)")

    foreach ($f in Get-ChildItem database\migrations\*.sql | Sort-Object Name) {
        Write-Host "Migration: $($f.Name)"
        Invoke-Psql $dbUser $cfg.DB_PASSWORD $dbName $f.FullName
    }
    foreach ($f in Get-ChildItem database\seed\*.sql | Sort-Object Name) {
        Write-Host "Seed:      $($f.Name)"
        Invoke-Psql $dbUser $cfg.DB_PASSWORD $dbName $f.FullName
    }
    Write-Host "Done. Database '$dbName' is ready." -ForegroundColor Green
}
finally {
    Remove-Item Env:PGOPTIONS -ErrorAction SilentlyContinue
    Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
}
