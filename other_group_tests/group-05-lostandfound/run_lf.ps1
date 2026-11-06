# run_lf.ps1 - Activities 3 to 6 for PUP-SPOT Lost and Found (PHP + PostgreSQL, group 5)
#   cd $HOME\dba\lf; Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\run_lf.ps1 -Phase deploy   (A3: extract zip, create DB, run the documented SQL, write .env)
#   .\run_lf.ps1 -Phase app      (A3: start both PHP servers, API smoke tests, role-use proof)
#   .\run_lf.ps1 -Phase a4       (A4: roles and privileges)
#   .\run_lf.ps1 -Phase a56      (A5 maintenance and A6 backup/restore/recovery)
param([ValidateSet('deploy','app','a4','a56')][string]$Phase = 'deploy', [string]$DB = 'grp05_lostandfounddb', [string]$G = 'LF', [string]$Zip = '')

$BASE = "$HOME\dba\lf"; $ROOT = "$BASE\grp05_lostandfound-main"
$E = "$HOME\dba\evidence\g$G"; New-Item -ItemType Directory -Force $BASE, $E, "$HOME\dba\backups" | Out-Null
$sec = Read-Host "postgres password" -AsSecureString
$PGA = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
$env:PGPASSWORD = $PGA
$APPPW = 'LfApp2026test'; $PUBPW = 'LfPub2026test'     # test passwords for this test copy only

function Run { & $args[0] @($args | Select-Object -Skip 1) 2>&1 | ForEach-Object { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_.Exception.Message } else { "$_" } } }
function Q($sql, $db = $DB, $role = $null) {
    if ($role) { $env:PGOPTIONS = "-c role=$role" } else { Remove-Item Env:PGOPTIONS -ErrorAction SilentlyContinue }
    $tag = if ($role) { "$role" } else { "postgres" }
    "--- [$tag@$db] $sql"
    Run psql -U postgres -h localhost -d $db -c $sql
    Remove-Item Env:PGOPTIONS -ErrorAction SilentlyContinue
    ""
}
function QL($sql, $user, $pw, $db = $DB) {   # real login as the application role
    $env:PGPASSWORD = $pw
    "--- [login $user@$db] $sql"
    Run psql -U $user -h localhost -d $db -c $sql
    $env:PGPASSWORD = $PGA
    ""
}
function Api($method, $url, $json = $null) {
    $a = @('-s', '-m', '30', '-X', $method, '-w', "`n[HTTP %{http_code}]")
    if ($json) { $tmp = "$BASE\body.json"; [IO.File]::WriteAllText($tmp, $json); $a += @('-H', 'Content-Type: application/json', '--data-binary', "@$tmp") }
    $a += $url
    $r = (& curl.exe @a 2>&1 | Out-String).Trim()
    "$method $url"
    if ($json) { "  body: $json" }
    if ($r.Length -gt 700) { $r = $r.Substring(0, 700) + ' ...(truncated)' }
    "  -> $r"; ""
}
function Save($name) { $l = @($input); $l | Out-File -FilePath "$E\$name" -Encoding utf8; $l }

if ($Phase -eq 'deploy') {
    & {
        "run at $(Get-Date)"
        if (-not (Test-Path $ROOT)) {
            if (-not $Zip) { $z = Get-ChildItem "$HOME\Downloads","$HOME\Desktop","$HOME\Documents" -Filter '*lostandfound*.zip' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1; if ($z) { $Zip = $z.FullName } }
            if (-not $Zip) { throw "zip not found, rerun with -Zip <path to grp05_lostandfound-main.zip>" }
            "extracting $Zip to $BASE"; Expand-Archive $Zip $BASE -Force
        }
        "--- prerequisites"
        Run psql --version
        Run php -v | Select-Object -First 1
        "php extensions: $((Run php -m | Where-Object { $_ -match '^(pdo_pgsql|pgsql)$' }) -join ', ')"
        Run git --version
        Q "select version()" postgres
        Q "CREATE DATABASE $DB" postgres
        $s = "$ROOT\sql"
        "=== 1 schema script"
        Run psql -U postgres -h localhost -d $DB -f "$s\grp05_lostandfounddb_script.sql"
        "=== 2 necessary data script"
        Run psql -U postgres -h localhost -d $DB -f "$s\grp05_lostandfounddb_necessary_data_script.sql"
        "=== 3 role script (both enter_your_password_here placeholders replaced with test passwords, as the README says)"
        $t = Get-Content "$s\grp05_lostandfounddb_role_creation_sample_script.sql" -Raw
        $rx = [regex]'enter_your_password_here'
        $t = $rx.Replace($t, $APPPW, 1); $t = $rx.Replace($t, $PUBPW, 1)
        $t | Out-File "$BASE\roles_run.sql" -Encoding ascii
        Run psql -U postgres -h localhost -d $DB -f "$BASE\roles_run.sql"
        Remove-Item "$BASE\roles_run.sql"
        "=== 4 demo data script"
        Run psql -U postgres -h localhost -d $DB -f "$s\grp05_lostandfounddb_demo_data_script.sql"
        "=== .env written from .env.example with the database settings"
        "DB_HOST=localhost`r`nDB_PORT=5432`r`nDB_NAME=$DB`r`nDB_USER=lostandfound_app`r`nDB_PASSWORD=$APPPW`r`nDB_PUBLIC_USER=lostandfound_public`r`nDB_PUBLIC_PASSWORD=$PUBPW" | Out-File "$ROOT\.env" -Encoding ascii
        "=== result"
        Q "select tablename from pg_tables where schemaname='public' order by 1"
        Q "select conrelid::regclass as tbl, contype, count(*) from pg_constraint where connamespace='public'::regnamespace group by 1,2 order by 1,2"
        Q "select count(*) as categories from categories"
        Q "select (select count(*) from items) items, (select count(*) from lost_reports) lost_reports, (select count(*) from claims) claims, (select count(*) from potential_matches) matches"
        Q "select rolname, rolcanlogin, rolsuper, rolcreatedb, rolcreaterole, (rolpassword is null) as no_password from pg_authid where rolname like 'lostandfound_%' order by 1"
        Q "select datname, datacl from pg_database where datname='$DB'"
    } | Save "a3_deploy.txt"
}

if ($Phase -eq 'app') {
    & {
        "run at $(Get-Date)"
        Get-Process php -ErrorAction SilentlyContinue | Stop-Process -Force
        foreach ($x in @(@('public', 8000), @('admin', 8001))) {
            Remove-Item "$BASE\php_$($x[0]).log" -ErrorAction SilentlyContinue
            Start-Process php -ArgumentList '-S', "127.0.0.1:$($x[1])", '-t', $x[0] -WorkingDirectory $ROOT -RedirectStandardError "$BASE\php_$($x[0]).log" -RedirectStandardOutput "$BASE\php_$($x[0])_out.log" -WindowStyle Hidden
        }
        Start-Sleep 4
        $P = 'http://127.0.0.1:8000'; $A = 'http://127.0.0.1:8001'
        "=== static pages"
        foreach ($u in "$P/app.html", "$A/app.html") { $c = (& curl.exe -s -o NUL -w '%{http_code}' $u); "$u -> HTTP $c" }
        "=== public API"
        Api GET "$P/api/public/categories"
        Api GET "$P/api/public/items"
        Api GET "$P/api/public/items/search?title=umbrella"
        $rep = '{"category_id":9,"title":"TEST black umbrella","description":"Folding umbrella with a wooden handle, left during the cross-group test","location_lost":"Library","date_lost":"2026-11-05","time_lost":"10:00","full_name":"Test Tester","student_number":"2023-00001-TG-0","email":"tester@example.com","phone_number":null,"contact_preference":"email"}'
        Api POST "$P/api/public/lost-reports/add" $rep
        $code = (Run psql -U postgres -h localhost -d $DB -At -c "select report_code from lost_reports where title='TEST black umbrella' order by report_id desc limit 1" | Out-String).Trim()
        "report_code created: $code"
        if ($code) {
            Api POST "$P/api/public/lost-reports/view" "{`"report_code`":`"$code`"}"
            Api GET "$P/api/public/lost-reports/matches/$code"
        }
        $item = (Run psql -U postgres -h localhost -d $DB -At -c "select item_id from items where status='unclaimed' order by item_id limit 1" | Out-String).Trim()
        "unclaimed item used for the claim: $item"
        Api POST "$P/api/public/claims/add" "{`"item_id`":$item,`"full_name`":`"Test Tester`",`"student_number`":`"2023-00001-TG-0`",`"email`":`"tester@example.com`",`"phone_number`":null,`"contact_preference`":`"email`"}"
        $cc = (Run psql -U postgres -h localhost -d $DB -At -c "select claim_code from claims where full_name='Test Tester' order by claim_id desc limit 1" | Out-String).Trim()
        "claim_code created: $cc"
        if ($cc) { Api POST "$P/api/public/claims/view" "{`"claim_code`":`"$cc`"}" }
        "=== validation and error handling"
        Api POST "$P/api/public/lost-reports/add" '{"title":"incomplete"}'
        Api POST "$P/api/public/lost-reports/view" '{"report_code":"NOPE-0000"}'
        Api POST "$P/api/public/lost-reports/view" '{}'
        Api GET "$P/api/admin/items"
        "=== admin API"
        Api GET "$A/api/admin/test"
        Api GET "$A/api/admin/items"
        Api GET "$A/api/admin/lost-reports"
        Api GET "$A/api/admin/claims"
        $cid = (Run psql -U postgres -h localhost -d $DB -At -c "select claim_id from claims where full_name='Test Tester' order by claim_id desc limit 1" | Out-String).Trim()
        if ($cid) { Api PATCH "$A/api/admin/claims/update/$cid" '{"status":"approved"}' }
        Api POST "$A/api/admin/items/add" '{"category_id":9,"title":"TEST found umbrella","description":"Black folding umbrella","location_found":"Library","date_found":"2026-11-06","time_found":"09:30"}'
        Api GET "$A/api/admin/sms/stats"
        "=== which database role does each server really use? (login switched off for one role at a time)"
        Q "ALTER ROLE lostandfound_public NOLOGIN" postgres
        "-- public role disabled: public server then admin server"
        Api GET "$P/api/public/categories"
        Api GET "$A/api/admin/categories"
        Q "ALTER ROLE lostandfound_public LOGIN" postgres
        Q "ALTER ROLE lostandfound_app NOLOGIN" postgres
        "-- app role disabled: public server then admin server"
        Api GET "$P/api/public/categories"
        Api GET "$A/api/admin/categories"
        Q "ALTER ROLE lostandfound_app LOGIN" postgres
        "-- both roles restored"
        Api GET "$P/api/public/categories"
        "=== database state after the tests"
        Q "select (select count(*) from items) items, (select count(*) from lost_reports) lost_reports, (select count(*) from claims) claims, (select count(*) from potential_matches) matches"
        Q "select claim_code, status, full_name from claims order by claim_id desc limit 3"
        Q "select report_code, status, title from lost_reports order by report_id desc limit 3"
        "=== PHP server logs (last lines)"
        "-- public"; Get-Content "$BASE\php_public.log" -Tail 25 -ErrorAction SilentlyContinue
        "-- admin";  Get-Content "$BASE\php_admin.log" -Tail 25 -ErrorAction SilentlyContinue
    } | Save "a3_app.txt"
    "Both servers keep running. Open http://127.0.0.1:8000/app.html and http://127.0.0.1:8001/app.html for the screenshots."
}

if ($Phase -eq 'a4') {
    & {
        "run at $(Get-Date)"
        Q "select rolname, rolcanlogin, rolsuper, rolcreatedb, rolcreaterole, rolinherit, (rolpassword is null) as no_password from pg_authid where rolname like 'lostandfound_%' order by 1"
        Q "select datname, datacl from pg_database where datname='$DB'"
        Q "select tablename, tableowner from pg_tables where schemaname='public' order by 1"
        $cols = foreach ($r in @(@('lostandfound_app','app'), @('lostandfound_public','public_role'))) {
            $parts = foreach ($pv in 'SELECT','INSERT','UPDATE','DELETE') { "case when has_table_privilege('$($r[0])',format('public.%I',tablename),'$pv') then '$($pv.Substring(0,1))' else '-' end" }
            "concat($($parts -join ',')) as $($r[1])"
        }
        "=== privilege matrix, letters S I U D (a dash means not granted)"
        Q "select tablename, $($cols -join ', ') from pg_tables where schemaname='public' order by 1"
        "=== column-level grants for lostandfound_public on lost_reports"
        Q "select column_name, privilege_type from information_schema.column_privileges where table_name='lost_reports' and grantee='lostandfound_public' and privilege_type='UPDATE' order by 1"
        "=== behaviour tests using real logins"
        $pub = @(
            @('SELECT items (allowed)', 'select count(*) from items'),
            @('SELECT lost_reports with personal data (allowed by the grant)', 'select report_code, full_name, student_number, email, phone_number from lost_reports limit 2'),
            @('SELECT claims with personal data (allowed by the grant)', 'select claim_code, full_name, student_number, email, phone_number from claims limit 2'),
            @('INSERT claim (allowed, rolled back)', "BEGIN; INSERT INTO claims(claim_code,item_id,full_name,email) VALUES ('ZZ-TEST',(select min(item_id) from items),'zz','a@b.c') RETURNING claim_id; ROLLBACK"),
            @('UPDATE lost_reports.status (column grant)', "update lost_reports set status='cancelled' where false"),
            @('UPDATE lost_reports.title (expect denied)', "update lost_reports set title='x' where false"),
            @('UPDATE claims.status (expect denied)', "update claims set status='approved' where false"),
            @('INSERT items (expect denied)', "insert into items(title) values ('zz')"),
            @('UPDATE items (expect denied)', "update items set status='claimed' where false"),
            @('DELETE lost_reports (expect denied)', 'delete from lost_reports where false'),
            @('DELETE potential_matches (allowed)', 'delete from potential_matches where false'),
            @('SELECT claim_images (expect denied)', 'select count(*) from claim_images'),
            @('SELECT pg_stat_activity (other sessions hidden)', 'select count(*) as visible, count(query) filter (where query <> ''<insufficient privilege>'') as with_text from pg_stat_activity'),
            @('CREATE TABLE (expect denied)', 'create table public.zz(x int)'),
            @('CREATE ROLE (expect denied)', 'create role zz_test'),
            @('DROP TABLE items (expect denied)', 'drop table items')
        )
        "################ lostandfound_public"
        foreach ($x in $pub) { "### $($x[0])"; QL $x[1] 'lostandfound_public' $PUBPW }
        $app = @(
            @('SELECT claims (allowed)', 'select count(*) from claims'),
            @('UPDATE claims.status (allowed, no row changed)', "update claims set status='approved' where false"),
            @('UPDATE items (allowed)', "update items set status='claimed' where false"),
            @('DELETE items (expect denied)', 'delete from items where false'),
            @('DELETE claims (expect denied)', 'delete from claims where false'),
            @('DELETE lost_reports (expect denied)', 'delete from lost_reports where false'),
            @('DELETE item_images (allowed)', 'delete from item_images where false'),
            @('DELETE potential_matches (allowed)', 'delete from potential_matches where false'),
            @('CREATE TABLE (expect denied)', 'create table public.zz(x int)'),
            @('DROP TABLE items (expect denied)', 'drop table items'),
            @('CREATE ROLE (expect denied)', 'create role zz_test'),
            @('VACUUM (expect denied)', 'vacuum public.items')
        )
        "################ lostandfound_app"
        foreach ($x in $app) { "### $($x[0])"; QL $x[1] 'lostandfound_app' $APPPW }
        "=== can the roles connect elsewhere"
        Q "select datname, has_database_privilege('lostandfound_public', datname, 'CONNECT') as public_role_can_connect, has_database_privilege('lostandfound_app', datname, 'CONNECT') as app_role_can_connect from pg_database where not datistemplate order by 1"
        "=== wrong password is rejected"
        QL 'select 1' 'lostandfound_public' 'wrongpassword'
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
        "--- can an application role run maintenance?"
        QL "VACUUM public.items" 'lostandfound_app' $APPPW
        QL "ANALYZE public.items" 'lostandfound_app' $APPPW
    } | Save "a5_health.txt"
    & {
        $dd = (Run psql -U postgres -h localhost -d postgres -At -c "show data_directory" | Out-String).Trim()
        $ld = (Run psql -U postgres -h localhost -d postgres -At -c "show log_directory" | Out-String).Trim()
        "data_directory=$dd"; "log_directory=$ld"
        $dir = if ([IO.Path]::IsPathRooted($ld)) { $ld } else { Join-Path $dd $ld }
        try {
            foreach ($f in (Get-ChildItem $dir -File -ErrorAction Stop | Sort-Object LastWriteTime -Descending | Select-Object -First 3)) {
                "== $($f.FullName) ($($f.Length) bytes, $($f.LastWriteTime))"
                Select-String -Path $f.FullName -Pattern "FATAL|ERROR|denied|failed" | Select-Object -Last 60 | ForEach-Object { $_.Line }
            }
        } catch { "Could not read the log folder: $($_.Exception.Message)" }
        "== PHP server logs (error and warning lines)"
        foreach ($n in 'public','admin') { "-- $n"; Select-String -Path "$BASE\php_$n.log" -Pattern "Warning|Fatal|Error|Notice|Deprecated| 4\d\d | 5\d\d " -ErrorAction SilentlyContinue | Select-Object -Last 25 | ForEach-Object { $_.Line } }
    } | Save "a5_logs.txt"
    & {
        $q = "select i.item_id, i.title, c.name from items i join categories c using(category_id) where i.status='unclaimed' and i.title ilike '%umbrella%' and i.location_found ilike '%library%'"
        Q "select relname,n_live_tup,n_dead_tup,last_vacuum,last_analyze from pg_stat_user_tables order by relname"
        Q "ANALYZE"
        Q "VACUUM (VERBOSE, ANALYZE) public.potential_matches"
        Q "select relname,n_live_tup,n_dead_tup,last_vacuum,last_analyze from pg_stat_user_tables order by relname"
        Q "EXPLAIN $q"
        Q "EXPLAIN (ANALYZE, BUFFERS) $q"
        Q "select indexname, tablename from pg_indexes where schemaname='public' order by 2,1"
    } | Save "a5_maintenance.txt"
    & {
        "run at $(Get-Date)"
        "no dedicated backup role exists in the project SQL, so the dump is taken as postgres"
        Run pg_dump -U postgres -h localhost -Fc -d $DB -f $F
        "pg_dump exit code: $LASTEXITCODE"
        (Get-Item $F | Select-Object Name, Length, LastWriteTime | Format-List | Out-String).Trim()
        (Get-FileHash $F -Algorithm SHA256 | Format-List | Out-String).Trim()
        "--- pg_restore --list (first 60 lines)"
        Run pg_restore --list $F | Select-Object -First 60
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
            Q "select count(*) from pg_trigger where not tgisinternal" $d
        }
    } | Save "a6_verify.txt"
    & {
        Q "select datname,datacl from pg_database where datname like '$DB%' order by 1" postgres
        "--- re-applying the database-level CONNECT grant on $RES (a database dump does not carry it)"
        Q "GRANT CONNECT ON DATABASE $RES TO lostandfound_public" postgres
        Q "select datname,datacl from pg_database where datname like '$DB%' order by 1" postgres
        QL "select count(*) as items_visible_to_public from items" 'lostandfound_public' $PUBPW $RES
        QL "select count(*) from claims" 'lostandfound_app' $APPPW $RES
    } | Save "a6_access.txt"
    & {
        $tbl = $null
        foreach ($c in 'claims','lost_reports','items','potential_matches') {
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
    Get-Process php -ErrorAction SilentlyContinue | Stop-Process -Force
    "PHP servers stopped. Test databases $RES and $REC were left for screenshots. Drop them later: dropdb -U postgres -h localhost <name>"
}

Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
""
"DONE ($Phase). Evidence in $E"
Get-ChildItem $E | Select-Object Name, Length | Format-Table | Out-String
