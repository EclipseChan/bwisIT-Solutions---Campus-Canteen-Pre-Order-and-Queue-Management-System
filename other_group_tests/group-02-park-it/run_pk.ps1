# run_pk.ps1 - Activities 3 to 6 for Park It (PHP + PostgreSQL, group 2), tested by G08
#   cd $HOME\dba\pk; Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\run_pk.ps1 -Phase deploy   (A3: README steps, database checks, seed, first start)
#   .\run_pk.ps1 -Phase app      (A3: application tests through the web pages; leaves the app running for screenshots)
#   .\run_pk.ps1 -Phase a4       (A4: roles from user-role.md, privileges, app as postgres/parkit_app, admin vs staff)
#   .\run_pk.ps1 -Phase a56      (A5 maintenance and A6 backup/restore/recovery; stops the app)
param([ValidateSet('deploy','app','a4','a4b','a56')][string]$Phase = 'deploy', [string]$DB = 'grp_parkitdb')

$BASE = "$HOME\dba\pk"; $SRC = "$BASE\park-it-database-main\park-it"; $WWW = "$BASE\www"; $APP = "$WWW\park-it"; $URL = 'http://localhost:8000'
$E = "$HOME\dba\evidence\gPK"; New-Item -ItemType Directory -Force $BASE, $E, "$HOME\dba\backups" | Out-Null
$sec = Read-Host "postgres password" -AsSecureString
$PGA = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
$env:PGPASSWORD = $PGA
$APPU = 'parkit_app'; $APPPW = 'ParkItApp2026!'

function Run { & $args[0] @($args | Select-Object -Skip 1) 2>&1 | ForEach-Object { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_.Exception.Message } else { "$_" } } }
function Q($sql, $db = $DB, $role = $null) {
    if ($role) { $env:PGOPTIONS = "-c role=$role" } else { Remove-Item Env:PGOPTIONS -ErrorAction SilentlyContinue }
    $tag = if ($role) { "$role" } else { "postgres" }
    "--- [$tag@$db] $sql"
    Run psql -U postgres -h localhost -d $db -c $sql
    Remove-Item Env:PGOPTIONS -ErrorAction SilentlyContinue
    ""
}
function QL($sql, $user, $pw, $db = $DB) {
    $env:PGPASSWORD = $pw
    "--- [login $user@$db] $sql"
    Run psql -U $user -h localhost -d $db -c $sql
    $env:PGPASSWORD = $PGA
    ""
}
function Scalar($sql, $db = $DB) { (Run psql -U postgres -h localhost -d $db -At -c $sql | Out-String).Trim() }
function Save($name) { $l = @($input); $l | Out-File -FilePath "$E\$name" -Encoding utf8; $l }
function PortPid($port) { (Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue | Select-Object -First 1).OwningProcess }
function StopApp { $p = PortPid 8000; if ($p) { & taskkill /PID $p /T /F 2>&1 | Out-Null; Start-Sleep 1; "stopped PHP server (pid $p)" } }

# copy park-it into www\park-it (the same layout as C:\xampp\htdocs\park-it), set the connection the way README Step 8 says, start php -S
function SetConn($user, $pw, $db) {
    Remove-Item $WWW -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Force $WWW | Out-Null
    Copy-Item $SRC $APP -Recurse
    $f = "$APP\config\database.php"
    $t = Get-Content $f -Raw
    $t = $t -replace "define\('DB_NAME', '[^']*'\)", "define('DB_NAME', '$db')"
    $t = $t -replace "define\('DB_USER', '[^']*'\)", "define('DB_USER', '$user')"
    $t = $t -replace "define\('DB_PASS', '[^']*'\)", "define('DB_PASS', '$pw')"
    [IO.File]::WriteAllText($f, $t)
}
function StartApp($user = 'postgres', $pw = $PGA, $db = $DB) {
    StopApp | Out-Null
    SetConn $user $pw $db
    Remove-Item "$BASE\php_out.txt", "$BASE\php_err.txt" -ErrorAction SilentlyContinue
    Start-Process php -ArgumentList '-S', 'localhost:8000', '-t', $WWW -WorkingDirectory $BASE -RedirectStandardOutput "$BASE\php_out.txt" -RedirectStandardError "$BASE\php_err.txt" -WindowStyle Hidden
    for ($i = 0; $i -lt 20 -and -not (PortPid 8000); $i++) { Start-Sleep 1 }
    $st = 'NOT listening'; if (PortPid 8000) { $st = 'listening on http://localhost:8000/park-it/' }
    "php server: $st  (DB_NAME=$db DB_USER=$user)"
}

# one web call with a cookie jar per user. fields are form fields; redirects are followed
function W($method, $path, [string[]]$fields = @(), $note = '', $jar = 'admin', $hdr = $null, [switch]$nofollow) {
    $a = @('-s', '-m', '60', '-b', "$BASE\jar_$jar.txt", '-c', "$BASE\jar_$jar.txt", '-o', "$BASE\body.txt", '-D', "$BASE\hdr.txt", '-w', '%{http_code}|%{num_redirects}|%{url_effective}')
    if (-not $nofollow) { $a += '-L' }
    if ($hdr) { $a += @('-H', $hdr) }
    if ($method -eq 'POST') {
        foreach ($f in $fields) { $a += @('--data-urlencode', $f) }
        if (-not $fields) { $a += @('-d', 'x=1') }
    }
    $a += "$URL$path"
    $r = (& curl.exe @a 2>&1 | Out-String).Trim()
    $script:LastBody = Get-Content "$BASE\body.txt" -Raw -ErrorAction SilentlyContinue
    if (-not $script:LastBody) { $script:LastBody = '' }
    $p = $r.Split('|'); $code = $p[0]; $final = ''; if ($p.Count -gt 2) { $final = $p[2].Replace($URL, '') }
    $m = [regex]::Match($script:LastBody, 'class="alert[^"]*">(.*?)</div>', 'Singleline')
    $al = ''; if ($m.Success) { $al = '  message: ' + ([regex]::Replace($m.Groups[1].Value, '<[^>]+>', '').Trim() -replace '\s+', ' ') }
    $d = ''; if ($fields) { $d = '  data=' + ($fields -join '&') }
    $line = "$method $path$d  [$jar]  ->  HTTP $code"
    if ($p.Count -gt 1 -and $p[1] -ne '0') { $line += " (redirected to $final)" }
    $line += $al
    if ($note) { $line += "   <$note>" }
    $line
}
function Login($user, $pw, $jar, $note = '') { W 'POST' '/park-it/auth/login.php' @("username=$user", "password=$pw") $note $jar }
function Plate($plate, $type = 'Car', $jar = 'admin', $note = '', $zone = '1') { W 'POST' '/park-it/modules/vehicles/index.php' @('action=register_entry', "license_plate=$plate", "vehicle_type=$type", "zone_id=$zone") $note $jar }
function Pay($tid, $method, $jar = 'admin', $note = '', $lost = '0') { W 'POST' '/park-it/modules/payments/process.php' @("transaction_id=$tid", "payment_method=$method", "is_lost_ticket=$lost") $note $jar }
function Tx($plate) { Scalar "select t.transaction_id from public.transaction t join public.vehicle v on v.vehicle_id=t.vehicle_id where v.license_plate='$plate' order by 1 desc limit 1" }
function Back($plate, $interval) { Q "update public.transaction set entry_time = localtimestamp - interval '$interval' where transaction_id = (select t.transaction_id from public.transaction t join public.vehicle v on v.vehicle_id=t.vehicle_id where v.license_plate='$plate' and t.status='Active' order by 1 desc limit 1)" }
function Api($jar = 'admin') { $a = @('-s', '-m', '30', '-b', "$BASE\jar_$jar.txt", '-w', ' HTTP %{http_code}', "$URL/park-it/modules/monitoring/api_status.php"); $x = (& curl.exe @a 2>&1 | Out-String).Trim(); if ($x.Length -gt 330) { $x = $x.Substring(0, 330) + '...' }; "GET modules/monitoring/api_status.php [$jar] -> $x" }
function Fresh { Remove-Item "$BASE\jar_*.txt" -ErrorAction SilentlyContinue }

# ============================================================== DEPLOY
if ($Phase -eq 'deploy') {
    & {
        "run at $(Get-Date)"
        $z = "$BASE\park-it.zip"
        Remove-Item "$BASE\park-it-database-main" -Recurse -Force -ErrorAction SilentlyContinue
        Expand-Archive $z $BASE -Force
        "extracted $z"
        "--- prerequisites"
        Run psql --version
        Run php -v | Select-Object -First 1
        $ext = @(Run php -m | Where-Object { $_ -match '^(pdo_pgsql|pgsql)$' }) -join ', '
        "php extensions: $ext"
        "the README asks for XAMPP; this test serves the same park-it folder with PHP's built-in server from a folder laid out like htdocs (www\park-it), same PHP"
        "--- README Step 2: database named grp_parkitdb"
        foreach ($d in "${DB}_restore", "${DB}_recovery", "${DB}_alt", $DB) { Run psql -U postgres -h localhost -d postgres -c "DROP DATABASE IF EXISTS $d" | Out-Null }
        Run psql -U postgres -h localhost -d postgres -c "CREATE DATABASE $DB"
        "--- README Step 3-4: schema.sql. psql can read the \restrict line, so it was run unedited"
        $has = @(Select-String -Path "$SRC\schema.sql" -Pattern '^\\(restrict|unrestrict)').Count
        "lines starting with a backslash command (restrict/unrestrict) in schema.sql: $has"
        Run psql -U postgres -h localhost -d $DB -v ON_ERROR_STOP=0 -f "$SRC\schema.sql"
        "--- second run of schema.sql (is it repeatable?)"
        Run psql -U postgres -h localhost -d $DB -f "$SRC\schema.sql" | Select-Object -First 6
        "--- tables created (README says 5)"
        Q "select table_schema, table_name from information_schema.tables where table_schema not in ('pg_catalog','information_schema') order by 1,2"
        Q "select conrelid::regclass as tbl, conname, contype, pg_get_constraintdef(oid) from pg_constraint where connamespace='public'::regnamespace order by 1,2"
        Q "select indexname, tablename from pg_indexes where schemaname='public' order by 2,1"
        Q "select count(*) as triggers from pg_trigger where not tgisinternal"
        Q "select tablename, tableowner from pg_tables where schemaname='public' order by 1"
        Q "select datname, datacl from pg_database where datname='$DB'"
        "--- README Step 8: config\database.php as shipped"
        $cfg = @(Select-String -Path "$SRC\config\database.php" -Pattern "define\('DB_" | ForEach-Object { $_.Line.Trim() }) -join ' | '
        "shipped settings: $cfg"
        "README says to put your own password in DB_PASS. The test copy gets the postgres password the same way."
        "--- README Step 9-10: start the app and run config\seed.php"
        Fresh
        StartApp
        W 'GET' '/park-it/' @() 'front page before the seed, not logged in' 'admin'
        W 'GET' '/park-it/config/seed.php' @() 'seed run 1 (no login needed)' 'admin'
        W 'GET' '/park-it/config/seed.php' @() 'seed run 2 (repeatable?)' 'admin'
        Q "select user_id, username, role, left(password_hash,7) as hash_prefix, length(password_hash) as hash_len from public.staff_user order by 1"
        Q "select * from public.parking_zone"
        "--- is the seed page reachable by an anonymous visitor after setup? (no cookie sent)"
        Fresh
        W 'GET' '/park-it/config/seed.php' @() 'anonymous, after setup' 'anon'
        "--- README Step 11: login page and who can reach what without logging in"
        Fresh
        W 'GET' '/park-it/auth/login.php' @() 'login page' 'anon'
        foreach ($pg in '/park-it/dashboard.php', '/park-it/modules/vehicles/index.php', '/park-it/modules/payments/index.php', '/park-it/modules/payments/history.php', '/park-it/modules/monitoring/index.php') { W 'GET' $pg @() 'anonymous' 'anon' -nofollow }
        Api 'anon'
        "--- front-end source facts"
        $ih = @(Select-String -Path "$SRC\*\*.php", "$SRC\modules\*\*.php" -Pattern 'htmlspecialchars').Count
        "htmlspecialchars calls in PHP files: $ih"
        $ex = @(Select-String -Path "$SRC\*\*.php", "$SRC\modules\*\*.php", "$SRC\*.php" -Pattern 'https?://' | ForEach-Object { $_.Line.Trim() } | Where-Object { $_ -match 'src=|href=' }) -join ' | '
        "external resources loaded by the pages: $ex"
        $csrf = @(Select-String -Path "$SRC\*.php", "$SRC\*\*.php", "$SRC\modules\*\*.php" -Pattern 'csrf|token' -ErrorAction SilentlyContinue).Count
        "lines mentioning csrf or token in the PHP files: $csrf"
    } | Save 'a3_deploy.txt'
    return
}

# ============================================================== APP
if ($Phase -eq 'app') {
    & {
        "run at $(Get-Date)"
        Fresh
        StartApp
        Q "show timezone"
        Q "select count(*) from public.vehicle"
        "==== login"
        Login 'admin' 'wrong' 'admin' 'wrong password'
        Login 'nobody' 'x' 'admin' 'unknown user'
        Login "' OR 1=1 --" 'x' 'admin' 'SQL text as username'
        Login '' '' 'admin' 'empty fields'
        W 'GET' '/park-it/dashboard.php' @() 'still not logged in' 'admin' -nofollow
        Login 'admin' 'admin123' 'admin' 'default admin account from the README'
        Login 'staff' 'staff123' 'staff' 'default staff account'
        W 'GET' '/park-it/dashboard.php' @() 'dashboard' 'admin'
        "==== Module 1: vehicle entry (as admin)"
        Plate 'ABC-1234' 'Car' 'admin' 'valid car'
        Plate 'MOT-001' 'Motorcycle' 'admin' 'valid motorcycle'
        Plate 'abc-1234' 'Car' 'admin' 'same plate, lower case, vehicle still parked'
        Plate 'XYZ 777' 'Car' 'admin' 'plate with a space'
        Plate 'AB@#1' 'Car' 'admin' 'invalid characters'
        Plate '' 'Car' 'admin' 'empty plate'
        Plate 'AAAAAAAAAAAAAAAAAAAAA' 'Car' 'admin' '21 characters'
        Plate 'TRK-001' 'Truck' 'admin' 'type not allowed'
        Plate 'ZON-001' 'Car' 'admin' 'zone 0' '0'
        Plate 'ZON-002' 'Car' 'admin' 'zone that does not exist' '999'
        Plate "X'); DROP TABLE public.vehicle;--" 'Car' 'admin' 'SQL text in the plate'
        Plate '---' 'Car' 'admin' 'plate made only of hyphens'
        Plate ' - ' 'Car' 'admin' 'plate made of spaces and a hyphen'
        Q "select vehicle_id, license_plate, vehicle_type from public.vehicle order by 1"
        Q "select transaction_id, vehicle_id, zone_id, status, is_lost_ticket from public.transaction order by 1"
        Q "select zone_name, max_capacity, current_active_count from public.parking_zone"
        "==== vehicle edit and delete"
        $v1 = Scalar "select vehicle_id from public.vehicle where license_plate='ABC-1234'"
        W 'POST' '/park-it/modules/vehicles/edit.php' @("vehicle_id=$v1", 'license_plate=abc-9999', 'vehicle_type=Car') 'valid edit' 'admin'
        W 'POST' '/park-it/modules/vehicles/edit.php' @("vehicle_id=$v1", 'license_plate=MOT-001', 'vehicle_type=Car') 'plate already used by another vehicle' 'admin'
        W 'POST' '/park-it/modules/vehicles/edit.php' @("vehicle_id=$v1", 'license_plate=ABC-9999', 'vehicle_type=Bus') 'invalid type' 'admin'
        W 'POST' '/park-it/modules/vehicles/edit.php' @('vehicle_id=99999', 'license_plate=NEW-1', 'vehicle_type=Car') 'vehicle that does not exist' 'admin'
        "changing the type of a parked vehicle changes its fee: Car to Motorcycle"
        W 'POST' '/park-it/modules/vehicles/edit.php' @("vehicle_id=$v1", 'license_plate=ABC-9999', 'vehicle_type=Motorcycle') 'edit type of a parked vehicle' 'admin'
        W 'POST' '/park-it/modules/vehicles/edit.php' @("vehicle_id=$v1", 'license_plate=ABC-9999', 'vehicle_type=Car') 'set it back' 'admin'
        W 'POST' '/park-it/modules/vehicles/delete.php' @("vehicle_id=$v1") 'delete a vehicle that has a transaction' 'admin'
        W 'GET' '/park-it/modules/vehicles/delete.php?vehicle_id=1' @() 'delete by GET' 'admin'
        Q "insert into public.vehicle(license_plate, vehicle_type) values ('LONE-1','Car')"
        $v2 = Scalar "select vehicle_id from public.vehicle where license_plate='LONE-1'"
        W 'POST' '/park-it/modules/vehicles/delete.php' @("vehicle_id=$v2") 'delete a vehicle with no transactions' 'admin'
        Q "select count(*) as lone_vehicle_left from public.vehicle where license_plate='LONE-1'"
        "==== Module 2: payment search and fee"
        W 'GET' '/park-it/modules/payments/index.php?plate=ABC-9999' @() 'search active vehicle' 'admin'
        W 'GET' '/park-it/modules/payments/index.php?plate=NOPE-1' @() 'search a plate that is not parked' 'admin'
        W 'GET' '/park-it/modules/payments/index.php?plate=ABC-9999&lost_ticket=1' @() 'lost ticket view' 'admin'
        "-- fee table, using entry times moved back in the database (the app has no way to enter a past time)"
        Plate 'CAR-2H' 'Car' 'admin' 'for 2 hours'
        Plate 'CAR-3H' 'Car' 'admin' 'for exactly 3 hours'
        Plate 'CAR-31' 'Car' 'admin' 'for 3 hours 1 minute'
        Plate 'CAR-5H' 'Car' 'admin' 'for 5 hours'
        Plate 'MOT-2H' 'Motorcycle' 'admin' 'for 2 hours'
        Plate 'MOT-6H' 'Motorcycle' 'admin' 'for 6 hours'
        Plate 'LOST-1' 'Car' 'admin' 'lost ticket'
        Back 'CAR-2H' '2 hours'; Back 'CAR-3H' '3 hours'; Back 'CAR-31' '3 hours 1 minute'; Back 'CAR-5H' '5 hours'; Back 'MOT-2H' '2 hours'; Back 'MOT-6H' '6 hours'; Back 'LOST-1' '9 hours'
        Pay (Tx 'CAR-2H') 'Cash' 'admin' 'expect 50'
        Pay (Tx 'CAR-3H') 'GCash' 'admin' 'expect 50 or 60 (boundary)'
        Pay (Tx 'CAR-31') 'Maya' 'admin' 'expect 60'
        Pay (Tx 'CAR-5H') 'Credit/Debit Card' 'staff' 'expect 70, paid as staff'
        Pay (Tx 'MOT-2H') 'Cash' 'admin' 'expect 30'
        Pay (Tx 'MOT-6H') 'Cash' 'admin' 'expect 60'
        Pay (Tx 'LOST-1') 'Cash' 'admin' 'lost ticket, expect 200' '1'
        Q "select v.license_plate, v.vehicle_type, p.amount, p.payment_method, t.status, t.is_lost_ticket, t.exit_time - t.entry_time as parked from public.payment p join public.transaction t using (transaction_id) join public.vehicle v using (vehicle_id) order by p.payment_id"
        "-- invalid payments"
        $t1 = Tx 'ABC-9999'
        Pay $t1 'Bitcoin' 'admin' 'method not allowed'
        Pay '99999' 'Cash' 'admin' 'transaction that does not exist'
        Pay '0' 'Cash' 'admin' 'transaction id 0'
        Pay (Tx 'CAR-2H') 'Cash' 'admin' 'same transaction paid a second time'
        W 'GET' '/park-it/modules/payments/process.php' @() 'process page opened with GET' 'admin'
        Pay $t1 'Cash' 'admin' 'pay the parked car now (about 1 hour)'
        Q "select count(*) as payments, sum(amount) as total from public.payment"
        Q "select zone_name, max_capacity, current_active_count from public.parking_zone"
        W 'GET' '/park-it/modules/payments/history.php' @() 'payment history' 'admin'
        "==== Module 3: monitoring and capacity"
        Api 'admin'
        Q "select count(*) as active_now from public.transaction where status='Active'"
        Q "insert into public.vehicle(license_plate, vehicle_type) select 'FILL-' || g, 'Car' from generate_series(1,40) g"
        Q "insert into public.transaction(vehicle_id, zone_id, entry_time, status, is_lost_ticket) select vehicle_id, 1, localtimestamp, 'Active', false from public.vehicle where license_plate like 'FILL-%'"
        "after adding 40 active vehicles directly in SQL, the zone counter still shows the old value until a page recounts it"
        Q "select current_active_count from public.parking_zone"
        Api 'admin'
        Q "select current_active_count from public.parking_zone"
        $n = [int](Scalar "select count(*) from public.transaction where status='Active'")
        $need = 50 - $n
        "active vehicles now $n, adding $need more to reach 50"
        if ($need -gt 0) {
            Q "insert into public.vehicle(license_plate, vehicle_type) select 'FULL-' || g, 'Car' from generate_series(1,$need) g"
            Q "insert into public.transaction(vehicle_id, zone_id, entry_time, status, is_lost_ticket) select vehicle_id, 1, localtimestamp, 'Active', false from public.vehicle where license_plate like 'FULL-%'"
        }
        Api 'admin'
        Plate 'OVER-1' 'Car' 'admin' 'lot is full, entry should be refused'
        Q "select count(*) as vehicle_rows_for_OVER1 from public.vehicle where license_plate='OVER-1'"
        Pay (Tx 'FULL-1') 'Cash' 'admin' 'one car leaves, a space opens'
        Api 'admin'
        Plate 'OVER-2' 'Car' 'admin' 'entry after a space opened'
        "==== direct database rules (what the database itself allows)"
        Q "insert into public.transaction(vehicle_id, zone_id, entry_time, status) select vehicle_id, 1, localtimestamp, 'Banana' from public.vehicle limit 1"
        Q "insert into public.vehicle(license_plate, vehicle_type) values ('SQL-TRUCK','Truck')"
        Q "update public.transaction set exit_time = entry_time - interval '1 day' where transaction_id = (select max(transaction_id) from public.transaction)"
        Q "insert into public.payment(transaction_id, amount, payment_method, payment_time) select max(transaction_id), 0, 'x', now() from public.transaction"
        Q "update public.parking_zone set current_active_count = -5"
        Q "update public.parking_zone set current_active_count = 51"
        Q "select count(*) as two_active_transactions_for_one_vehicle from (select vehicle_id from public.transaction where status='Active' group by 1 having count(*)>1) x"
        Q "select count(*) as paid_but_still_active from public.transaction t join public.payment p using (transaction_id) where t.status='Active'"
        "==== response headers and cookies"
        W 'GET' '/park-it/dashboard.php' @() 'dashboard headers' 'admin' | Out-Null
        Get-Content "$BASE\hdr.txt" | Select-Object -First 14
        "cookie jar (HttpOnly shows as a #HttpOnly_ prefix):"
        Get-Content "$BASE\jar_admin.txt" | Where-Object { $_ -match 'PHPSESSID' }
        "==== php server log"
        $rq = @(Get-Content "$BASE\php_err.txt" -ErrorAction SilentlyContinue | Select-String 'Accepted').Count
        "requests logged: $rq"
        Get-Content "$BASE\php_err.txt" -ErrorAction SilentlyContinue | Select-String 'Warning|Notice|Fatal|Deprecated' | Select-Object -First 8 | ForEach-Object { $_.Line }
        "=== database after the tests"
        Q "select (select count(*) from public.vehicle) vehicles, (select count(*) from public.transaction) transactions, (select count(*) from public.payment) payments, (select current_active_count from public.parking_zone) zone_count"
        "left running for screenshots: http://localhost:8000/park-it/  (admin / admin123)"
    } | Save 'a3_app.txt'
    return
}

# ============================================================== A4
if ($Phase -eq 'a4') {
    & {
        "run at $(Get-Date)"
        StopApp
        "=== PART A: the role SQL from user-role.md sections 4.1 to 4.3, copied as written (only the sample password replaced)"
        Q "select rolname from pg_roles where rolname ~ '^parkit' order by 1" 'postgres'
        Run psql -U postgres -h localhost -d $DB -f "$BASE\roles_doc.sql"
        "--- second run (is it repeatable?)"
        Run psql -U postgres -h localhost -d $DB -f "$BASE\roles_doc.sql"
        Q "select rolname, rolsuper, rolcreatedb, rolcreaterole, rolinherit, rolcanlogin, left(rolpassword,14) as pw_scheme from pg_authid where rolname ~ '^parkit' order by 1"
        Q "select r.rolname as member, g.rolname as member_of from pg_auth_members m join pg_roles r on r.oid=m.member join pg_roles g on g.oid=m.roleid where r.rolname ~ '^parkit'"
        Q "select tablename, concat(case when has_table_privilege('parkit_app',format('public.%I',tablename),'SELECT') then 'S' else '-' end, case when has_table_privilege('parkit_app',format('public.%I',tablename),'INSERT') then 'I' else '-' end, case when has_table_privilege('parkit_app',format('public.%I',tablename),'UPDATE') then 'U' else '-' end, case when has_table_privilege('parkit_app',format('public.%I',tablename),'DELETE') then 'D' else '-' end, case when has_table_privilege('parkit_app',format('public.%I',tablename),'TRUNCATE') then 'T' else '-' end) as parkit_app_SIUDT from pg_tables where schemaname='public' order by 1"
        Q "select c.relname as sequence, has_sequence_privilege('parkit_app', c.oid, 'USAGE') as usage from pg_class c where c.relkind='S' and c.relnamespace='public'::regnamespace order by 1"
        Q "select has_schema_privilege('parkit_app','public','USAGE') schema_usage, has_schema_privilege('parkit_app','public','CREATE') schema_create, has_database_privilege('parkit_app','$DB','CONNECT') db_connect"
        Q "select datname, datacl from pg_database where datname='$DB'"
        "=== PART B: real login as parkit_app, privileges exactly as the document grants them"
        QL 'select count(*) from public.staff_user' $APPU $APPPW
        QL "update public.staff_user set role='Admin' where username='staff'" $APPU $APPPW
        QL "select password_hash from public.staff_user limit 1" $APPU $APPPW
        QL "insert into public.vehicle(license_plate, vehicle_type) values ('ROLE-1','Car')" $APPU $APPPW
        QL "select nextval('public.vehicle_vehicle_id_seq')" $APPU $APPPW
        QL "update public.payment set amount = 0 where false" $APPU $APPPW
        QL "delete from public.payment where false" $APPU $APPPW
        QL "delete from public.transaction where false" $APPU $APPPW
        QL "delete from public.vehicle where false" $APPU $APPPW
        QL "truncate public.payment" $APPU $APPPW
        QL "create table public.zz(x int)" $APPU $APPPW
        QL "drop table public.payment" $APPU $APPPW
        QL "create role zz_test" $APPU $APPPW
        QL "select rolname from pg_authid limit 1" $APPU $APPPW
        QL "vacuum public.vehicle" $APPU $APPPW
        QL "create temp table zz_t(x int)" $APPU $APPPW
        QL "select current_database()" $APPU $APPPW 'postgres'
        "=== PART C: the application running as parkit_app, privileges as documented (no sequence grant)"
        Fresh
        StartApp $APPU $APPPW $DB
        Login 'admin' 'admin123' 'admin' 'login (reads staff_user)'
        Plate 'A4-0001' 'Car' 'admin' 'register a vehicle entry as parkit_app'
        Q "select count(*) as a4_vehicle_rows from public.vehicle where license_plate='A4-0001'"
        W 'GET' '/park-it/dashboard.php' @() 'dashboard' 'admin'
        W 'GET' '/park-it/modules/payments/history.php' @() 'payment history' 'admin'
        Api 'admin'
        "--- the project does not say to grant sequence rights, so the same grant was added by the testing group (roles_fix.sql, GRANT USAGE, SELECT ON ALL SEQUENCES) and the same steps repeated"
        Run psql -U postgres -h localhost -d $DB -f "$BASE\roles_fix.sql"
        Plate 'A4-0001' 'Car' 'admin' 'register a vehicle entry, with sequence grant'
        Plate 'A4-0002' 'Motorcycle' 'admin' 'second entry'
        Back 'A4-0001' '4 hours'
        Pay (Tx 'A4-0001') 'Cash' 'admin' 'payment and exit as parkit_app'
        $va = Scalar "select vehicle_id from public.vehicle where license_plate='A4-0002'"
        W 'POST' '/park-it/modules/vehicles/edit.php' @("vehicle_id=$va", 'license_plate=A4-0002', 'vehicle_type=Car') 'edit a vehicle (UPDATE is granted)' 'admin'
        Q "insert into public.vehicle(license_plate, vehicle_type) values ('A4-LONE','Car')"
        $vl = Scalar "select vehicle_id from public.vehicle where license_plate='A4-LONE'"
        W 'POST' '/park-it/modules/vehicles/delete.php' @("vehicle_id=$vl") 'delete a vehicle with no transactions (DELETE not granted)' 'admin'
        Q "select count(*) as a4_lone_left from public.vehicle where license_plate='A4-LONE'"
        Q "select usename, application_name, count(*) from pg_stat_activity where datname='$DB' and usename is not null group by 1,2"
        "=== PART D: application roles (Admin and Staff). user-role.md says only the Administrator registers vehicles"
        W 'POST' '/park-it/auth/login.php' @('username=staff', 'password=staff123') 'staff login' 'staff'
        Plate 'STAFF-1' 'Car' 'staff' 'staff registers a vehicle'
        $vs = Scalar "select vehicle_id from public.vehicle where license_plate='STAFF-1'"
        W 'POST' '/park-it/modules/vehicles/edit.php' @("vehicle_id=$vs", 'license_plate=STAFF-1', 'vehicle_type=Motorcycle') 'staff edits a vehicle' 'staff'
        W 'GET' '/park-it/modules/vehicles/index.php' @() 'staff opens Module 1' 'staff'
        W 'GET' '/park-it/modules/payments/index.php' @() 'staff opens Module 2' 'staff'
        Pay (Tx 'STAFF-1') 'Cash' 'staff' 'staff takes a payment'
        $roleHits = @(Select-String -Path "$SRC\*.php", "$SRC\*\*.php", "$SRC\modules\*\*.php" -Pattern "isAdmin|'role'|\['role'\]" | ForEach-Object { "$($_.Filename):$($_.LineNumber): $($_.Line.Trim())" })
        "places in the PHP code that look at the role:"
        $roleHits
        "--- logout, then use the old session"
        W 'GET' '/park-it/auth/logout.php' @() 'logout' 'staff'
        W 'GET' '/park-it/modules/vehicles/index.php' @() 'after logout, same cookie' 'staff' -nofollow
        "--- a request from another website: forged form post with an Origin header and no token"
        W 'POST' '/park-it/modules/vehicles/index.php' @('action=register_entry', 'license_plate=CSRF-1', 'vehicle_type=Car', 'zone_id=1') 'Origin: http://evil.example' 'admin' 'Origin: http://evil.example'
        Q "select count(*) as csrf_rows from public.vehicle where license_plate='CSRF-1'"
        "--- repeated wrong passwords (6 tries), then the correct one"
        1..6 | ForEach-Object { W 'POST' '/park-it/auth/login.php' @('username=admin', "password=bad$_") "wrong password try $_" 'brute' }
        W 'POST' '/park-it/auth/login.php' @('username=admin', 'password=admin123') 'correct password right after' 'brute'
        "=== PART E: credentials and configuration"
        $pw = @(Select-String -Path "$SRC\config\database.php" -Pattern "DB_USER|DB_PASS" | ForEach-Object { $_.Line.Trim() }) -join ' | '
        "config\database.php in the repository: $pw"
        $seedpw = @(Select-String -Path "$SRC\config\seed.php" -Pattern "'password'" | ForEach-Object { $_.Line.Trim() }) -join ' | '
        "default passwords written in config\seed.php: $seedpw"
        Q "select username, role, left(password_hash,4) as algo, length(password_hash) as len from public.staff_user order by 1"
        "--- pg_hba.conf rules"
        Q "select line_number, type, database, user_name, address, auth_method from pg_hba_file_rules order by line_number"
    } | Save 'a4_access_tests.txt'
    return
}


# ============================================================== A4b (rerun of the application parts with free capacity)
if ($Phase -eq 'a4b') {
    & {
        "run at $(Get-Date)"
        "the first A4 run found the lot full (50 of 50) from the Activity 3 tests, so entries were refused for that reason. Capacity is freed here and the application tests are repeated"
        StopApp
        Q "delete from public.transaction where vehicle_id in (select vehicle_id from public.vehicle where license_plate ~ '^(FILL|FULL)-') and status='Active'"
        Q "select count(*) as active_now from public.transaction where status='Active'"
        "--- sequence rights taken away again so the document's grants are tested exactly as written"
        Q "REVOKE USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public FROM parkit_runtime_grp"
        Q "select c.relname as sequence, has_sequence_privilege('parkit_app', c.oid, 'USAGE') as usage from pg_class c where c.relkind='S' and c.relnamespace='public'::regnamespace order by 1"
        "=== PART C: the application running as parkit_app, privileges as documented (no sequence grant)"
        Fresh
        StartApp $APPU $APPPW $DB
        Login 'admin' 'admin123' 'admin' 'login (reads staff_user)'
        W 'GET' '/park-it/dashboard.php' @() 'dashboard (reads and recounts the zone)' 'admin'
        Plate 'A4-0001' 'Car' 'admin' 'register a vehicle entry as parkit_app, no sequence grant'
        Q "select count(*) as a4_vehicle_rows from public.vehicle where license_plate='A4-0001'"
        "--- same grant added by the testing group (roles_fix.sql: GRANT USAGE, SELECT ON ALL SEQUENCES), steps repeated"
        Run psql -U postgres -h localhost -d $DB -f "$BASE\roles_fix.sql"
        Plate 'A4-0001' 'Car' 'admin' 'register a vehicle entry, with sequence grant'
        Plate 'A4-0002' 'Motorcycle' 'admin' 'second entry'
        Back 'A4-0001' '4 hours'
        Pay (Tx 'A4-0001') 'Cash' 'admin' 'payment and exit as parkit_app (insert payment, update transaction and zone)'
        $va = Scalar "select vehicle_id from public.vehicle where license_plate='A4-0002'"
        W 'POST' '/park-it/modules/vehicles/edit.php' @("vehicle_id=$va", 'license_plate=A4-0002', 'vehicle_type=Car') 'edit a vehicle (UPDATE is granted)' 'admin'
        W 'GET' '/park-it/modules/payments/history.php' @() 'payment history' 'admin'
        Api 'admin'
        Q "insert into public.vehicle(license_plate, vehicle_type) values ('A4-LONE','Car')"
        $vl = Scalar "select vehicle_id from public.vehicle where license_plate='A4-LONE'"
        W 'POST' '/park-it/modules/vehicles/delete.php' @("vehicle_id=$vl") 'delete a vehicle with no transactions (DELETE not granted)' 'admin'
        Q "select count(*) as a4_lone_left from public.vehicle where license_plate='A4-LONE'"
        Q "select usename, application_name, count(*) from pg_stat_activity where datname='$DB' and usename is not null group by 1,2"
        "=== PART D: application roles. user-role.md says only the Administrator registers vehicles"
        W 'POST' '/park-it/auth/login.php' @('username=staff', 'password=staff123') 'staff login' 'staff'
        Plate 'STAFF-1' 'Car' 'staff' 'staff registers a vehicle'
        $vs = Scalar "select vehicle_id from public.vehicle where license_plate='STAFF-1'"
        W 'POST' '/park-it/modules/vehicles/edit.php' @("vehicle_id=$vs", 'license_plate=STAFF-1', 'vehicle_type=Motorcycle') 'staff edits a vehicle' 'staff'
        W 'GET' '/park-it/modules/vehicles/index.php' @() 'staff opens Module 1' 'staff'
        $vd = Scalar "select vehicle_id from public.vehicle where license_plate='STAFF-1'"
        Q "insert into public.vehicle(license_plate, vehicle_type) values ('STAFF-LONE','Car')" 
        Pay (Tx 'STAFF-1') 'Cash' 'staff' 'staff takes a payment and exits the vehicle'
        "--- logout, then use the old session"
        W 'GET' '/park-it/auth/logout.php' @() 'logout' 'staff'
        W 'GET' '/park-it/modules/vehicles/index.php' @() 'after logout, same cookie' 'staff' -nofollow
        "--- a request from another website: form post with an Origin header and no token"
        W 'POST' '/park-it/modules/vehicles/index.php' @('action=register_entry', 'license_plate=CSRF-1', 'vehicle_type=Car', 'zone_id=1') 'Origin: http://evil.example' 'admin' 'Origin: http://evil.example'
        Q "select count(*) as csrf_rows from public.vehicle where license_plate='CSRF-1'"
        "=== database state"
        Q "select (select count(*) from public.vehicle) vehicles, (select count(*) from public.transaction) transactions, (select count(*) from public.payment) payments"
        StopApp
    } | Save 'a4_app_roles.txt'
    return
}

# ============================================================== A5 + A6
if ($Phase -eq 'a56') {
    $F = "$HOME\dba\backups\${DB}_activity6.dump"
    & {
        "run at $(Get-Date)"
        Q "select version()" 'postgres'
        Q "select pg_size_pretty(pg_database_size('$DB')) as db_size"
        Q "select datname,numbackends,xact_commit,xact_rollback,blks_read,blks_hit,deadlocks,temp_files from pg_stat_database where datname='$DB'"
        Q "select pid,usename,application_name,state,left(query,60) as query from pg_stat_activity where datname='$DB'"
        Q "select relname,n_live_tup,n_dead_tup,last_vacuum,last_autovacuum,last_analyze,last_autoanalyze from pg_stat_user_tables order by relname"
        Q "select relname, pg_size_pretty(pg_total_relation_size(relid)) total, pg_size_pretty(pg_indexes_size(relid)) idx from pg_stat_user_tables order by pg_total_relation_size(relid) desc"
        Q "select indexrelname, relname, idx_scan from pg_stat_user_indexes order by relname, indexrelname"
        Q "show log_statement" 'postgres'
        Q "show log_min_duration_statement" 'postgres'
        Q "show max_connections" 'postgres'
        Q "show autovacuum" 'postgres'
        "--- can parkit_app run maintenance?"
        QL "VACUUM public.vehicle" $APPU $APPPW
        QL "ANALYZE public.vehicle" $APPU $APPPW
    } | Save 'a5_health.txt'
    & {
        $dd = Scalar "show data_directory" 'postgres'; $ld = Scalar "show log_directory" 'postgres'
        "data_directory=$dd"; "log_directory=$ld"
        $logs = Get-ChildItem "$dd\$ld" -Filter *.log -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 2
        foreach ($f in $logs) {
            "== $($f.FullName) ($($f.Length) bytes, $($f.LastWriteTime))"
            Get-Content $f.FullName -ErrorAction SilentlyContinue | Select-String 'ERROR|FATAL|WARNING|PANIC' | Select-Object -Last 120 | ForEach-Object { $_.Line }
        }
        "== PHP server output (warnings, notices, fatal errors)"
        $rq2 = @(Get-Content "$BASE\php_err.txt" -ErrorAction SilentlyContinue | Select-String 'Accepted').Count
        "requests in the PHP log: $rq2"
        Get-Content "$BASE\php_err.txt" -ErrorAction SilentlyContinue | Select-String 'Warning|Notice|Fatal|Deprecated' | Select-Object -First 10 | ForEach-Object { $_.Line }
    } | Save 'a5_logs.txt'
    & {
        Q "select relname,n_live_tup,n_dead_tup,last_vacuum,last_analyze from pg_stat_user_tables order by relname"
        Q "ANALYZE"
        Q "VACUUM (VERBOSE, ANALYZE) public.parking_zone"
        Q "VACUUM (VERBOSE, ANALYZE) public.vehicle"
        Q "select relname,n_live_tup,n_dead_tup,last_vacuum,last_analyze from pg_stat_user_tables order by relname"
        "--- query 1: search the active transaction for a plate (payments page)"
        Q "EXPLAIN (ANALYZE, BUFFERS) select t.transaction_id, t.vehicle_id, t.zone_id, t.entry_time, t.status, v.license_plate, v.vehicle_type from public.transaction t join public.vehicle v on v.vehicle_id=t.vehicle_id where v.license_plate='FILL-5' and t.status='Active'"
        "--- query 2: parking summary recount (runs on every dashboard and monitor refresh)"
        Q "EXPLAIN (ANALYZE, BUFFERS) select z.zone_id, z.max_capacity, z.current_active_count, count(t.transaction_id) from public.parking_zone z left join public.transaction t on z.zone_id=t.zone_id and t.status='Active' group by 1,2,3"
        "--- query 3: currently parked list"
        Q "EXPLAIN (ANALYZE, BUFFERS) select t.transaction_id, v.license_plate, v.vehicle_type, t.entry_time from public.transaction t join public.vehicle v on v.vehicle_id=t.vehicle_id where t.status='Active' order by t.entry_time"
        "--- query 4: payment history"
        Q "EXPLAIN (ANALYZE, BUFFERS) select p.payment_id, v.license_plate, p.amount, p.payment_method, p.payment_time from public.payment p join public.transaction t using (transaction_id) join public.vehicle v using (vehicle_id) order by p.payment_time desc"
        "--- the plate search with sequential scans disabled (one rolled back transaction)"
        Q "BEGIN; SET LOCAL enable_seqscan = off; EXPLAIN (ANALYZE) select t.transaction_id from public.transaction t join public.vehicle v on v.vehicle_id=t.vehicle_id where v.license_plate='FILL-5' and t.status='Active'; ROLLBACK"
        Q "select indexname, tablename from pg_indexes where schemaname='public' order by 2,1"
        "--- foreign key columns without an index"
        Q "select c.conrelid::regclass as tbl, a.attname as fk_column from pg_constraint c join pg_attribute a on a.attrelid=c.conrelid and a.attnum = any(c.conkey) where c.contype='f' and c.connamespace='public'::regnamespace and not exists (select 1 from pg_index i where i.indrelid=c.conrelid and (i.indkey::int2[])[0]=a.attnum) order by 1,2"
    } | Save 'a5_maintenance.txt'
    & {
        "run at $(Get-Date)"
        "no dedicated backup role exists in the project, so the dump is taken as postgres"
        Run pg_dump -U postgres -h localhost -Fc -d $DB -f $F
        "pg_dump exit code: $LASTEXITCODE"
        Get-Item $F | Format-List Name, Length, LastWriteTime
        Get-FileHash $F -Algorithm SHA256 | Format-List Algorithm, Hash, Path
        "--- pg_restore --list (first 70 lines)"
        Run pg_restore --list $F | Select-Object -First 70
        $td = @(Run pg_restore --list $F | Select-String 'TABLE DATA').Count
        $da = @(Run pg_restore --list $F | Select-String 'DEFAULT ACL').Count
        $ac = @(Run pg_restore --list $F | Select-String ' ACL ').Count
        "TABLE DATA entries in archive: $td ; DEFAULT ACL entries: $da ; ACL entries: $ac"
        "the README does not describe any backup procedure"
    } | Save 'a6_backup.txt'
    & {
        foreach ($d in "${DB}_restore", "${DB}_recovery") { Run psql -U postgres -h localhost -d postgres -c "DROP DATABASE IF EXISTS $d" }
        Run psql -U postgres -h localhost -d postgres -c "CREATE DATABASE ${DB}_restore"
        $sw = [Diagnostics.Stopwatch]::StartNew()
        $o = Run pg_restore -U postgres -h localhost -d "${DB}_restore" $F
        $ec = $LASTEXITCODE; $sw.Stop()
        "pg_restore exit code: $ec ; elapsed seconds: $([math]::Round($sw.Elapsed.TotalSeconds, 2))"
        if ($o) { $o } else { "no messages (no warnings or errors)" }
    } | Save 'a6_restore.txt'
    & {
        foreach ($d in $DB, "${DB}_restore") {
            "################ $d"
            Q "select (select count(*) from pg_tables where schemaname='public') tables,(select count(*) from pg_sequences where schemaname='public') sequences,(select count(*) from pg_indexes where schemaname='public') indexes" $d
            Q "select (select count(*) from public.vehicle) vehicle, (select count(*) from public.transaction) transaction, (select count(*) from public.payment) payment, (select count(*) from public.staff_user) staff_user, (select count(*) from public.parking_zone) parking_zone" $d
            Q "select contype,count(*) from pg_constraint where connamespace='public'::regnamespace group by contype order by contype" $d
            Q "select grantee, count(*) as table_grants from information_schema.role_table_grants where table_schema='public' group by 1 order by 1" $d
            Q "select md5(string_agg(t::text, '' order by t::text)) as payment_checksum from public.payment t" $d
            Q "select md5(string_agg(t::text, '' order by t::text)) as transaction_checksum from public.transaction t" $d
            Q "select md5(string_agg(t::text, '' order by t::text)) as staff_user_checksum from public.staff_user t" $d
            Q "select sequencename, last_value from pg_sequences where schemaname='public' order by 1" $d
            Q "insert into public.payment(transaction_id, amount, payment_method, payment_time) select transaction_id, -1, 'x', now() from public.transaction limit 1" $d
        }
        "=== the application against the restored database (as parkit_app)"
        Fresh
        StartApp $APPU $APPPW "${DB}_restore"
        Login 'admin' 'admin123' 'admin' 'login against the restored copy'
        W 'GET' '/park-it/dashboard.php' @() 'dashboard' 'admin'
        Api 'admin'
        W 'GET' '/park-it/modules/payments/history.php' @() 'payment history' 'admin'
        Q "select count(*) as active_in_restored_copy from public.transaction where status='Active'" "${DB}_restore"
        StopApp
    } | Save 'a6_verify.txt'
    & {
        Q "select datname,datacl from pg_database where datname like '${DB}%' order by 1" 'postgres'
        Q "select rolname from pg_roles where rolname ~ '^parkit' order by 1" $DB
        "--- table privileges of the roles: original vs restored copy"
        foreach ($d in $DB, "${DB}_restore") { Q "select grantee, count(*) as grants from information_schema.role_table_grants where table_schema='public' and grantee ~ '^parkit' group by 1 order by 1" $d }
        "--- login as the application account against the restored copy"
        QL "select count(*) from public.vehicle" $APPU $APPPW "${DB}_restore"
        QL "delete from public.payment where false" $APPU $APPPW "${DB}_restore"
        QL "select count(*) from public.staff_user" $APPU $APPPW "${DB}_restore"
        QL "select usename, count(*) from pg_stat_activity where usename is not null group by 1" $APPU $APPPW "${DB}_restore"
        Q "select tablename, tableowner from pg_tables where schemaname='public' order by 1" "${DB}_restore"
    } | Save 'a6_access.txt'
    & {
        "target table: payment (money records)"
        "== BEFORE (restored copy)"
        Q "select count(*) as rows, md5(string_agg(t::text, '' order by t::text)) as table_checksum from public.payment t" "${DB}_restore"
        "== INCIDENT: a bad update sets every payment to 0.01 and a delete removes the cash ones from the restored copy"
        Q "update public.payment set amount = 0.01" "${DB}_restore"
        Q "delete from public.payment where payment_method = 'Cash'" "${DB}_restore"
        "== AFTER LOSS"
        Q "select count(*) as rows, md5(string_agg(t::text, '' order by t::text)) as table_checksum from public.payment t" "${DB}_restore"
        Q "select coalesce(sum(amount),0) as total_collected from public.payment" "${DB}_restore"
        "== RECOVERY: restore the same dump into ${DB}_recovery"
        Run psql -U postgres -h localhost -d postgres -c "CREATE DATABASE ${DB}_recovery"
        Run pg_restore -U postgres -h localhost -d "${DB}_recovery" $F
        "pg_restore exit code: $LASTEXITCODE"
        "== RECOVERED"
        Q "select count(*) as rows, md5(string_agg(t::text, '' order by t::text)) as table_checksum from public.payment t" "${DB}_recovery"
        Q "select coalesce(sum(amount),0) as total_collected from public.payment" "${DB}_recovery"
        "== ORIGINAL DATABASE UNTOUCHED"
        Q "select count(*) as rows, md5(string_agg(t::text, '' order by t::text)) as table_checksum from public.payment t"
    } | Save 'a6_recovery.txt'
    StopApp
    return
}
