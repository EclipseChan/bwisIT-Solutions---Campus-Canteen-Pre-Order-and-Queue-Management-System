# run_bt.ps1 - Activities 3 to 6 for BoardTrack (Node.js + PostgreSQL, group 11)
#   cd $HOME\dba\bt; Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\run_bt.ps1 -Phase deploy   (A3: npm install, .env, npm start with auto-setup, plain-SQL route, DB checks)
#   .\run_bt.ps1 -Phase app      (A3: the README quick test, validation, headers)
#   .\run_bt.ps1 -Phase a4       (A4: app role tests over HTTP + documented DB-role plan applied to a copy)
#   .\run_bt.ps1 -Phase a56      (A5 maintenance and A6 backup/restore/recovery; stops the app)
param([ValidateSet('deploy','app','a4','a56')][string]$Phase = 'deploy', [string]$DB = 'boardtrack_db', [string]$G = 'BT', [string]$Zip = '')

$BASE = "$HOME\dba\bt"; $ROOT = "$BASE\BoardTrack-main"; $URL = 'http://localhost:3000'
$E = "$HOME\dba\evidence\g$G"; New-Item -ItemType Directory -Force $BASE, $E, "$HOME\dba\backups" | Out-Null
$sec = Read-Host "postgres password" -AsSecureString
$PGA = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
$env:PGPASSWORD = $PGA
$PLAIN = 'boardtrack_plain'; $APPPW = 'BtApp2026test'; $DEMOPW = 'ChangeMe123!'

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
function StartApp {
    if (PortPid 3000) { "app already listening on port 3000"; return }
    Remove-Item "$BASE\app_out.txt", "$BASE\app_err.txt" -ErrorAction SilentlyContinue
    Start-Process cmd -ArgumentList '/c', 'npm start' -WorkingDirectory $ROOT -RedirectStandardOutput "$BASE\app_out.txt" -RedirectStandardError "$BASE\app_err.txt" -WindowStyle Hidden
    for ($i = 0; $i -lt 30 -and -not (PortPid 3000); $i++) { Start-Sleep 1 }
    "app start: " + $(if (PortPid 3000) { 'listening on port 3000' } else { 'NOT listening' })
}
function StopApp { $p = PortPid 3000; if ($p) { Stop-Process -Id $p -Force -ErrorAction SilentlyContinue; "stopped app (pid $p)" } }
# one HTTP call with a cookie jar; prints status and the page message
function Http($method, $path, $jar, [string[]]$fields = @(), $who = '') {
    $a = @('-s', '-m', '30', '-b', $jar, '-c', $jar, '-X', $method, '-w', '|||%{http_code}|||%{redirect_url}')
    foreach ($f in $fields) { $a += @('--data-urlencode', $f) }
    $a += "$URL$path"
    $r = (& curl.exe @a 2>&1 | Out-String)
    $parts = $r -split '\|\|\|'
    $body = $parts[0]; $code = $parts[1]; $loc = ($parts[2]).Trim()
    $msg = ''
    $m = [regex]::Match($body, '<div class="msg (err|ok)">(.*?)</div>', 'Singleline')
    if ($m.Success) { $msg = '[' + $m.Groups[1].Value + '] ' + [Net.WebUtility]::HtmlDecode($m.Groups[2].Value.Trim()) }
    else { $m2 = [regex]::Match($body, '<h1>Oops</h1><p>(.*?)</p>'); if ($m2.Success) { $msg = '[page] ' + [Net.WebUtility]::HtmlDecode($m2.Groups[1].Value) } }
    $rows = ([regex]::Matches($body, '<tr>')).Count; if ($rows -gt 0) { $rows = $rows - 1 }
    $line = "$method $path"; if ($who) { $line += "   as $who" }
    $line += "  ->  HTTP $code"; if ($loc) { $line += "  redirect $($loc -replace [regex]::Escape($URL), '')" }; if ($rows -gt 0) { $line += "  rows=$rows" }; if ($msg) { $line += "  $msg" }
    $line
}
function Login($user, $pw = $DEMOPW) {
    $jar = "$BASE\jar_$user.txt"; Remove-Item $jar -ErrorAction SilentlyContinue
    Http POST '/login' $jar @("username=$user", "password=$pw") $user | Out-Null
    $jar
}

if ($Phase -eq 'deploy') {
    & {
        "run at $(Get-Date)"
        if (-not (Test-Path $ROOT)) {
            if (-not $Zip) { $z = Get-ChildItem "$HOME\Downloads","$HOME\Desktop","$HOME\Documents" -Filter '*BoardTrack*.zip' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1; if ($z) { $Zip = $z.FullName } }
            if (-not $Zip) { throw "zip not found, rerun with -Zip <path to BoardTrack-main.zip>" }
            "extracting $Zip to $BASE"; Expand-Archive $Zip $BASE -Force
        }
        "--- prerequisites"
        "node: $(Run node -v)"; "npm: $(cmd /c "npm -v 2>&1")"; Run psql --version
        "--- npm install"
        Push-Location $ROOT; cmd /c "npm install 2>&1" | Select-Object -Last 8; Pop-Location
        "--- .env from .env.example (README step), DATABASE_URL points at the tester's postgres account"
        $u = [uri]::EscapeDataString($PGA)
        $secret = -join ((48..57) + (97..122) | Get-Random -Count 32 | ForEach-Object { [char]$_ })
        "DATABASE_URL=postgresql://postgres:$u@localhost:5432/$DB`r`nPORT=3000`r`nSESSION_SECRET=$secret`r`nAUTO_CREATE_DB=true`r`nAUTO_SETUP=true`r`nAUTO_SEED=true" | Out-File "$ROOT\.env" -Encoding ascii
        "--- first npm start (creates the database, tables and sample data automatically)"
        StartApp
        "--- start-up output"; Get-Content "$BASE\app_out.txt" -ErrorAction SilentlyContinue; Get-Content "$BASE\app_err.txt" -ErrorAction SilentlyContinue | Select-Object -First 20
        "--- second setup run must change nothing (npm run db:setup)"
        Push-Location $ROOT; cmd /c "npm run db:setup 2>&1" | Select-Object -Last 8; Pop-Location
        "--- other documented route: plain SQL on an empty database"
        Run psql -U postgres -h localhost -d postgres -c "DROP DATABASE IF EXISTS $PLAIN"
        Run createdb -U postgres -h localhost $PLAIN
        Run psql -U postgres -h localhost -d $PLAIN -v ON_ERROR_STOP=0 -q -f "$ROOT\db\boardtrack_full_setup.sql" | Select-Object -First 15
        Q "select (select count(*) from pg_tables where schemaname='public') as tables_auto" $DB
        Q "select (select count(*) from pg_tables where schemaname='public') as tables_plain" $PLAIN
        "=== database verification ($DB)"
        Q "select tablename from pg_tables where schemaname='public' order by 1"
        Q "select contype, count(*) from pg_constraint where connamespace='public'::regnamespace group by 1 order by 1"
        Q "select conname, pg_get_constraintdef(oid) from pg_constraint where contype='x'"
        Q "select tgname, tgrelid::regclass as tbl from pg_trigger where not tgisinternal order by 1"
        Q "select viewname from pg_views where schemaname='public'"
        Q "select extname, extversion from pg_extension order by 1"
        Q "select indexname, tablename from pg_indexes where schemaname='public' order by 2,1"
        Q "select table_name, (xpath('/row/c/text()', query_to_xml(format('select count(*) as c from public.%I', table_name), false, true, '')))[1]::text::int as row_count from information_schema.tables where table_schema='public' and table_type='BASE TABLE' order by 1"
        Q "select username, role, tenant_id, is_active, left(password_hash,7) as hash_prefix from app_user order by user_id"
        "=== which database account does the app use?"
        Q "select usename, application_name, state, count(*) from pg_stat_activity where datname='$DB' group by 1,2,3"
        Q "select rolname, rolsuper, rolcreatedb, rolcreaterole from pg_roles where rolname = 'postgres' or rolname ~ '^(boardtrack|app_)'"
        Q "select datname, datacl from pg_database where datname='$DB'"
    } | Save "a3_deploy.txt"
    "The app is running at $URL. Leave it running."
}

if ($Phase -eq 'app') {
    & {
        "run at $(Get-Date)"
        StartApp
        $L = Login 'landlord'
        "=== pages as landlord"
        foreach ($p in '/', '/properties', '/rooms', '/tenants', '/leases', '/payments', '/bills') { Http GET $p $L @() 'landlord' }
        "=== README quick test"
        $maria = Scalar "select tenant_id from tenant where full_name='Maria Santos'"
        $r101 = Scalar "select r.room_id from room r join property p using(property_id) where p.property_name like 'Sunshine%' and r.room_number='101'"
        $r103 = Scalar "select r.room_id from room r join property p using(property_id) where p.property_name like 'Sunshine%' and r.room_number='103'"
        "ids: Maria tenant_id=$maria, room 101=$r101, room 103=$r103"
        "1. overlapping ACTIVE lease on room 101 (must be rejected)"
        Http POST '/leases' $L @("tenant_id=$maria","room_id=$r101",'start_date=2026-06-01','end_date=2026-12-31','monthly_rent=3500','status=ACTIVE') 'landlord'
        "2. lease on room 103 (accepted, room becomes OCCUPIED)"
        Http POST '/leases' $L @("tenant_id=$maria","room_id=$r103",'start_date=2026-11-10','end_date=2027-05-10','monthly_rent=4000','status=ACTIVE') 'landlord'
        $lid = Scalar "select max(lease_id) from lease where room_id=$r103"
        Q "select room_number, status from room where room_id=$r103"
        "3. terminate that lease (room returns to AVAILABLE)"
        Http POST "/leases/$lid" $L @("tenant_id=$maria","room_id=$r103",'start_date=2026-11-10','end_date=2027-05-10','monthly_rent=4000','status=TERMINATED') 'landlord'
        Q "select room_number, status from room where room_id=$r103"
        "   manual room status that contradicts the leases (room 101 has an ACTIVE lease, set AVAILABLE)"
        Http POST "/rooms/$r101" $L @('property_id=1','room_number=101','monthly_rate=3500','status=AVAILABLE') 'landlord'
        "4. add a payment, total paid must change"
        $act = Scalar "select lease_id from lease where status='ACTIVE' order by lease_id limit 1"
        Q "select lease_id, total_paid from v_lease_summary where lease_id=$act"
        Http POST '/payments' $L @("lease_id=$act",'payment_date=2026-11-06','amount=1000','payment_method=GCASH','status=COMPLETED') 'landlord'
        Q "select lease_id, total_paid from v_lease_summary where lease_id=$act"
        "5. delete a lease that has payments (blocked by the foreign key)"
        Http POST "/leases/$act/delete" $L @() 'landlord'
        "6. delete the unused test lease (allowed)"
        Http POST "/leases/$lid/delete" $L @() 'landlord'
        "=== validation"
        Http POST '/leases' $L @("tenant_id=$maria","room_id=$r103",'start_date=2026-12-01','end_date=2026-11-01','monthly_rent=4000','status=ACTIVE') 'landlord'
        Http POST '/leases' $L @("tenant_id=$maria","room_id=$r103",'start_date=2026-11-10','end_date=2027-05-10','monthly_rent=-5','status=ACTIVE') 'landlord'
        Http POST '/leases' $L @("tenant_id=$maria","room_id=$r103",'start_date=notadate','end_date=2027-05-10','monthly_rent=4000','status=ACTIVE') 'landlord'
        Http POST '/payments' $L @("lease_id=$act",'payment_date=2026-11-06','amount=0','payment_method=CASH','status=COMPLETED') 'landlord'
        Http POST '/tenants' $L @('full_name=Dup Tester','contact_number=0917','email=maria@example.com') 'landlord'
        Http GET '/rooms/abc/edit' $L @() 'landlord'
        Http GET '/rooms/999999/edit' $L @() 'landlord'
        Http GET '/leases' "$BASE\nojar.txt" @() '(not logged in)'
        Http POST '/login' "$BASE\nojar.txt" @('username=landlord', 'password=wrong') '(wrong password)'
        Http POST '/login' "$BASE\nojar.txt" @("username=landlord' OR '1'='1", 'password=x') '(injection attempt)'
        "=== response headers and cookie (login page)"
        & curl.exe -s -I "$URL/login" 2>&1
        "--- Set-Cookie after login"
        & curl.exe -s -i -X POST --data-urlencode "username=landlord" --data-urlencode "password=$DEMOPW" "$URL/login" 2>&1 | Select-String 'Set-Cookie'
        "--- CSRF token in the forms?"
        $c = (Select-String -Path "$ROOT\src\views\*.ejs", "$ROOT\src\*.js" -Pattern 'csrf|csurf' -SimpleMatch -ErrorAction SilentlyContinue | Measure-Object).Count
        "matches for csrf in views and server code: $c"
        "--- helmet or rate limiting?"
        "dependencies: $((Get-Content "$ROOT\package.json" -Raw | ConvertFrom-Json).dependencies.PSObject.Properties.Name -join ', ')"
        "=== database after the tests"
        Q "select (select count(*) from lease) leases, (select count(*) from payment) payments, (select count(*) from room where status='OCCUPIED') occupied_rooms"
        "=== app log"
        Get-Content "$BASE\app_out.txt" -Tail 15 -ErrorAction SilentlyContinue
        Get-Content "$BASE\app_err.txt" -Tail 25 -ErrorAction SilentlyContinue
    } | Save "a3_app.txt"
    "The app keeps running at $URL for the screenshots."
}

if ($Phase -eq 'a4') {
    & {
        "run at $(Get-Date)"
        StartApp
        "=== PART A: the application's own roles, tested over HTTP (permission table in src/auth.js)"
        $L = Login 'landlord'; $C = Login 'caretaker'; $T = Login 'juan'
        "--- landlord (admin): full create/update/delete on properties"
        Http GET '/properties/new' $L @() 'landlord'
        Http POST '/properties' $L @('property_name=ZZ Test House', 'address=1 Test St') 'landlord'
        $pid1 = Scalar "select max(property_id) from property where property_name='ZZ Test House'"
        Http POST "/properties/$pid1" $L @('property_name=ZZ Test House 2', 'address=2 Test St') 'landlord'
        Http POST "/properties/$pid1/delete" $L @() 'landlord'
        "--- caretaker (staff): create/read/update, no delete, properties read-only, rooms update-only"
        foreach ($p in '/properties', '/rooms', '/tenants', '/leases', '/payments', '/bills') { Http GET $p $C @() 'caretaker' }
        Http GET '/properties/new' $C @() 'caretaker'
        Http POST '/properties' $C @('property_name=ZZ Staff House', 'address=x') 'caretaker'
        Http POST '/properties/1' $C @('property_name=Hacked', 'address=x') 'caretaker'
        Http POST '/properties/1/delete' $C @() 'caretaker'
        Http GET '/rooms/new' $C @() 'caretaker'
        Http POST '/rooms/1/delete' $C @() 'caretaker'
        Http GET '/tenants/new' $C @() 'caretaker'
        Http POST '/tenants/1/delete' $C @() 'caretaker'
        Http POST '/leases/1/delete' $C @() 'caretaker'
        Http POST '/payments/1/delete' $C @() 'caretaker'
        "--- juan (tenant, tenant_id 1): read-only, own rows only"
        foreach ($p in '/', '/properties', '/rooms', '/tenants', '/leases', '/payments', '/bills') { Http GET $p $T @() 'juan' }
        Q "select (select count(*) from lease) all_leases, (select count(*) from lease where tenant_id=1) juan_leases, (select count(*) from payment) all_payments, (select count(*) from payment p join lease l using(lease_id) where l.tenant_id=1) juan_payments, (select count(*) from utility_bill) all_bills, (select count(*) from utility_bill b join lease l using(lease_id) where l.tenant_id=1) juan_bills"
        Http GET '/leases/new' $T @() 'juan'
        Http POST '/leases' $T @('tenant_id=1', 'room_id=3', 'start_date=2026-11-10', 'end_date=2027-05-10', 'monthly_rent=1', 'status=ACTIVE') 'juan'
        Http GET '/leases/2/edit' $T @() 'juan (another tenant lease)'
        Http POST '/leases/2/delete' $T @() 'juan'
        Http POST '/payments' $T @('lease_id=1', 'payment_date=2026-11-06', 'amount=1', 'payment_method=CASH', 'status=COMPLETED') 'juan'
        "--- not logged in"
        Http GET '/leases' "$BASE\nojar.txt" @() '(not logged in)'
        Http POST '/leases/1/delete' "$BASE\nojar.txt" @() '(not logged in)'
        "=== PART B: database level"
        "The repository has no role script. docs/user-roles.md says roles are planned for Activity 4. Roles in this cluster that match the plan:"
        Q "select rolname from pg_roles where rolname ~ '^(boardtrack|app_)' order by 1"
        "The app connects with the account in DATABASE_URL (the tester used postgres):"
        Q "select usename, rolsuper from pg_stat_activity a join pg_roles r on r.rolname=a.usename where datname='$DB' group by 1,2"
        Q "select datname, datacl from pg_database where datname='$DB'"
        Q "select tablename, tableowner from pg_tables where schemaname='public' order by 1"
        "=== PART C: the sketch from docs/user-roles.md applied to a COPY ($PLAIN, built from db/boardtrack_full_setup.sql)"
        Q @"
DO `$`$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='app_runtime_grp') THEN CREATE ROLE app_runtime_grp NOLOGIN; END IF;
 IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='app_readonly_grp') THEN CREATE ROLE app_readonly_grp NOLOGIN; END IF;
 IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='boardtrack_admin_grp') THEN CREATE ROLE boardtrack_admin_grp NOLOGIN; END IF;
 IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='boardtrack_app') THEN CREATE ROLE boardtrack_app LOGIN PASSWORD '$APPPW' IN ROLE app_runtime_grp; END IF;
END `$`$
"@ $PLAIN
        Q "GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_readonly_grp" $PLAIN
        Q "GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO app_runtime_grp" $PLAIN
        Q "GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO app_runtime_grp" $PLAIN
        $cols = foreach ($r in @(@('boardtrack_app','app'), @('app_readonly_grp','readonly'), @('boardtrack_admin_grp','admin_grp'))) {
            $parts = foreach ($pv in 'SELECT','INSERT','UPDATE','DELETE') { "case when has_table_privilege('$($r[0])',format('public.%I',tablename),'$pv') then '$($pv.Substring(0,1))' else '-' end" }
            "concat($($parts -join ',')) as $($r[1])"
        }
        "--- privilege matrix after the sketch (S I U D)"
        Q "select tablename, $($cols -join ', ') from pg_tables where schemaname='public' order by 1" $PLAIN
        "--- behaviour tests (real login as boardtrack_app; NOLOGIN groups through SET ROLE)"
        $t = @(
          @('boardtrack_app', 'login query reads app_user and hashes', "select username, left(password_hash,7) from app_user limit 1"),
          @('boardtrack_app', 'login check with crypt()', "select count(*) from app_user where username='landlord' and password_hash = crypt('$DEMOPW', password_hash)"),
          @('boardtrack_app', 'lease update fires the room trigger (rolled back)', "BEGIN; update lease set status='TERMINATED' where lease_id=1; select room_id, status from room where room_id=1; ROLLBACK"),
          @('boardtrack_app', 'DELETE lease (the app admin delete button needs it)', "delete from lease where false"),
          @('boardtrack_app', 'DELETE payment', "delete from payment where false"),
          @('boardtrack_app', 'UPDATE app_user (role escalation)', "update app_user set role='admin' where false"),
          @('boardtrack_app', 'CREATE TABLE', "create table public.zz(x int)"),
          @('boardtrack_app', 'DROP TABLE lease', "drop table lease"),
          @('boardtrack_app', 'CREATE ROLE', "create role zz_test")
        )
        foreach ($x in $t) { "### [$($x[0])] $($x[1])"; QL $x[2] $x[0] $APPPW $PLAIN }
        "### [app_readonly_grp] read the password hashes"
        Q "select username, left(password_hash,7) from app_user limit 1" $PLAIN app_readonly_grp
        "### [app_readonly_grp] insert"
        Q "insert into property(property_name,address) values ('zz','zz')" $PLAIN app_readonly_grp
        "### [boardtrack_admin_grp] read a business table (no grants in the sketch)"
        Q "select count(*) from lease" $PLAIN boardtrack_admin_grp
        "### the planned boardtrack_owner role from the plan table"
        Q "select count(*) as boardtrack_owner_exists from pg_roles where rolname='boardtrack_owner'" $PLAIN
        "### database connect for the sketch roles"
        Q "select datname, has_database_privilege('boardtrack_app', datname, 'CONNECT') as app_can_connect from pg_database where not datistemplate order by 1" $PLAIN
    } | Save "a4_access_tests.txt"
}

if ($Phase -eq 'a56') {
    $RES = "${DB}_restore"; $REC = "${DB}_recovery"
    $F = "$HOME\dba\backups\${DB}_activity6.dump"
    $cnt = "select table_name, (xpath('/row/c/text()', query_to_xml(format('select count(*) as c from public.%I', table_name), false, true, '')))[1]::text::int as row_count from information_schema.tables where table_schema='public' and table_type='BASE TABLE' order by 1"
    & {
        "run at $(Get-Date)"
        Q "select version()" postgres
        Q "select pg_size_pretty(pg_database_size('$DB')) as db_size"
        Q "select datname,numbackends,xact_commit,xact_rollback,blks_read,blks_hit,deadlocks,temp_files from pg_stat_database where datname='$DB'"
        Q "select pid,usename,application_name,state,left(query,60) as query from pg_stat_activity where datname='$DB'"
        Q "select relname,n_live_tup,n_dead_tup,last_vacuum,last_autovacuum,last_analyze,last_autoanalyze from pg_stat_user_tables order by relname"
        Q $cnt
        Q "show log_statement" postgres; Q "show log_min_duration_statement" postgres; Q "show max_connections" postgres; Q "show autovacuum" postgres
        "--- can a non-owner role run maintenance? (boardtrack_app from the Activity 4 copy)"
        QL "VACUUM public.lease" 'boardtrack_app' $APPPW $PLAIN
    } | Save "a5_health.txt"
    & {
        $dd = (Run psql -U postgres -h localhost -d postgres -At -c "show data_directory" | Out-String).Trim()
        $ld = (Run psql -U postgres -h localhost -d postgres -At -c "show log_directory" | Out-String).Trim()
        "data_directory=$dd"; "log_directory=$ld"
        $dir = if ([IO.Path]::IsPathRooted($ld)) { $ld } else { Join-Path $dd $ld }
        try {
            foreach ($f in (Get-ChildItem $dir -File -ErrorAction Stop | Sort-Object LastWriteTime -Descending | Select-Object -First 2)) {
                "== $($f.FullName) ($($f.Length) bytes, $($f.LastWriteTime))"
                Select-String -Path $f.FullName -Pattern "FATAL|ERROR|denied|failed" | Select-Object -Last 45 | ForEach-Object { $_.Line }
            }
        } catch { "Could not read the log folder: $($_.Exception.Message)" }
        "== app log (Node)"
        Get-Content "$BASE\app_out.txt" -ErrorAction SilentlyContinue | Select-Object -Last 20
        Get-Content "$BASE\app_err.txt" -ErrorAction SilentlyContinue | Select-Object -Last 30
    } | Save "a5_logs.txt"
    & {
        $q = "select lease_id, tenant, property_name, room_number, status, total_paid, utilities_billed from v_lease_summary where tenant_id = 1 order by 1"
        Q "select relname,n_live_tup,n_dead_tup,last_vacuum,last_analyze from pg_stat_user_tables order by relname"
        Q "ANALYZE"
        Q "VACUUM (VERBOSE, ANALYZE) public.lease"
        Q "select relname,n_live_tup,n_dead_tup,last_vacuum,last_analyze from pg_stat_user_tables order by relname"
        Q "EXPLAIN $q"
        Q "EXPLAIN (ANALYZE, BUFFERS) $q"
        Q "select indexname, tablename from pg_indexes where schemaname='public' order by 2,1"
        Q "select pg_get_viewdef('v_lease_summary'::regclass) as view_definition"
    } | Save "a5_maintenance.txt"
    & {
        "run at $(Get-Date)"
        "no dedicated backup role exists in the project, so the dump is taken as postgres"
        Run pg_dump -U postgres -h localhost -Fc -d $DB -f $F
        "pg_dump exit code: $LASTEXITCODE"
        (Get-Item $F | Select-Object Name, Length, LastWriteTime | Format-List | Out-String).Trim()
        (Get-FileHash $F -Algorithm SHA256 | Format-List | Out-String).Trim()
        "--- pg_restore --list (first 70 lines)"
        Run pg_restore --list $F | Select-Object -First 70
        "TABLE DATA entries in archive: $((Run pg_restore --list $F | Select-String 'TABLE DATA').Count)"
    } | Save "a6_backup.txt"
    & {
        foreach ($d in @($RES, $REC)) { Run psql -U postgres -h localhost -d postgres -c "DROP DATABASE IF EXISTS $d" }
        Run createdb -U postgres -h localhost $RES
        $sw = [Diagnostics.Stopwatch]::StartNew()
        $m = Run pg_restore -U postgres -h localhost -d $RES $F
        $ec = $LASTEXITCODE; $sw.Stop()
        "pg_restore exit code: $ec ; elapsed seconds: $([math]::Round($sw.Elapsed.TotalSeconds, 2))"
        if ($m) { "messages:"; $m } else { "no messages (no warnings or errors)" }
    } | Save "a6_restore.txt"
    & {
        foreach ($d in @($DB, $RES)) {
            "################ $d"
            Q "select (select count(*) from pg_tables where schemaname='public') tables,(select count(*) from pg_views where schemaname='public') views,(select count(*) from pg_sequences where schemaname='public') sequences" $d
            Q $cnt $d
            Q "select contype,count(*) from pg_constraint where connamespace='public'::regnamespace group by contype order by contype" $d
            Q "select count(*) as table_grants from information_schema.role_table_grants where table_schema='public'" $d
            Q "select tgname from pg_trigger where not tgisinternal order by 1" $d
            Q "select extname from pg_extension order by 1" $d
            "--- business rule 2 still enforced (duplicate of an ACTIVE lease, rolled back)"
            Q "BEGIN; INSERT INTO lease(tenant_id,room_id,start_date,end_date,monthly_rent,status) SELECT tenant_id, room_id, start_date, end_date, monthly_rent, 'ACTIVE' FROM lease WHERE status='ACTIVE' LIMIT 1; ROLLBACK" $d
            "--- room status guard still enforced"
            Q "update room set status='AVAILABLE' where room_id = (select room_id from lease where status='ACTIVE' order by lease_id limit 1)" $d
            "--- demo login still works from the restored data"
            Q "select count(*) as landlord_login_ok from app_user where username='landlord' and password_hash = crypt('$DEMOPW', password_hash)" $d
        }
    } | Save "a6_verify.txt"
    & {
        Q "select datname,datacl from pg_database where datname like '$DB%' order by 1" postgres
        Q "select rolname from pg_roles where rolname ~ '^(boardtrack|app_)' order by 1"
        "--- roles are cluster-wide, so they are not in the dump; the restored copy has no grants for them unless the roles exist and the dump carried the privileges"
        Q "select count(*) as table_grants_for_sketch_roles from information_schema.role_table_grants where grantee ~ '^(boardtrack|app_)' and table_schema='public'" $DB
        Q "select count(*) as table_grants_for_sketch_roles from information_schema.role_table_grants where grantee ~ '^(boardtrack|app_)' and table_schema='public'" $RES
    } | Save "a6_access.txt"
    & {
        $tbl = $null
        foreach ($c in 'payment','lease','tenant','utility_bill') {
            $n = (Run psql -U postgres -h localhost -d $RES -At -c "select count(*) from public.$c" | Out-String).Trim()
            if ($n -match '^\d+$' -and [int]$n -gt 0) { $tbl = $c; break }
        }
        if (-not $tbl) { "No table has rows, simulation skipped."; return }
        "target table: $tbl"
        $sum = "select count(*) as rows, md5(string_agg(t::text, '' order by t::text)) as table_checksum from public.$tbl t"
        "== BEFORE";       Q $sum $RES postgres
        "== INCIDENT: delete one row"; Q "delete from public.$tbl where ctid = (select min(ctid) from public.$tbl)" $RES postgres
        "== AFTER LOSS";   Q $sum $RES postgres
        "== RECOVERY: restore the same dump into $REC"
        Run createdb -U postgres -h localhost $REC
        $m = Run pg_restore -U postgres -h localhost -d $REC $F
        "pg_restore exit code: $LASTEXITCODE"; if ($m) { $m }
        "== RECOVERED";    Q $sum $REC postgres
        "== ORIGINAL DATABASE UNTOUCHED"; Q $sum $DB postgres
    } | Save "a6_recovery.txt"
    StopApp | Out-Null
    "App stopped. Test databases $RES, $REC and $PLAIN were left for screenshots. Drop them later: dropdb -U postgres -h localhost <name>"
}

Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
""
"DONE ($Phase). Evidence in $E"
Get-ChildItem $E | Select-Object Name, Length | Format-Table | Out-String
