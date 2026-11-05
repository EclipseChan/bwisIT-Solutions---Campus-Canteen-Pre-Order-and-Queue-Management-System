$ErrorActionPreference = "Continue"

$root = Split-Path -Parent $PSScriptRoot
$pgBin = "C:\Program Files\PostgreSQL\18\bin"
$pgData = Join-Path $root ".pgdata"
$pidFile = Join-Path $root ".brewpos-app.pid"

if (Test-Path $pidFile) {
    $appPid = (Get-Content $pidFile -Raw).Trim()
    if ($appPid -and (Get-Process -Id $appPid -ErrorAction SilentlyContinue)) {
        Write-Host "Stopping BrewPOS (PID $appPid) ..."
        Stop-Process -Id $appPid -Force
    }
    Remove-Item $pidFile -Force -ErrorAction SilentlyContinue
}
else {
    Write-Host "No BrewPOS PID file found; app may already be stopped."
}

if (Test-Path $pgData) {
    Write-Host "Stopping local PostgreSQL ..."
    & "$pgBin\pg_ctl.exe" stop -D $pgData -m fast -w
}
else {
    Write-Host "Local PostgreSQL cluster directory not found; nothing to stop."
}

Write-Host "BrewPOS stopped."
