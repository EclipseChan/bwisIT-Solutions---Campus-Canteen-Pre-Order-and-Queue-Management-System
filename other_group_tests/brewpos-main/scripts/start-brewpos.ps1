$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$pgBin = "C:\Program Files\PostgreSQL\18\bin"
$pgData = Join-Path $root ".pgdata"
$pgPort = 5433
$appUrl = "http://localhost:8081"
$jar = Join-Path $root "target\brewpos-0.0.1-SNAPSHOT.jar"
$pidFile = Join-Path $root ".brewpos-app.pid"

function Test-Postgres {
    & "$pgBin\pg_isready.exe" -h localhost -p $pgPort -U postgres *> $null
    return $LASTEXITCODE -eq 0
}

function Test-App {
    return [bool](Get-NetTCPConnection -LocalPort 8081 -State Listen -ErrorAction SilentlyContinue)
}

if (-not (Test-Path $pgData)) {
    throw "Local PostgreSQL cluster not found at $pgData. Re-run the BrewPOS database setup."
}

if (-not (Test-Postgres)) {
    Write-Host "Starting local PostgreSQL on port $pgPort ..."
    Start-Process -FilePath "$pgBin\pg_ctl.exe" `
        -ArgumentList @("start", "-D", "`"$pgData`"") `
        -WindowStyle Hidden `
        -RedirectStandardOutput (Join-Path $pgData "pgctl.out.log") `
        -RedirectStandardError (Join-Path $pgData "pgctl.err.log") | Out-Null

    for ($i = 0; $i -lt 30; $i++) {
        Start-Sleep -Seconds 1
        if (Test-Postgres) { break }
    }
    if (-not (Test-Postgres)) {
        throw "PostgreSQL did not start. See $pgData\server.log"
    }
    Write-Host "PostgreSQL is ready."
}
else {
    Write-Host "PostgreSQL is already running on port $pgPort."
}

if (-not (Test-Path $jar)) {
    Write-Host "Building BrewPOS (first run only) ..."
    Push-Location $root
    try {
        cmd /c "mvnw.cmd -DskipTests package"
        if ($LASTEXITCODE -ne 0) { throw "Maven build failed." }
    }
    finally {
        Pop-Location
    }
}

if (-not (Test-App)) {
    Write-Host "Starting BrewPOS ..."
    $process = Start-Process -FilePath "java.exe" `
        -ArgumentList @("-jar", "`"$jar`"") `
        -WorkingDirectory $root `
        -WindowStyle Hidden `
        -RedirectStandardOutput (Join-Path $root "brewpos-app.log") `
        -RedirectStandardError (Join-Path $root "brewpos-app.err.log") `
        -PassThru
    Set-Content -Path $pidFile -Value $process.Id

    for ($i = 0; $i -lt 60; $i++) {
        Start-Sleep -Seconds 1
        if (Test-App) { break }
    }
    if (-not (Test-App)) {
        throw "BrewPOS did not start. See $root\brewpos-app.log"
    }
    Write-Host "BrewPOS started (PID $($process.Id))."
}
else {
    Write-Host "BrewPOS is already running."
}

Write-Host ""
Write-Host "BrewPOS is available at $appUrl"
