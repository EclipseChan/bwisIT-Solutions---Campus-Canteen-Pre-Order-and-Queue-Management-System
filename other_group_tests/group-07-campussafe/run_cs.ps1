# run_cs.ps1 - Activities 3 to 6 for CampusSafe (PHP + PostgreSQL, group 7), tested by G08
#   Put grp07-campussafe-main1.zip in $HOME\dba\cs, then:
#   cd $HOME\dba\cs; Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\run_cs.ps1 -Phase deploy   (A3: setup steps, database checks, seed, web checks, role gating)
#   .\run_cs.ps1 -Phase a4       (A4: roles script as shipped, privilege matrix, real logins, app as campussafe_app)
#   .\run_cs.ps1 -Phase a56      (A5 maintenance, A6 backup/restore/recovery; stops the app)
param([ValidateSet('deploy','a4','a56')][string]$Phase = 'deploy', [string]$DB = 'grp07_campussafedb')

$BASE = "$HOME\dba\cs"; $SRC = "$BASE\grp07-campussafe-main"; $URL = 'http://localhost:8000'
$E = "$HOME\dba\evidence\gCS"; New-Item -ItemType Directory -Force $BASE, $E, "$HOME\dba\backups" | Out-Null
$sec = Read-Host "postgres password" -AsSecureString
$PGA = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
$env:PGPASSWORD = $PGA
$APPU = 'campussafe_app'; $APPPW = 'change_me_locally'; $DEMO = 'Password123!'

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
function PhpExe { $c = Get-Command php -ErrorAction SilentlyContinue; if ($c) { $c.Source } elseif (Test-Path 'C:\xampp\php\php.exe') { 'C:\xampp\php\php.exe' } else { $null } }

# write .env the way the README says (copy .env.example, edit DB_*), then start php -S on public\
function SetConn($user, $pw) {
    StopApp | Out-Null
    $lines = Get-Content "$SRC\.env.example"
    $out = @()
    foreach ($l in $lines) {
        if ($l -match '^DB_USER=') { $out += "DB_USER=$user" }
        elseif ($l -match '^DB_PASSWORD=') { $out += "DB_PASSWORD=$pw" }
        elseif ($l -match '^DB_NAME=') { $out += "DB_NAME=$DB" }
        else { $out += $l }
    }
    $out | Set-Content "$SRC\.env" -Encoding ASCII
    $php = PhpExe
    Start-Process -FilePath $php -ArgumentList '-S', 'localhost:8000', '-t', "$SRC\public" -WorkingDirectory $SRC -WindowStyle Hidden `
        -RedirectStandardError "$BASE\php_err.log" -RedirectStandardOutput "$BASE\php_out.log"
    Start-Sleep 3
    "app started with DB_USER=$user"
}

# web helper: returns an object with Code, Location, Body. No redirect following, so redirects are visible.
function W($method, $path, $sess, $form = $null) {
    $r = [ordered]@{ Code = 0; Location = ''; Body = '' }
    try {
        $req = [System.Net.HttpWebRequest]::Create("$URL$path")
        $req.Method = $method; $req.AllowAutoRedirect = $false; $req.CookieContainer = $sess.Cookies; $req.Timeout = 30000
        if ($form) {
            $pairs = @(); foreach ($k in $form.Keys) { $pairs += ([uri]::EscapeDataString("$k") + '=' + [uri]::EscapeDataString("$($form[$k])")) }
            $bytes = [Text.Encoding]::UTF8.GetBytes(($pairs -join '&'))
            $req.ContentType = 'application/x-www-form-urlencoded'; $req.ContentLength = $bytes.Length
            $st = $req.GetRequestStream(); $st.Write($bytes, 0, $bytes.Length); $st.Close()
        }
        try { $resp = $req.GetResponse() } catch [System.Net.WebException] { $resp = $_.Exception.Response; if (-not $resp) { throw } }
        $r.Code = [int]$resp.StatusCode; $r.Location = "$($resp.Headers['Location'])"
        $sr = New-Object IO.StreamReader($resp.GetResponseStream()); $r.Body = $sr.ReadToEnd(); $sr.Close(); $resp.Close()
    } catch { $r.Body = $_.Exception.Message }
    [pscustomobject]$r
}
function Token($sess, $path) {
    $g = W 'GET' $path $sess
    $m = [regex]::Match($g.Body, 'name="csrf_token" value="([^"]+)"')
    if ($m.Success) { $m.Groups[1].Value } else { '' }
}
function Login($user, $pw) {
    $s = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $t = Token $s '/login.php'
    $f = @{ username = $user; password = $pw; csrf_token = $t }
    $r = W 'POST' '/login.php' $s $f
    "login $user -> HTTP $($r.Code) Location '$($r.Location)'" | Out-Host
    $s
}
function Show($label, $r) { "{0,-62} HTTP {1} {2}" -f $label, $r.Code, $r.Location }
function Msg($r) { $m = [regex]::Match($r.Body, 'class="alert[^>]*>\s*(.*?)\s*</div>', 'Singleline'); if ($m.Success) { ($m.Groups[1].Value -replace '<[^>]+>', ' ' -replace '\s+', ' ').Trim() } else { '' } }

$pages = @('/index.php', '/reports/list.php', '/reports/new.php', '/admin/index.php', '/admin/verify.php', '/admin/assign.php', '/admin/users.php', '/admin/categories.php', '/admin/locations.php', '/admin/stats.php', '/maintenance/index.php', '/maintenance/assigned.php')

# =========================================================================== DEPLOY (Activity 3)
if ($Phase -eq 'deploy') {
    & {
        "=== Activity 3: deploy CampusSafe, tested by G08, $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        if (-not (Test-Path $SRC)) {
            $zip = Get-ChildItem $BASE -Filter '*.zip' | Select-Object -First 1
            if (-not $zip) { "NO ZIP in $BASE"; return }
            Expand-Archive $zip.FullName $BASE -Force
        }
        "--- versions"; Run psql --version; $php = PhpExe; "php: $php"; if ($php) { Run $php -v | Select-Object -First 1; Run $php -m | Where-Object { $_ -match 'pdo|pgsql|fileinfo|session' } }
        "--- shipped files"; Get-ChildItem $SRC | Select-Object Name | Format-Table -HideTableHeaders | Out-String
        "--- .env.example"; Get-Content "$SRC\.env.example" | Where-Object { $_ -match '^DB_|^DEMO' }

        "=== database setup (README manual steps, as postgres)"
        Run psql -U postgres -h localhost -d postgres -c "DROP DATABASE IF EXISTS $DB"
        Run psql -U postgres -h localhost -d postgres -c "CREATE DATABASE $DB"
        foreach ($f in '01_schema.sql', '02_seed.sql') {
            "--- $f"; Run psql -U postgres -h localhost -d $DB -v ON_ERROR_STOP=0 -f "$SRC\database\$f" | Select-Object -Last 8
        }
        "--- schema run a second time (repeatability)"; Run psql -U postgres -h localhost -d $DB -f "$SRC\database\01_schema.sql" | Select-String 'ERROR' | Select-Object -First 3
        "--- 02_seed.sql second run"; Run psql -U postgres -h localhost -d $DB -f "$SRC\database\02_seed.sql" | Select-String 'ERROR' | Select-Object -First 3

        "=== app: .env then seed_users.php"
        SetConn 'postgres' $PGA
        Push-Location $SRC
        Run $php database\seed_users.php | Select-Object -First 14
        Run $php database\seed_users.php | Select-Object -First 3
        Pop-Location
        Q "select u.username, r.role_name, u.account_status, length(u.password_hash) hashlen, left(u.password_hash,4) prefix from app_user u join role r using(role_id) order by 1"

        "=== database checks"
        Q "select table_name from information_schema.tables where table_schema='public' order by 1"
        Q "select contype, count(*) from pg_constraint c join pg_namespace n on n.oid=c.connamespace where n.nspname='public' group by 1 order by 1"
        Q "select count(*) indexes from pg_indexes where schemaname='public'"
        Q "select count(*) triggers from pg_trigger where not tgisinternal"
        Q "select (select count(*) from hazard_report) reports, (select count(*) from hazard_category) cats, (select count(*) from campus_location) locs, (select count(*) from attachment) att"
        Q "select tableowner, count(*) from pg_tables where schemaname='public' group by 1"
        "--- verify.sql shipped with the project"; Run psql -U postgres -h localhost -d $DB -f "$SRC\database\verify.sql" | Select-Object -First 40

        "=== web checks"
        "--- anonymous access to protected pages"
        $anon = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        foreach ($p in $pages) { Show "anonymous GET $p" (W 'GET' $p $anon) }
        $r = W 'GET' '/login.php' $anon; "login page HTTP $($r.Code); csrf field present: $($r.Body -match 'csrf_token')"
        $r = W 'GET' '/install.php' $anon; "install.php reachable without login after setup: HTTP $($r.Code) (title: $([regex]::Match($r.Body,'<title>(.*?)</title>').Groups[1].Value))"
        "--- login tests"
        $s = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        $t = Token $s '/login.php'
        foreach ($c in @(@('demo_admin', 'wrong'), @('nobody', $DEMO), @('', ''), @("' OR '1'='1", 'x'))) {
            $r = W 'POST' '/login.php' $s @{ username = $c[0]; password = $c[1]; csrf_token = $t }; "login '$($c[0])' / '$($c[1])' -> HTTP $($r.Code) $($r.Location) msg: $(Msg $r)"
        }
        $r = W 'POST' '/login.php' $s @{ username = 'demo_admin'; password = $DEMO }; "login without csrf token -> HTTP $($r.Code) $($r.Location) msg: $(Msg $r)"
        "--- role gating: each account against every page (Code 200 = allowed, 302/403 = blocked)"
        foreach ($u in 'demo_admin', 'demo_maint1', 'demo_student', 'demo_faculty', 'demo_auditor') {
            $s = Login $u $DEMO
            foreach ($p in $pages) { Show "$u GET $p" (W 'GET' $p $s) }
        }
        "--- submit a hazard report as student"
        $s = Login 'demo_student' $DEMO
        $t = Token $s '/reports/new.php'
        $cat = Scalar "select min(category_id) from hazard_category where is_active"; $loc = Scalar "select min(location_id) from campus_location where is_active"
        $r = W 'POST' '/reports/new.php' $s @{ category_id = $cat; location_id = $loc; description = 'G08 test: wet floor near stairs'; csrf_token = $t }; Show 'valid report' $r; "msg: $(Msg $r)"
        $r = W 'POST' '/reports/new.php' $s @{ category_id = $cat; location_id = $loc; description = ''; csrf_token = $t }; Show 'empty description' $r; "msg: $(Msg $r)"
        $r = W 'POST' '/reports/new.php' $s @{ category_id = '9999'; location_id = $loc; description = 'bad category'; csrf_token = $t }; Show 'category 9999' $r; "msg: $(Msg $r)"
        $r = W 'POST' '/reports/new.php' $s @{ category_id = $cat; location_id = $loc; description = "<script>alert(1)</script> '; DROP TABLE hazard_report;--"; csrf_token = $t }; Show 'script and SQL text in description' $r
        $r = W 'POST' '/reports/new.php' $s @{ category_id = $cat; location_id = $loc; description = 'no token' }; Show 'report without csrf token' $r; "msg: $(Msg $r)"
        Q "select report_id, status, priority, left(description,40) d, reporter_user_id from hazard_report order by report_id desc limit 4"
        Q "select count(*) from report_status_history"
        "--- admin workflow: verify then assign then technician resolves"
        $a = Login 'demo_admin' $DEMO
        $rid = Scalar "select max(report_id) from hazard_report where status='Submitted'"
        $t = Token $a "/admin/verify.php?id=$rid"
        $r = W 'POST' '/admin/verify.php' $a @{ report_id = $rid; priority = 'High'; notes = 'G08 verify'; csrf_token = $t }; Show "verify report $rid" $r; "msg: $(Msg $r)"
        $r = W 'POST' '/admin/verify.php' $a @{ report_id = $rid; priority = 'Urgent'; notes = 'bad priority'; csrf_token = $t }; Show 'priority Urgent' $r; "msg: $(Msg $r)"
        $mt = Scalar "select user_id from app_user where username='demo_maint1'"
        $t = Token $a "/admin/assign.php?id=$rid"
        $r = W 'POST' '/admin/assign.php' $a @{ report_id = $rid; maintenance_user_id = $mt; notes = 'G08 assign'; csrf_token = $t }; Show "assign report $rid" $r; "msg: $(Msg $r)"
        $m = Login 'demo_maint1' $DEMO
        $t = Token $m "/maintenance/update.php?id=$rid"
        $r = W 'POST' "/maintenance/update.php?id=$rid" $m @{ action_details = 'G08 started'; csrf_token = $t }; Show 'technician: in progress' $r; "msg: $(Msg $r)"
        $r = W 'POST' "/maintenance/update.php?id=$rid" $m @{ action_details = 'G08 fixed'; is_resolution = '1'; csrf_token = $t }; Show 'technician: resolved' $r; "msg: $(Msg $r)"
        Q "select report_id, status, priority, resolved_at is not null resolved from hazard_report where report_id=$rid"
        Q "select * from report_status_history where report_id=$rid order by 1"
        "--- headers and cookie"
        $x = Invoke-WebRequest "$URL/login.php" -UseBasicParsing -SessionVariable ws
        $x.Headers.Keys | ForEach-Object { "$_ : $($x.Headers[$_])" }
        "--- direct database rules"
        Q "update hazard_report set status='Banana' where report_id=$rid"
        Q "update hazard_report set status='Resolved', resolved_at=null where report_id=$rid"
        Q "insert into hazard_report(reporter_user_id,location_id,category_id,description,priority) values (1,1,1,'x','Urgent')"
        Q "select count(*) from hazard_report"
        "--- php log"; if (Test-Path "$BASE\php_err.log") { Get-Content "$BASE\php_err.log" | Where-Object { $_ -match 'Warning|Notice|Fatal|Deprecated' } | Select-Object -First 10 }
        "app left running at $URL for screenshots (login demo_admin / $DEMO)"
    } *>&1 | Save 'a3_deploy.txt'
    return
}

# =========================================================================== A4
if ($Phase -eq 'a4') {
    & {
        "=== Activity 4: roles and privileges, tested by G08, $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        "--- roles script 03_roles_and_privileges.sql, run as shipped, first run"
        Run psql -U postgres -h localhost -d $DB -f "$SRC\database\03_roles_and_privileges.sql" | Select-Object -Last 25
        "--- second run (repeatability)"
        Run psql -U postgres -h localhost -d $DB -f "$SRC\database\03_roles_and_privileges.sql" | Select-String 'ERROR|already' | Select-Object -First 5
        Q "select rolname, rolcanlogin, rolsuper, rolcreatedb, rolcreaterole, rolreplication from pg_roles where rolname like 'campussafe%' or rolname like 'app\_%' order by 1"
        Q "select r.rolname role, m.rolname member from pg_auth_members a join pg_roles r on r.oid=a.roleid join pg_roles m on m.oid=a.member where r.rolname like 'app\_%'"
        Q "select left(rolpassword,14) pw from pg_authid where rolname='campussafe_app'"
        "--- privilege matrix (S I U D T)"
        foreach ($g in 'app_runtime_grp', 'app_readonly_grp', 'app_backup_grp') {
            Q "select '$g' grp, t.tablename, case when has_table_privilege('$g', t.tablename, 'SELECT') then 'S' else '-' end || case when has_table_privilege('$g', t.tablename, 'INSERT') then 'I' else '-' end || case when has_table_privilege('$g', t.tablename, 'UPDATE') then 'U' else '-' end || case when has_table_privilege('$g', t.tablename, 'DELETE') then 'D' else '-' end || case when has_table_privilege('$g', t.tablename, 'TRUNCATE') then 'T' else '-' end priv from pg_tables t where t.schemaname='public' order by 2"
        }
        Q "select has_schema_privilege('app_runtime_grp','public','USAGE') usage, has_schema_privilege('app_runtime_grp','public','CREATE') create_, has_database_privilege('app_runtime_grp','$DB','CONNECT') connect_, has_database_privilege('public','$DB','CONNECT') public_connect"
        Q "select datacl from pg_database where datname='$DB'"
        "--- real logins"
        $users = @(@('campussafe_app', $APPPW), @('campussafe_report', $APPPW), @('campussafe_backup', $APPPW))
        foreach ($u in $users) {
            $n = $u[0]; $p = $u[1]
            "##### $n"
            QL "select count(*) from hazard_report" $n $p
            QL "select count(*) from app_user" $n $p
            QL "select username, left(password_hash,7) from app_user limit 1" $n $p
            QL "insert into hazard_category(category_name) values ('A4 test $n')" $n $p
            QL "update app_user set role_id=1 where username='demo_student'" $n $p
            QL "delete from hazard_report where report_id=1" $n $p
            QL "delete from attachment where attachment_id=-1" $n $p
            QL "truncate hazard_report" $n $p
            QL "create table a4_t(i int)" $n $p
            QL "create role a4_x" $n $p
            QL "select count(*) from pg_authid" $n $p
            QL "vacuum hazard_report" $n $p
            QL "select 1" $n $p 'postgres'
        }
        "--- app as campussafe_app (least privilege)"
        SetConn $APPU $APPPW
        $s = Login 'demo_student' $DEMO
        $t = Token $s '/reports/new.php'
        $cat = Scalar "select min(category_id) from hazard_category where is_active"; $loc = Scalar "select min(location_id) from campus_location where is_active"
        $r = W 'POST' '/reports/new.php' $s @{ category_id = $cat; location_id = $loc; description = 'G08 A4: report as campussafe_app'; csrf_token = $t }; Show 'student submits report' $r; "msg: $(Msg $r)"
        $a = Login 'demo_admin' $DEMO
        foreach ($p in '/admin/index.php', '/admin/verify.php', '/admin/users.php', '/admin/stats.php') { Show "admin GET $p" (W 'GET' $p $a) }
        $rid = Scalar "select max(report_id) from hazard_report where status='Submitted'"
        $t = Token $a "/admin/verify.php?id=$rid"
        $r = W 'POST' '/admin/verify.php' $a @{ report_id = $rid; priority = 'Medium'; notes = 'A4 verify'; csrf_token = $t }; Show 'admin verifies' $r; "msg: $(Msg $r)"
        $t = Token $a '/admin/users.php'
        $r = W 'POST' '/admin/users.php' $a @{ action = 'create'; full_name = 'A4 Tester'; email = 'a4@x.test'; username = 'a4_user'; role_id = '2'; password = 'Passw0rd!x'; csrf_token = $t }; Show 'admin creates a user' $r; "msg: $(Msg $r)"
        $t = Token $a '/admin/categories.php'
        $r = W 'POST' '/admin/categories.php' $a @{ action = 'create'; category_name = 'A4 Category'; description = 'a4'; is_active = '1'; csrf_token = $t }; Show 'admin adds a category' $r; "msg: $(Msg $r)"
        Q "select report_id, status, priority from hazard_report order by report_id desc limit 3"
        Q "select username from app_user where username='a4_user'"
        "--- application roles against pages (see also a3_deploy.txt)"
        foreach ($u in 'demo_student', 'demo_faculty', 'demo_auditor', 'demo_maint1') {
            $s = Login $u $DEMO
            foreach ($p in '/admin/users.php', '/admin/verify.php', '/admin/stats.php', '/maintenance/index.php') { Show "$u GET $p" (W 'GET' $p $s) }
        }
        "--- other checks"
        "6 wrong passwords then correct:"
        $s = New-Object Microsoft.PowerShell.Commands.WebRequestSession
        $t = Token $s '/login.php'
        1..6 | ForEach-Object { $r = W 'POST' '/login.php' $s @{ username = 'demo_admin'; password = "bad$_"; csrf_token = $t }; "attempt $_ -> HTTP $($r.Code) $(Msg $r)" }
        $r = W 'POST' '/login.php' $s @{ username = 'demo_admin'; password = $DEMO; csrf_token = $t }; "correct password -> HTTP $($r.Code) $($r.Location)"
        "forged post without token as student (Origin evil):"
        $s = Login 'demo_student' $DEMO
        $r = W 'POST' '/reports/new.php' $s @{ category_id = $cat; location_id = $loc; description = 'forged no token' }; Show 'post without csrf token' $r; "msg: $(Msg $r)"
        "logout then reuse session:"
        $r = W 'GET' '/logout.php' $s; Show 'logout' $r
        Show 'GET /reports/list.php after logout' (W 'GET' '/reports/list.php' $s)
        "--- hashes and config"
        Q "select left(password_hash,4) p, count(*) from app_user group by 1"
        "default password in .env.example: DEMO_PASSWORD=Password123!; DB_PASSWORD=change_me_locally"
        Select-String -Path "$SRC\.gitignore" -Pattern '\.env' | Select-Object -First 3
        "--- pg_hba rules"; $hba = Scalar "show hba_file" 'postgres'; Get-Content $hba | Where-Object { $_ -match '^(host|local)' }
    } *>&1 | Save 'a4_access.txt'
    return
}

# =========================================================================== A5 + A6
if ($Phase -eq 'a56') {
    $DUMP = "$HOME\dba\backups\${DB}_activity6.dump"
    & {
        "=== Activity 5: maintenance and monitoring, tested by G08, $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        Q "select version()" 'postgres'
        Q "select pg_size_pretty(pg_database_size('$DB')) size"
        Q "select datname,numbackends,xact_commit,xact_rollback,blks_read,blks_hit,deadlocks,temp_files from pg_stat_database where datname='$DB'"
        Q "select name, setting from pg_settings where name in ('autovacuum','log_statement','log_min_duration_statement','max_connections','logging_collector','log_directory') order by 1" 'postgres'
        Q "select relname, n_live_tup live, n_dead_tup dead, last_autovacuum, last_autoanalyze from pg_stat_user_tables order by 1"
        Q "select relname, pg_size_pretty(pg_total_relation_size(relid)) total from pg_stat_user_tables order by pg_total_relation_size(relid) desc"
        Q "select relname, indexrelname, idx_scan from pg_stat_user_indexes order by idx_scan, 1"
        Q "select c.conrelid::regclass tbl, a.attname col from pg_constraint c join pg_attribute a on a.attrelid=c.conrelid and a.attnum=any(c.conkey) where c.contype='f' and not exists (select 1 from pg_index i where i.indrelid=c.conrelid and a.attnum = i.indkey[0]) order by 1"
        "--- server log (this database, last entries)"
        $ld = Scalar "select setting from pg_settings where name='data_directory'" 'postgres'
        $lf = Get-ChildItem "$ld\log" -Filter *.log -ErrorAction SilentlyContinue | Sort-Object LastWriteTime | Select-Object -Last 1
        if ($lf) { Get-Content $lf.FullName | Select-String -Pattern 'campussafe|grp07|hazard|app_user|assignment|attachment' | Select-Object -Last 40 | ForEach-Object { $_.Line } } else { "log folder not readable" }
        "--- maintenance_commands.sql from the project (db-maintenance is for other groups; this project's own commands are in the repo docs)"
        "--- manual maintenance as postgres"
        Q "analyze"
        Run psql -U postgres -h localhost -d $DB -c "vacuum (verbose, analyze) hazard_report" | Select-Object -Last 12
        Run psql -U postgres -h localhost -d $DB -c "vacuum (verbose, analyze) report_status_history" | Select-Object -Last 8
        Q "select relname, n_dead_tup dead, last_vacuum, last_analyze from pg_stat_user_tables order by 1"
        "--- as campussafe_app"
        QL "vacuum hazard_report" $APPU $APPPW
        QL "analyze hazard_report" $APPU $APPPW
        "--- query plans for the pages' queries"
        Q "explain (analyze, buffers) select r.report_id, r.status, r.priority, c.category_name, l.building from hazard_report r join hazard_category c using(category_id) join campus_location l using(location_id) order by r.submitted_at desc"
        Q "explain (analyze, buffers) select * from hazard_report where status='Submitted' order by submitted_at"
        Q "explain (analyze, buffers) select * from report_status_history where report_id=1 order by changed_at"
        Q "explain (analyze, buffers) select a.*, u.full_name from assignment a join app_user u on u.user_id=a.maintenance_user_id where a.maintenance_user_id=2"
        Q "explain (analyze, buffers) select status, count(*) from hazard_report group by 1"
        Q "select count(*) reports from hazard_report"
    } *>&1 | Save 'a5_maintenance.txt'

    & {
        "=== Activity 6: backup, restore, recovery, tested by G08, $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        Remove-Item $DUMP -ErrorAction SilentlyContinue
        $sw = [Diagnostics.Stopwatch]::StartNew()
        Run pg_dump -U postgres -h localhost -Fc -d $DB -f $DUMP; "pg_dump exit $LASTEXITCODE in $($sw.Elapsed.TotalSeconds) s"
        $fi = Get-Item $DUMP; "file $($fi.Name) bytes $($fi.Length)"; "sha256 $((Get-FileHash $DUMP -Algorithm SHA256).Hash)"
        "--- archive contents"; Run pg_restore -l $DUMP | Select-Object -First 12; "TOC entries: $((Run pg_restore -l $DUMP | Where-Object { $_ -notmatch '^;' }).Count)"
        "ACL entries: $((Run pg_restore -l $DUMP | Where-Object { $_ -match ' ACL ' }).Count)"
        "--- backup role: campussafe_backup login runs pg_dump"
        $env:PGPASSWORD = $APPPW; Run pg_dump -U campussafe_backup -h localhost -Fc -d $DB -f "$HOME\dba\backups\${DB}_backuprole.dump"; "exit $LASTEXITCODE size $((Get-Item "$HOME\dba\backups\${DB}_backuprole.dump" -ErrorAction SilentlyContinue).Length)"; $env:PGPASSWORD = $PGA
        "=== restore into $DB`_restore"
        Run psql -U postgres -h localhost -d postgres -c "DROP DATABASE IF EXISTS ${DB}_restore"
        Run psql -U postgres -h localhost -d postgres -c "CREATE DATABASE ${DB}_restore"
        $sw.Restart(); Run pg_restore -U postgres -h localhost -d "${DB}_restore" $DUMP; "pg_restore exit $LASTEXITCODE in $($sw.Elapsed.TotalSeconds) s"
        "=== compare original and restored"
        foreach ($d in $DB, "${DB}_restore") {
            "##### $d"
            Q "select (select count(*) from pg_tables where schemaname='public') tables, (select count(*) from pg_indexes where schemaname='public') indexes, (select count(*) from pg_sequences) sequences" $d
            Q "select (select count(*) from role) role, (select count(*) from app_user) users, (select count(*) from hazard_category) cats, (select count(*) from campus_location) locs, (select count(*) from hazard_report) reports, (select count(*) from assignment) assignments, (select count(*) from report_status_history) history, (select count(*) from maintenance_action) actions, (select count(*) from attachment) attachments" $d
            Q "select contype, count(*) from pg_constraint c join pg_namespace n on n.oid=c.connamespace where n.nspname='public' group by 1 order by 1" $d
            Q "select md5(string_agg(h::text, '|' order by report_id)) reports_md5 from hazard_report h" $d
            Q "select md5(string_agg(h::text, '|' order by 1)) history_md5 from report_status_history h" $d
            Q "select md5(string_agg(h::text, '|' order by user_id)) users_md5 from app_user h" $d
            Q "select sequencename, last_value from pg_sequences order by 1" $d
            Q "select grantee, count(*) from information_schema.role_table_grants where table_schema='public' and grantee like 'app%' group by 1 order by 1" $d
            Q "select datacl from pg_database where datname='$d'" 'postgres'
        }
        Q "insert into hazard_report(reporter_user_id,location_id,category_id,description,priority) values (1,1,1,'x','Urgent')" "${DB}_restore"
        "--- application against the restored copy as campussafe_app"
        SetConn 'postgres' $PGA | Out-Null
        $txt = (Get-Content "$SRC\.env" -Raw) -replace "DB_NAME=$DB", "DB_NAME=${DB}_restore" -replace 'DB_USER=postgres', "DB_USER=$APPU" -replace "DB_PASSWORD=$([regex]::Escape($PGA))", "DB_PASSWORD=$APPPW"
        StopApp | Out-Null; $txt | Set-Content "$SRC\.env" -Encoding ASCII
        Start-Process -FilePath (PhpExe) -ArgumentList '-S', 'localhost:8000', '-t', "$SRC\public" -WorkingDirectory $SRC -WindowStyle Hidden; Start-Sleep 3
        $a = Login 'demo_admin' $DEMO
        foreach ($p in '/admin/index.php', '/reports/list.php', '/admin/stats.php') { Show "restored copy, admin GET $p" (W 'GET' $p $a) }
        QL "select count(*) from hazard_report" $APPU $APPPW "${DB}_restore"
        QL "truncate hazard_report" $APPU $APPPW "${DB}_restore"
        StopApp
        "=== recovery simulation (incident in the restored copy, then restore again)"
        Q "select count(*), md5(string_agg(h::text, '|' order by report_id)) from hazard_report h" "${DB}_restore"
        Q "update hazard_report set status='Closed', resolved_at=now()" "${DB}_restore"
        Q "delete from report_status_history" "${DB}_restore"
        Q "select (select count(*) from hazard_report where status='Closed') closed, (select count(*) from report_status_history) history" "${DB}_restore"
        Run psql -U postgres -h localhost -d postgres -c "DROP DATABASE IF EXISTS ${DB}_recovery"
        Run psql -U postgres -h localhost -d postgres -c "CREATE DATABASE ${DB}_recovery"
        Run pg_restore -U postgres -h localhost -d "${DB}_recovery" $DUMP; "recovery restore exit $LASTEXITCODE"
        Q "select count(*), md5(string_agg(h::text, '|' order by report_id)) from hazard_report h" "${DB}_recovery"
        Q "select count(*) history from report_status_history" "${DB}_recovery"
        Q "select count(*), md5(string_agg(h::text, '|' order by report_id)) from hazard_report h" $DB
        "--- uploaded files (not in the dump)"
        "attachment rows: $(Scalar 'select count(*) from attachment')"; "files in uploads: $((Get-ChildItem "$SRC\uploads" -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count)"
        Copy-Item $DUMP "$E\" -ErrorAction SilentlyContinue
        "=== cleanup (databases and roles created by this test)"
        "DROP DATABASE grp07_campussafedb, grp07_campussafedb_restore, grp07_campussafedb_recovery; DROP ROLE campussafe_app, campussafe_report, campussafe_backup, app_runtime_grp, app_readonly_grp, app_backup_grp;"
    } *>&1 | Save 'a6_backup_restore.txt'
    return
}
