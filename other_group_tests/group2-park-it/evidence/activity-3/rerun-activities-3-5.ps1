$ErrorActionPreference = 'Stop'

$appSource = 'C:\Users\EclipseLapsed\Downloads\Park it\park-it-database-final'
$database = 'parkit_test_20261105_1429'
$hostName = '127.0.0.1'
$port = 5432
$postgresUser = 'postgres'
$psql = 'C:\Program Files\PostgreSQL\18\bin\psql.exe'
$php = (Get-Command php -ErrorAction Stop).Source
$tempCopy = Join-Path $env:TEMP ('park-it-rerun-' + [guid]::NewGuid().ToString('N'))

if (-not (Test-Path -LiteralPath $appSource)) { throw "Application source not found." }
if (-not (Test-Path -LiteralPath $psql)) { throw "PostgreSQL psql not found." }

$securePassword = Read-Host 'PostgreSQL password for postgres (input is hidden)' -AsSecureString
$passwordPointer = [IntPtr]::Zero
try {
    $passwordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
    $env:PGPASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPointer)
    $env:PARK_IT_TEST_DB_PASSWORD = $env:PGPASSWORD
}
finally {
    if ($passwordPointer -ne [IntPtr]::Zero) {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPointer)
    }
}

function Invoke-ParkItSql {
    param([string]$TargetDatabase, [string]$Sql)
    & $psql -X -w -P pager=off -h $hostName -p $port -U $postgresUser `
        -d $TargetDatabase -v ON_ERROR_STOP=1 -c $Sql
    if ($LASTEXITCODE -ne 0) { throw "psql query failed for the designated test database." }
}

function Read-ParkItApplicationPassword {
    param([string]$Username)
    $applicationPassword = Read-Host "Application password for $Username (input is hidden)" -AsSecureString
    $securePointer = [IntPtr]::Zero
    try {
        $securePointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($applicationPassword)
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($securePointer)
    }
    finally {
        if ($securePointer -ne [IntPtr]::Zero) {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($securePointer)
        }
        $applicationPassword.Dispose()
    }
}

$server = $null
$adminPassword = $null
$staffPassword = $null
try {
    $connectedDatabase = (& $psql -X -w -At -h $hostName -p $port -U $postgresUser `
        -d $database -v ON_ERROR_STOP=1 -c 'SELECT current_database();' | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or $connectedDatabase -ne $database) {
        throw "Could not verify the designated disposable database."
    }

    Write-Output '=== Activity 3: temporary installation and startup ==='
    Copy-Item -LiteralPath $appSource -Destination $tempCopy -Recurse
    $config = Join-Path $tempCopy 'config\database.php'
    $configText = Get-Content -LiteralPath $config -Raw
    $configText = [regex]::Replace($configText, "define\('DB_NAME',\s*'[^']+'\);",
        "define('DB_NAME', '$database');")
    $configText = [regex]::Replace($configText, "define\('DB_PASS',\s*'[^']*'\);",
        "define('DB_PASS', getenv('PARK_IT_TEST_DB_PASSWORD') ?: '');")
    $configText = [regex]::Replace($configText, "define\('BASE_URL',\s*'[^']*'\);",
        "define('BASE_URL', '');")
    [System.IO.File]::WriteAllText($config, $configText, (New-Object System.Text.UTF8Encoding($false)))

    $phpFiles = @(Get-ChildItem -LiteralPath $tempCopy -Recurse -File -Filter '*.php')
    $lintFailures = @()
    foreach ($file in $phpFiles) {
        $lintOutput = & $php -l $file.FullName 2>&1
        if ($LASTEXITCODE -ne 0) { $lintFailures += ($file.Name + ': ' + ($lintOutput -join ' ')) }
    }
    Write-Output "PHP files linted: $($phpFiles.Count)"
    Write-Output "PHP lint failures: $($lintFailures.Count)"
    if ($lintFailures.Count -gt 0) { $lintFailures | ForEach-Object { Write-Output $_ } }
    if ($lintFailures.Count -gt 0) { throw "PHP syntax check failed; stopping before application startup." }

    $webPort = 18763
    while (Get-NetTCPConnection -State Listen -LocalPort $webPort -ErrorAction SilentlyContinue) {
        $webPort++
    }
    $stdout = Join-Path $tempCopy 'php-server.stdout.log'
    $stderr = Join-Path $tempCopy 'php-server.stderr.log'
    $server = Start-Process -FilePath $php `
        -ArgumentList @('-S', "127.0.0.1:$webPort", '-t', $tempCopy) `
        -PassThru -RedirectStandardOutput $stdout -RedirectStandardError $stderr
    $baseUrl = "http://127.0.0.1:$webPort"
    Start-Sleep -Seconds 2
    $homeResponse = Invoke-WebRequest -UseBasicParsing -Uri "$baseUrl/" -TimeoutSec 15
    Write-Output "Loopback HTTP status: $([int]$homeResponse.StatusCode)"
    Write-Output "Login page rendered: $([bool]($homeResponse.Content -match 'Sign In'))"

    $seed = Invoke-WebRequest -UseBasicParsing -Uri "$baseUrl/config/seed.php" -TimeoutSec 15
    Write-Output "Disposable database seed completed: $([bool]($seed.Content -match 'Database initialization completed successfully'))"

    $adminPassword = Read-ParkItApplicationPassword -Username 'admin'
    $adminPage = Invoke-WebRequest -UseBasicParsing -Uri "$baseUrl/auth/login.php" `
        -Method Post -Body @{ username = 'admin'; password = $adminPassword } `
        -SessionVariable adminSession -TimeoutSec 15
    Write-Output "Admin login reached dashboard: $([bool]($adminPage.Content -match 'System Overview Dashboard'))"

    $staffPassword = Read-ParkItApplicationPassword -Username 'staff'
    $staffPage = Invoke-WebRequest -UseBasicParsing -Uri "$baseUrl/auth/login.php" `
        -Method Post -Body @{ username = 'staff'; password = $staffPassword } `
        -SessionVariable staffSession -TimeoutSec 15
    Write-Output "Staff login reached dashboard: $([bool]($staffPage.Content -match 'System Overview Dashboard'))"

    $adminVehicles = Invoke-WebRequest -UseBasicParsing -Uri "$baseUrl/modules/vehicles/index.php" `
        -WebSession $adminSession -TimeoutSec 15
    $staffVehicles = Invoke-WebRequest -UseBasicParsing -Uri "$baseUrl/modules/vehicles/index.php" `
        -WebSession $staffSession -TimeoutSec 15
    Write-Output "Admin can open vehicle module: $([int]$adminVehicles.StatusCode -eq 200)"
    Write-Output "Staff can open vehicle module: $([int]$staffVehicles.StatusCode -eq 200)"

    $anonymousApiStatus = 'not returned'
    try {
        $null = Invoke-WebRequest -UseBasicParsing -Uri "$baseUrl/modules/monitoring/api_status.php" -TimeoutSec 15
        $anonymousApiStatus = 'unexpected HTTP success'
    }
    catch {
        if ($_.Exception.Response) {
            $anonymousApiStatus = [int]$_.Exception.Response.StatusCode
        }
        else {
            throw
        }
    }
    Write-Output "Anonymous monitoring API HTTP status: $anonymousApiStatus"

    Write-Output '=== Activity 4: disposable database and application-role checks ==='
    Invoke-ParkItSql -TargetDatabase $database -Sql `
        "SELECT current_database() AS database, current_user, rolsuper, rolcreatedb, rolcreaterole FROM pg_roles WHERE rolname=current_user;"
    Invoke-ParkItSql -TargetDatabase $database -Sql `
        "SELECT tablename FROM pg_tables WHERE schemaname='public' ORDER BY tablename;"
    Invoke-ParkItSql -TargetDatabase $database -Sql `
        "SELECT username, role FROM public.staff_user ORDER BY username;"

    Write-Output '=== Activity 5: health, monitoring, and maintenance ==='
    Invoke-ParkItSql -TargetDatabase $database -Sql `
        "SELECT current_database(), version(), pg_size_pretty(pg_database_size(current_database())) AS database_size;"
    Invoke-ParkItSql -TargetDatabase $database -Sql `
        "SELECT relname, n_live_tup, n_dead_tup, last_analyze, last_autoanalyze FROM pg_stat_user_tables ORDER BY relname;"
    Invoke-ParkItSql -TargetDatabase $database -Sql `
        "SELECT datname, usename, state, wait_event_type FROM pg_stat_activity WHERE datname=current_database() ORDER BY usename;"
    Invoke-ParkItSql -TargetDatabase $database -Sql `
        "SELECT name, setting FROM pg_settings WHERE name IN ('log_destination','logging_collector','log_min_duration_statement') ORDER BY name;"
    Invoke-ParkItSql -TargetDatabase $database -Sql `
        "SELECT name, size, modification FROM pg_ls_logdir() ORDER BY modification DESC LIMIT 5;"
    Invoke-ParkItSql -TargetDatabase $database -Sql 'ANALYZE VERBOSE public.parking_zone;'
    Invoke-ParkItSql -TargetDatabase $database -Sql 'ANALYZE VERBOSE public.payment;'
    Invoke-ParkItSql -TargetDatabase $database -Sql 'ANALYZE VERBOSE public.staff_user;'
    Invoke-ParkItSql -TargetDatabase $database -Sql 'ANALYZE VERBOSE public."transaction";'
    Invoke-ParkItSql -TargetDatabase $database -Sql 'ANALYZE VERBOSE public.vehicle;'
    Invoke-ParkItSql -TargetDatabase $database -Sql `
        'VACUUM (ANALYZE, VERBOSE) public.parking_zone;'
    Invoke-ParkItSql -TargetDatabase $database -Sql `
        "EXPLAIN (ANALYZE, BUFFERS) SELECT z.zone_id, COUNT(t.transaction_id) FROM public.parking_zone z LEFT JOIN public.""transaction"" t ON t.zone_id=z.zone_id AND t.status='Active' GROUP BY z.zone_id;"

    Write-Output 'Rerun finished. The original project files were not edited.'
}
finally {
    if ($server -and -not $server.HasExited) {
        Stop-Process -Id $server.Id -Force
    }
    Remove-Item Env:\PARK_IT_TEST_DB_PASSWORD -ErrorAction SilentlyContinue
    Remove-Item Env:\PGPASSWORD -ErrorAction SilentlyContinue
    $adminPassword = $null
    $staffPassword = $null
    if (Test-Path -LiteralPath $tempCopy) {
        Remove-Item -LiteralPath $tempCopy -Recurse -Force
    }
}
