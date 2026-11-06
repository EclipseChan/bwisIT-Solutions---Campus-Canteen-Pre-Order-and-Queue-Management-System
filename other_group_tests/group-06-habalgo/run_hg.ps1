# run_hg.ps1 - Activities 3 to 6 for HabalGo (PHP + PostgreSQL, group 6), retest by G08
#   cd $HOME\dba\hg; Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\run_hg.ps1 -Phase deploy   (A3: README steps as written, database checks, first start)
#   .\run_hg.ps1 -Phase app      (A3: API tests; leaves the app running for screenshots)
#   .\run_hg.ps1 -Phase a4       (A4: database\03_roles_and_privileges.sql, role tests, app as the app and readonly users)
#   .\run_hg.ps1 -Phase a56      (A5 maintenance and A6 backup/restore/recovery; stops the app)
param([ValidateSet('deploy','app','a4','a56')][string]$Phase = 'deploy', [string]$DB = 'grp00_habalgodb', [string]$G = 'HG')

$BASE = "$HOME\dba\hg"; $ROOT = "$BASE\HabalGo-main"; $URL = 'http://localhost:8000'
$E = "$HOME\dba\evidence\g$G"; New-Item -ItemType Directory -Force $BASE, $E, "$HOME\dba\backups" | Out-Null
$sec = Read-Host "postgres password" -AsSecureString
$PGA = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
$env:PGPASSWORD = $PGA
# passwords for the two login roles are the ones written in database\03_roles_and_privileges.sql
$APPU = 'habalgo_app_user'; $APPPW = 'HabalGoSecurePass2026!'; $ROU = 'habalgo_readonly_user'; $ROPW = 'HabalGoReadOnly2026!'

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
# start php -S localhost:8000; $useEnv=$false starts it exactly as the README says (no variables, only a .env file that PHP never reads)
function StartApp($useEnv = $true, $user = 'postgres', $pw = $PGA, $db = $DB) {
    StopApp | Out-Null
    foreach ($v in 'DB_HOST','DB_PORT','DB_NAME','DB_USER','DB_PASS','DB_PASSWORD') { Remove-Item "Env:$v" -ErrorAction SilentlyContinue }
    if ($useEnv) { $env:DB_HOST = 'localhost'; $env:DB_PORT = '5432'; $env:DB_NAME = $db; $env:DB_USER = $user; $env:DB_PASS = $pw }
    Remove-Item "$BASE\php_out.txt", "$BASE\php_err.txt" -ErrorAction SilentlyContinue
    Start-Process php -ArgumentList '-S', 'localhost:8000' -WorkingDirectory $ROOT -RedirectStandardOutput "$BASE\php_out.txt" -RedirectStandardError "$BASE\php_err.txt" -WindowStyle Hidden
    for ($i = 0; $i -lt 20 -and -not (PortPid 8000); $i++) { Start-Sleep 1 }
    "php server: " + $(if (PortPid 8000) { 'listening on http://localhost:8000' } else { 'NOT listening' }) + $(if ($useEnv) { "  (DB_NAME=$db DB_USER=$user)" } else { '  (no DB_* variables set, README way)' })
}
function Api($method, $res, $body = $null, $note = '', $extra = '', [string[]]$more = @()) {
    $a = @('-s', '-m', '60', '-X', $method, '-D', "$BASE\hdr.txt", '-o', "$BASE\body.txt", '-w', '%{http_code}')
    if ($body) { [IO.File]::WriteAllText("$BASE\req.json", $body); $a += @('-H', 'Content-Type: application/json', '--data-binary', "@$BASE\req.json") }
    $a += $more; $a += "$URL/api.php?t=$res$extra"
    $script:LastCode = (& curl.exe @a 2>&1 | Out-String).Trim()
    $script:LastBody = (Get-Content "$BASE\body.txt" -Raw -ErrorAction SilentlyContinue); if (-not $script:LastBody) { $script:LastBody = '' }
    $b = $script:LastBody.Trim(); $n = $b.Length; if ($n -gt 130) { $b = $b.Substring(0, 130) + "... ($n chars)" }
    $line = "$method api.php?t=$res$extra"; if ($body) { $line += "  body=$($body.Trim())" }
    $line += "  ->  HTTP $script:LastCode  $b"; if ($note) { $line += "   <$note>" }
    $line
}
function J { try { $script:LastBody | ConvertFrom-Json } catch { $null } }

# data-driven test runner: the test text is a single-quoted here-string, so quotes and braces in it cannot upset the PowerShell parser
#   ==text                      header line
#   M|||METHOD|||resource|||json|||note|||extra-query|||curl args separated by ^
#   Q|||sql                     run SQL as postgres      CAP|||name  keep the id of the last response     SC|||name|||sql  keep a scalar
#   HDR                         print the response headers of the last call     SAY|||text
$script:V = @{ N101 = ('N' * 101); A5000 = ('a' * 5000) }
function Tests($text) {
    foreach ($raw in ($text -split "`r?`n")) {
        $l = $raw.TrimEnd(); if (-not $l) { continue }
        foreach ($k in @($script:V.Keys)) { $l = $l.Replace("@$k@", [string]$script:V[$k]) }
        if ($l.StartsWith('==')) { $l; continue }
        $p = $l -split '\|\|\|'
        switch ($p[0]) {
            'M'   { $more = @(); if ($p.Count -gt 6 -and $p[6]) { $more = $p[6] -split '\^' }
                    $ex = if ($p.Count -gt 5) { $p[5] } else { '' }; $nt = if ($p.Count -gt 4) { $p[4] } else { '' }
                    $body = if ($p.Count -gt 3 -and $p[3]) { $p[3] } else { $null }
                    Api $p[1] $p[2] $body $nt $ex $more }
            'Q'   { Q $p[1] }
            'CAP' { $script:V[$p[1]] = (J).id; "   ($($p[1]) = $($script:V[$p[1]]))" }
            'SC'  { $script:V[$p[1]] = Scalar $p[2]; "   ($($p[1]) = $($script:V[$p[1]]))" }
            'HDR' { Get-Content "$BASE\hdr.txt" }
            'SAY' { $p[1] }
        }
    }
}

if ($Phase -eq 'deploy') {
    & {
        "run at $(Get-Date)"
        if (-not (Test-Path $ROOT)) {
            $z = Get-ChildItem $BASE -Filter '*.zip' | Select-Object -First 1
            if (-not $z) { $z = Get-ChildItem "$HOME\Downloads","$HOME\Desktop","$HOME\Documents" -Filter '*HabalGo*.zip' -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 }
            if (-not $z) { throw "zip not found: put HabalGo-main.zip in $BASE" }
            "extracting $($z.FullName)"; Expand-Archive $z.FullName $BASE -Force
        }
        "--- prerequisites"
        Run psql --version
        Run php -v | Select-Object -First 1
        $ext = @(Run php -m | Where-Object { $_ -match '^(pdo_pgsql|pgsql)$' }) -join ', '
        "php extensions: $ext"
        "--- README Step 3: create the database named in the README, then schema.sql and 'sample data.sql'"
        foreach ($d in @($DB, "${DB}_restore", "${DB}_recovery", "${DB}_alt")) { Run psql -U postgres -h localhost -d postgres -c "DROP DATABASE IF EXISTS $d" | Out-Null }
        Run psql -U postgres -h localhost -d postgres -c "CREATE DATABASE $DB;"
        "--- psql -U postgres -d $DB -f schema.sql"
        Run psql -U postgres -h localhost -d $DB -v ON_ERROR_STOP=1 -f "$ROOT\schema.sql"
        "--- psql -U postgres -d $DB -f `"sample data.sql`""
        Run psql -U postgres -h localhost -d $DB -v ON_ERROR_STOP=1 -f "$ROOT\sample data.sql"
        "--- the database\ folder holds a second copy of the schema and a seed, not mentioned in the README. Same content?"
        $same = (Get-Content "$ROOT\schema.sql" -Raw).Trim() -eq (Get-Content "$ROOT\database\01_schema.sql" -Raw).Trim()
        "schema.sql identical to database\01_schema.sql (ignoring outer blank lines): $same"
        Run psql -U postgres -h localhost -d postgres -c "CREATE DATABASE ${DB}_alt;" | Out-Null
        Run psql -U postgres -h localhost -d "${DB}_alt" -v ON_ERROR_STOP=1 -q -f "$ROOT\database\01_schema.sql" | Out-Null
        Run psql -U postgres -h localhost -d "${DB}_alt" -v ON_ERROR_STOP=1 -q -f "$ROOT\database\02_seed.sql" | Out-Null
        $n1 = Scalar 'select count(*) from habalgo.driver' $DB
        $n2 = Scalar 'select count(*) from habalgo.driver' ($DB + '_alt')
        "driver rows from sample data.sql: $n1 ; from database 02_seed.sql: $n2"
        "--- second run of schema.sql (README does not say it is repeatable; script uses IF NOT EXISTS)"
        Run psql -U postgres -h localhost -d $DB -v ON_ERROR_STOP=1 -q -f "$ROOT\schema.sql" | Select-Object -First 4
        "--- second run of 'sample data.sql' (duplicates?)"
        Run psql -U postgres -h localhost -d $DB -q -f "$ROOT\sample data.sql" | Select-Object -First 4
        Q "select count(*) as drivers, count(distinct license_no) as distinct_licenses from habalgo.driver"
        "--- README Step 2: cp .env.example .env, fill in the credentials"
        Copy-Item "$ROOT\.env.example" "$ROOT\.env" -Force
        "README .env block asks for: DB_HOST DB_PORT DB_NAME=grp00_habalgodb DB_SCHEMA=habalgo DB_USER DB_PASS"
        "repository .env.example actually contains:"
        Get-Content "$ROOT\.env.example" | ForEach-Object { if ($_ -match '^DB_PASSWORD') { 'DB_PASSWORD=(placeholder)' } else { $_ } }
        $gl = @(Select-String -Path ($ROOT + '\config.php') -Pattern 'getenv' | ForEach-Object { $_.Line.Trim() }) -join ' | '
        "config.php reads: $gl"
        $envhits = @(Select-String -Path ($ROOT + '\*.php') -Pattern 'parse_ini|dotenv|file_get_contents').Count
        "PHP files that look like they read a .env file (parse_ini, dotenv, file_get_contents): $envhits"
        "--- README Step 4 Option A exactly as written: php -S localhost:8000 (the .env file above is in place, no variables set)"
        StartApp $false
        "GET /"; (& curl.exe -s -o NUL -w "HTTP %{http_code}" "$URL/index.html")
        ""
        Api GET 'dashboard' $null 'README way: what does the app say?'
        "--- same start with the variable names config.php really reads (DB_NAME, DB_USER, DB_PASS, postgres account)"
        StartApp $true 'postgres' $PGA $DB
        Api GET 'dashboard'
        Api GET 'options'
        "=== database verification ($DB)"
        Q "select table_schema, table_name from information_schema.tables where table_schema not in ('pg_catalog','information_schema') order by 1,2"
        Q "select contype, count(*) from pg_constraint where connamespace='habalgo'::regnamespace group by 1 order by 1"
        Q "select conrelid::regclass as tbl, conname, pg_get_constraintdef(oid) from pg_constraint where connamespace='habalgo'::regnamespace and contype in ('c','f','u') order by 1,2"
        Q "select indexname, tablename from pg_indexes where schemaname='habalgo' order by 2,1"
        Q "select count(*) as triggers from pg_trigger where not tgisinternal"
        Q "select table_name, (xpath('/row/c/text()', query_to_xml(format('select count(*) as c from habalgo.%I', table_name), false, true, '')))[1]::text::int as row_count from information_schema.tables where table_schema='habalgo' and table_type='BASE TABLE' order by 1"
        Q "select usename, application_name, state, count(*) from pg_stat_activity where datname='$DB' group by 1,2,3"
        Q "select datname, datacl from pg_database where datname='$DB'"
        Q "select schemaname, tablename, tableowner from pg_tables where schemaname='habalgo' order by 2"
        Q "select rolname, rolsuper from pg_roles where rolname = 'postgres' or rolname ~ '^(habalgo|app_)' order by 1"
        "=== front end and api.php, source facts"
        $ih = @(Select-String -Path ($ROOT + '\js\app.js') -Pattern 'innerHTML').Count
        "innerHTML uses in js app.js: $ih ; esc() definition:"
        (Select-String -Path "$ROOT\js\app.js" -Pattern '^const esc' | ForEach-Object { $_.Line.Trim() })
        "external resources loaded by index.html:"
        (Select-String -Path "$ROOT\index.html" -Pattern 'https?://' | ForEach-Object { $_.Line.Trim() })
    } | Save "a3_deploy.txt"
    "The PHP server is running at $URL. Leave it running."
}

if ($Phase -eq 'app') {
    & {
        "run at $(Get-Date)"
        StartApp $true 'postgres' $PGA $DB
        Tests (Get-Content "$BASE\tests_app.txt" -Raw)
        "=== php server log (errors and warnings only)"
        Get-Content "$BASE\php_err.txt" -ErrorAction SilentlyContinue | Select-String 'Warning|Notice|Fatal|Deprecated|Error' | Select-Object -First 12 | ForEach-Object { $_.Line }
        $rq = @(Get-Content ($BASE + '\php_err.txt') -ErrorAction SilentlyContinue | Select-String 'Accepted').Count
        "requests logged: $rq"
        "=== database after the tests"
        Q "select (select count(*) from habalgo.customer) customers, (select count(*) from habalgo.booking) bookings, (select count(*) from habalgo.payment) payments, (select count(*) from habalgo.location) locations, (select count(*) from habalgo.rating_feedback) ratings"
        Q "select customer_id, name, phone, email from habalgo.customer order by 1"
        Q "select location_id, address, city from habalgo.location order by 1"
    } | Save "a3_app.txt"
    "The PHP server keeps running at $URL for the screenshots."
}

if ($Phase -eq 'a4') {
    & {
        "run at $(Get-Date)"
        StopApp
        "=== PART A: database\03_roles_and_privileges.sql, run as written (no edits, errors do not stop it)"
        "roles named in the script that already exist on this server before the run (left over from other projects tested on the same server):"
        Q "select rolname from pg_roles where rolname in ('app_runtime_grp','app_readonly_grp','habalgo_app_user','habalgo_readonly_user') order by 1" postgres
        Run psql -U postgres -h localhost -d $DB -f "$ROOT\database\03_roles_and_privileges.sql"
        "--- second run of the script (is it repeatable?)"
        Run psql -U postgres -h localhost -d $DB -f "$ROOT\database\03_roles_and_privileges.sql" | Where-Object { $_ -match 'ERROR' }
        Q "select rolname, rolsuper, rolcreatedb, rolcreaterole, rolinherit, rolcanlogin, left(rolpassword,14) as pw_scheme from pg_authid where rolname ~ '^(habalgo|app_)' order by 1" postgres
        Q "select r.rolname as member, g.rolname as member_of from pg_auth_members m join pg_roles r on r.oid=m.member join pg_roles g on g.oid=m.roleid where r.rolname ~ '^habalgo' order by 1"
        $pv = foreach ($pr in 'SELECT','INSERT','UPDATE','DELETE','TRUNCATE') { "case when has_table_privilege('ROLE',format('habalgo.%I',tablename),'$pr') then '$($pr.Substring(0,1))' else '-' end" }
        $cols = foreach ($r in @(@('habalgo_app_user','app_user'), @('habalgo_readonly_user','readonly_user'))) {
            $parts = foreach ($x in $pv) { $x.Replace('ROLE', $r[0]) }
            "concat($($parts -join ',')) as $($r[1])"
        }
        "--- privilege matrix (S I U D T) for the two login accounts"
        Q "select tablename, $($cols -join ', ') from pg_tables where schemaname='habalgo' order by 1"
        Q "select has_schema_privilege('habalgo_app_user','habalgo','USAGE') schema_usage, has_schema_privilege('habalgo_app_user','habalgo','CREATE') schema_create, has_schema_privilege('habalgo_app_user','public','CREATE') public_create, has_database_privilege('habalgo_app_user','$DB','CONNECT') db_connect, (select bool_and(has_sequence_privilege('habalgo_app_user', format('habalgo.%I',sequencename), 'USAGE')) from pg_sequences where schemaname='habalgo') seq_usage"
        Q "select datname, datacl from pg_database where datname='$DB'"
        "--- do the default privileges reach a table created afterwards? (created and dropped by postgres)"
        Q "create table habalgo.zz_new(x int)"
        Q "select has_table_privilege('app_runtime_grp','habalgo.zz_new','INSERT') runtime_insert, has_table_privilege('app_readonly_grp','habalgo.zz_new','SELECT') readonly_select, has_table_privilege('app_readonly_grp','habalgo.zz_new','INSERT') readonly_insert"
        Q "drop table habalgo.zz_new"
        "=== PART B: real logins"
        $t = @(
          @($APPU, 'read customers', "select count(*) from habalgo.customer"),
          @($APPU, 'insert a customer (rolled back)', "BEGIN; insert into habalgo.customer(name,phone,email) values ('T','1','t@example.com') returning customer_id; ROLLBACK"),
          @($APPU, 'update a payment amount (rolled back)', "BEGIN; update habalgo.payment set amount = amount + 1 where payment_id = (select min(payment_id) from habalgo.payment) returning payment_id; ROLLBACK"),
          @($APPU, 'delete a payment (rolled back)', "BEGIN; delete from habalgo.payment where payment_id = (select min(payment_id) from habalgo.payment) returning payment_id; ROLLBACK"),
          @($APPU, 'delete a rating (rolled back)', "BEGIN; delete from habalgo.rating_feedback returning rating_id; ROLLBACK"),
          @($APPU, 'TRUNCATE booking', "truncate habalgo.booking"),
          @($APPU, 'CREATE TABLE in schema habalgo', "create table habalgo.zz(x int)"),
          @($APPU, 'CREATE TABLE in public', "create table public.zz(x int)"),
          @($APPU, 'DROP TABLE payment', "drop table habalgo.payment"),
          @($APPU, 'ALTER TABLE payment', "alter table habalgo.payment add column zz int"),
          @($APPU, 'CREATE INDEX', "create index zz_i on habalgo.payment(amount)"),
          @($APPU, 'CREATE ROLE', "create role zz_test"),
          @($APPU, 'read password hashes', "select rolname from pg_authid limit 1"),
          @($APPU, 'VACUUM (not owner)', "vacuum habalgo.payment"),
          @($APPU, 'CREATE TEMP TABLE (PUBLIC keeps TEMP on the database)', "create temp table zz_t(x int)"),
          @($ROU, 'read bookings', "select count(*) from habalgo.booking"),
          @($ROU, 'insert a customer', "insert into habalgo.customer(name,phone,email) values ('T','1','t2@example.com')"),
          @($ROU, 'update a payment', "update habalgo.payment set amount=1 where false"),
          @($ROU, 'delete a booking', "delete from habalgo.booking where false"),
          @($ROU, 'use a sequence', "select nextval('habalgo.customer_customer_id_seq')"),
          @($ROU, 'CREATE TABLE', "create table habalgo.zz(x int)")
        )
        foreach ($x in $t) { "### [$($x[0])] $($x[1])"; $pw = if ($x[0] -eq $APPU) { $APPPW } else { $ROPW }; QL $x[2] $x[0] $pw $DB }
        "### can the application account connect to another database?"
        QL "select current_database()" $APPU $APPPW 'postgres'
        "=== PART C: the application running as habalgo_app_user (the account the script is for)"
        StartApp $true $APPU $APPPW $DB
        Q "select usename, application_name, state, count(*) from pg_stat_activity where datname='$DB' group by 1,2,3"
        Tests (Get-Content "$BASE\tests_a4c.txt" -Raw)
        "=== PART D: the application running as habalgo_readonly_user (reads should work, writes should fail)"
        StartApp $true $ROU $ROPW $DB
        Tests (Get-Content "$BASE\tests_a4d.txt" -Raw)
        "php log for the write attempts:"
        Get-Content "$BASE\php_err.txt" -ErrorAction SilentlyContinue | Select-String 'Warning|Fatal|Error' | Select-Object -First 4 | ForEach-Object { $_.Line }
        "=== PART E: no login in the application"
        StartApp $true 'postgres' $PGA $DB
        "who can call the API? every call in Activity 3 and here carried no cookie, token or password"
        "source search for session, login, password_verify, token, Authorization in the PHP and JS files:"
        $m = Select-String -Path "$ROOT\*.php", "$ROOT\js\*.js" -Pattern 'session_start|password_verify|login|Authorization|Bearer|token' -ErrorAction SilentlyContinue
        if ($m) { $m | Select-Object -First 6 | ForEach-Object { "$($_.Filename):$($_.LineNumber): $($_.Line.Trim())" } } else { "no matches" }
        "role mentions in the README and in the application code:"
        (Select-String -Path "$ROOT\README.md" -Pattern 'role|03_roles|least' -ErrorAction SilentlyContinue | Select-Object -First 5 | ForEach-Object { "README.md:$($_.LineNumber): $($_.Line.Trim())" })
        $dc = @(Select-String -Path ($ROOT + '\config.php') -Pattern "'user'" | ForEach-Object { $_.Line.Trim() }) -join ' '
        "defaults in config.php: $dc"
        $pc = @(Select-String -Path ($ROOT + '\database\03_roles_and_privileges.sql') -Pattern 'PASSWORD').Count
        "lines with PASSWORD inside database 03_roles_and_privileges.sql: $pc"
        "=== pg_hba.conf rules"
        Q "select line_number, type, database, user_name, address, auth_method from pg_hba_file_rules order by line_number"
    } | Save "a4_access_tests.txt"
    "The PHP server is running as postgres again."
}

if ($Phase -eq 'a56') {
    $RES = "${DB}_restore"; $REC = "${DB}_recovery"
    $F = "$HOME\dba\backups\${DB}_activity6.dump"
    $cnt = "select table_name, (xpath('/row/c/text()', query_to_xml(format('select count(*) as c from habalgo.%I', table_name), false, true, '')))[1]::text::int as row_count from information_schema.tables where table_schema='habalgo' and table_type='BASE TABLE' order by 1"
    & {
        "run at $(Get-Date)"
        if (PortPid 8000) { Api GET 'dashboard' | Out-Null; Api GET 'bookings' | Out-Null }
        Q "select version()" postgres
        Q "select pg_size_pretty(pg_database_size('$DB')) as db_size"
        Q "select datname,numbackends,xact_commit,xact_rollback,blks_read,blks_hit,deadlocks,temp_files from pg_stat_database where datname='$DB'"
        Q "select pid,usename,application_name,state,left(query,60) as query from pg_stat_activity where datname='$DB'"
        Q "select relname,n_live_tup,n_dead_tup,last_vacuum,last_autovacuum,last_analyze,last_autoanalyze from pg_stat_user_tables order by relname"
        Q "select relname, pg_size_pretty(pg_total_relation_size(relid)) total, pg_size_pretty(pg_indexes_size(relid)) idx from pg_stat_user_tables order by pg_total_relation_size(relid) desc"
        Q $cnt
        Q "select indexrelname, relname, idx_scan from pg_stat_user_indexes order by relname, indexrelname"
        Q "show log_statement" postgres; Q "show log_min_duration_statement" postgres; Q "show max_connections" postgres; Q "show autovacuum" postgres
        "--- can habalgo_app_user run maintenance?"
        QL "VACUUM habalgo.booking" $APPU $APPPW $DB
        QL "ANALYZE habalgo.booking" $APPU $APPPW $DB
    } | Save "a5_health.txt"
    & {
        $dd = (Run psql -U postgres -h localhost -d postgres -At -c "show data_directory" | Out-String).Trim()
        $ld = (Run psql -U postgres -h localhost -d postgres -At -c "show log_directory" | Out-String).Trim()
        "data_directory=$dd"; "log_directory=$ld"
        $dir = if ([IO.Path]::IsPathRooted($ld)) { $ld } else { Join-Path $dd $ld }
        try {
            foreach ($f in (Get-ChildItem $dir -File -ErrorAction Stop | Sort-Object LastWriteTime -Descending | Select-Object -First 2)) {
                "== $($f.FullName) ($($f.Length) bytes, $($f.LastWriteTime))"
                Select-String -Path $f.FullName -Pattern "FATAL|ERROR|denied|failed|timeout" | Select-Object -Last 70 | ForEach-Object { $_.Line }
            }
        } catch { "Could not read the log folder: $($_.Exception.Message)" }
        "== PHP server output (warnings, notices, fatal errors)"
        Get-Content "$BASE\php_err.txt" -ErrorAction SilentlyContinue | Select-String 'Warning|Notice|Fatal|Deprecated|Error' | Select-Object -Last 25 | ForEach-Object { $_.Line }
        $rq2 = @(Get-Content ($BASE + '\php_err.txt') -ErrorAction SilentlyContinue | Select-String 'Accepted').Count
        $sz = (Get-Item ($BASE + '\php_err.txt') -ErrorAction SilentlyContinue).Length
        "requests in the PHP log: $rq2 ; log file size $sz bytes ; the PHP server writes this only to the console (no file of its own)"
    } | Save "a5_logs.txt"
    & {
        $q1 = "select b.booking_id as id, c.name, lp.address, ld.address, d.name, b.booking_status from habalgo.booking b join habalgo.customer c on c.customer_id=b.customer_id join habalgo.location lp on lp.location_id=b.pickup_location_id join habalgo.location ld on ld.location_id=b.dropoff_location_id left join habalgo.driver d on d.driver_id=b.driver_id order by b.booking_id desc"
        $q2 = "select (select count(*) from habalgo.customer)::int, (select count(*) from habalgo.booking where booking_status in ('Pending','Confirmed','In Progress'))::int, (select coalesce(sum(amount),0) from habalgo.payment where status='Paid')::float, (select round(avg(rating),1) from habalgo.rating_feedback)::float"
        $q3 = "select p.payment_id, p.booking_id, c.name, p.amount, p.method, p.status from habalgo.payment p join habalgo.booking b on b.booking_id=p.booking_id join habalgo.customer c on c.customer_id=b.customer_id order by p.payment_id desc"
        $q4 = "select booking_status, count(*) from habalgo.booking group by 1 order by 2 desc"
        Q "select relname,n_live_tup,n_dead_tup,last_vacuum,last_analyze from pg_stat_user_tables order by relname"
        Q "ANALYZE"
        Q "VACUUM (VERBOSE, ANALYZE) habalgo.booking"
        Q "VACUUM (VERBOSE, ANALYZE) habalgo.customer"
        Q "select relname,n_live_tup,n_dead_tup,last_vacuum,last_analyze from pg_stat_user_tables order by relname"
        "--- query 1: the bookings list (api.php BK query)"
        Q "EXPLAIN (ANALYZE, BUFFERS) $q1"
        "--- query 2: dashboard statistics"
        Q "EXPLAIN (ANALYZE, BUFFERS) $q2"
        "--- query 3: the payments list"
        Q "EXPLAIN (ANALYZE, BUFFERS) $q3"
        "--- query 4: bookings by status"
        Q "EXPLAIN (ANALYZE, BUFFERS) $q4"
        "--- the same bookings query with sequential scans disabled (one rolled back transaction)"
        Q "BEGIN; SET LOCAL enable_seqscan = off; EXPLAIN (ANALYZE) $q1; ROLLBACK"
        Q "select indexname, tablename from pg_indexes where schemaname='habalgo' order by 2,1"
        "--- foreign key columns without an index"
        Q "select c.conrelid::regclass as tbl, a.attname as fk_column from pg_constraint c join pg_attribute a on a.attrelid=c.conrelid and a.attnum = any(c.conkey) where c.contype='f' and c.connamespace='habalgo'::regnamespace and not exists (select 1 from pg_index i where i.indrelid=c.conrelid and i.indkey[0]=a.attnum) order by 1,2"
    } | Save "a5_maintenance.txt"
    & {
        "run at $(Get-Date)"
        "no dedicated backup role exists in the project, so the dump is taken as postgres"
        Run pg_dump -U postgres -h localhost -Fc -d $DB -f $F
        "pg_dump exit code: $LASTEXITCODE"
        (Get-Item $F | Select-Object Name, Length, LastWriteTime | Format-List | Out-String).Trim()
        (Get-FileHash $F -Algorithm SHA256 | Format-List | Out-String).Trim()
        "--- pg_restore --list (first 80 lines)"
        Run pg_restore --list $F | Select-Object -First 80
        $td = @(Run pg_restore --list $F | Select-String 'TABLE DATA').Count
        $da = @(Run pg_restore --list $F | Select-String 'DEFAULT ACL').Count
        $ac = @(Run pg_restore --list $F | Select-String ' ACL ').Count
        "TABLE DATA entries in archive: $td ; DEFAULT ACL entries: $da ; ACL entries: $ac"
        "the README does not describe any backup procedure"
        (Select-String -Path "$ROOT\README.md" -Pattern 'backup|pg_dump|restore' -ErrorAction SilentlyContinue | ForEach-Object { $_.Line })
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
            Q "select (select count(*) from pg_tables where schemaname='habalgo') tables,(select count(*) from pg_sequences where schemaname='habalgo') sequences, (select count(*) from pg_indexes where schemaname='habalgo') indexes" $d
            Q $cnt $d
            Q "select contype,count(*) from pg_constraint where connamespace='habalgo'::regnamespace group by contype order by contype" $d
            Q "select grantee, count(*) as table_grants from information_schema.role_table_grants where table_schema='habalgo' group by 1 order by 1" $d
            Q "select md5(string_agg(t::text, '' order by t::text)) as payment_checksum from habalgo.payment t" $d
            Q "select md5(string_agg(t::text, '' order by t::text)) as booking_checksum from habalgo.booking t" $d
            Q "select sequencename, last_value from pg_sequences where schemaname='habalgo' order by 1" $d
            Q "select count(*) as default_acl_entries from pg_default_acl" $d
            "--- constraint still enforced"
            Q "insert into habalgo.payment(booking_id,amount,method,status) select booking_id,0,'x','x' from habalgo.booking limit 1" $d
            Q "insert into habalgo.rating_feedback(booking_id,customer_id,rating) select booking_id,customer_id,9 from habalgo.booking limit 1" $d
        }
        "=== the application against the restored database (as habalgo_app_user)"
        StartApp $true $APPU $APPPW $RES
        Q "select datname, usename, count(*) from pg_stat_activity where datname like '$DB%' and usename is not null group by 1,2 order by 1" postgres
        Api GET 'dashboard'
        Api GET 'bookings' | Out-Null; $bk = @($script:LastBody | ConvertFrom-Json).Count; "bookings returned by the app: $bk"
        Q "select count(*) as bookings_in_restored_copy from habalgo.booking" $RES
        StopApp
    } | Save "a6_verify.txt"
    & {
        Q "select datname,datacl from pg_database where datname like '$DB%' order by 1" postgres
        Q "select rolname from pg_roles where rolname ~ '^(habalgo|app_)' order by 1"
        "--- table privileges of the roles: original vs restored copy"
        foreach ($d in @($DB, $RES)) { Q "select grantee, count(*) as grants from information_schema.role_table_grants where table_schema='habalgo' and grantee ~ '^(habalgo|app_)' group by 1 order by 1" $d }
        "--- default privileges (ALTER DEFAULT PRIVILEGES) in each"
        foreach ($d in @($DB, $RES)) { Q "select defaclrole::regrole as creator, defaclnamespace::regnamespace as schema, defaclobjtype, defaclacl from pg_default_acl order by 3" $d }
        "--- login as the application account against the restored copy"
        QL "select count(*) from habalgo.customer" $APPU $APPPW $RES
        QL "update habalgo.payment set amount=amount where false" $APPU $APPPW $RES
        QL "select count(*) from habalgo.customer" $ROU $ROPW $RES
        QL "insert into habalgo.customer(name,phone,email) values ('x','1','x@x.x')" $ROU $ROPW $RES
        "--- owner of the objects"
        Q "select tablename, tableowner from pg_tables where schemaname='habalgo' order by 1" $RES
    } | Save "a6_access.txt"
    & {
        $sum = "select count(*) as rows, md5(string_agg(t::text, '' order by t::text)) as table_checksum from habalgo.payment t"
        "target table: payment (money records)"
        "== BEFORE (restored copy)";     Q $sum $RES postgres
        "== INCIDENT: a bad update changes every payment to 0.01 and a delete removes the Paid ones from the restored copy"
        Q "update habalgo.payment set amount = 0.01" $RES postgres
        Q "delete from habalgo.payment where status = 'Paid'" $RES postgres
        "== AFTER LOSS";   Q $sum $RES postgres
        Q "select coalesce(sum(amount),0) as revenue_as_dashboard_reports_it from habalgo.payment where status='Paid'" $RES postgres
        "== RECOVERY: restore the same dump into $REC"
        Run createdb -U postgres -h localhost $REC
        $m = Run pg_restore -U postgres -h localhost -d $REC $F
        "pg_restore exit code: $LASTEXITCODE"; if ($m) { $m }
        "== RECOVERED";    Q $sum $REC postgres
        Q "select coalesce(sum(amount),0) as revenue_as_dashboard_reports_it from habalgo.payment where status='Paid'" $REC postgres
        "== ORIGINAL DATABASE UNTOUCHED"; Q $sum $DB postgres
    } | Save "a6_recovery.txt"
    StopApp | Out-Null
    "PHP server stopped. Test databases $RES, $REC and ${DB}_alt were left for screenshots. Drop later: dropdb -U postgres -h localhost <name>"
}

Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
foreach ($v in 'DB_HOST','DB_PORT','DB_NAME','DB_USER','DB_PASS') { Remove-Item "Env:$v" -ErrorAction SilentlyContinue }
""
"DONE ($Phase). Evidence in $E"
Get-ChildItem $E | Select-Object Name, Length | Format-Table | Out-String
