# run_bp.ps1 - Activities 3 to 6 for BrewPOS (Spring Boot + PostgreSQL, group 4), retest by G08
#   cd $HOME\dba\bp; Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#   .\run_bp.ps1 -Phase deploy   (A3: clean database, schema.sql, seed.sql, .env, mvnw test, start the app)
#   .\run_bp.ps1 -Phase app      (A3: TESTING_GUIDE steps and API checks)
#   .\run_bp.ps1 -Phase a4       (A4: brewpos_app role, documented group roles, API as brewpos_app)
#   .\run_bp.ps1 -Phase a56      (A5 maintenance and A6 backup/restore/recovery; stops the app)
param([ValidateSet('deploy','app','a4','a56')][string]$Phase = 'deploy', [string]$DB = 'grp_brewposdb', [string]$G = 'BP')

$BASE = "$HOME\dba\bp"; $ROOT = "$BASE\brewpos-main"; $URL = 'http://localhost:8081'
$E = "$HOME\dba\evidence\g$G"; New-Item -ItemType Directory -Force $BASE, $E, "$HOME\dba\backups" | Out-Null
$sec = Read-Host "postgres password" -AsSecureString
$PGA = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec))
$env:PGPASSWORD = $PGA
$APPPW = 'BpApp2026test'

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
function WriteEnv($user, $pw, $db = $DB) {
    Copy-Item "$ROOT\.env.example" "$ROOT\.env" -Force
    $c = Get-Content "$ROOT\.env.example" -Raw
    $c = $c.Replace('DB_USERNAME=postgres', "DB_USERNAME=$user").Replace('your_password_here', ($pw -replace '\\', '\\')).Replace('/grp_brewposdb', "/$db")
    [IO.File]::WriteAllText("$ROOT\.env", $c)
}
function StopApp { $p = PortPid 8081; if ($p) { & taskkill /PID $p /T /F 2>&1 | Out-Null; Start-Sleep 2; "stopped app (pid $p)" } }
function StartApp {
    if (PortPid 8081) { "app already listening on port 8081"; return }
    Remove-Item "$BASE\app_out.txt", "$BASE\app_err.txt" -ErrorAction SilentlyContinue
    $env:JAVA_HOME = if ($env:JAVA_HOME) { $env:JAVA_HOME } else { try { Split-Path (Split-Path (Get-Command javac -ErrorAction Stop).Source) } catch { $null } }
    Start-Process cmd -ArgumentList '/c', 'mvnw.cmd spring-boot:run' -WorkingDirectory $ROOT -RedirectStandardOutput "$BASE\app_out.txt" -RedirectStandardError "$BASE\app_err.txt" -WindowStyle Hidden
    for ($i = 0; $i -lt 240 -and -not (PortPid 8081); $i++) { Start-Sleep 1 }
    "app start: " + $(if (PortPid 8081) { 'listening on port 8081' } else { 'NOT listening' })
}
# one REST call; prints status and the start of the body; keeps $script:LastBody / $script:LastCode
function Api($method, $path, $body = $null, $note = '', [string[]]$extra = @()) {
    $a = @('-s', '-m', '60', '-X', $method, '-D', "$BASE\hdr.txt", '-o', "$BASE\body.txt", '-w', '%{http_code}')
    if ($body) { [IO.File]::WriteAllText("$BASE\req.json", $body); $a += @('-H', 'Content-Type: application/json', '--data-binary', "@$BASE\req.json") }
    $a += $extra; $a += "$URL$path"
    $script:LastCode = (& curl.exe @a 2>&1 | Out-String).Trim()
    $script:LastBody = (Get-Content "$BASE\body.txt" -Raw -ErrorAction SilentlyContinue); if (-not $script:LastBody) { $script:LastBody = '' }
    $b = $script:LastBody.Trim(); $n = $b.Length; if ($n -gt 150) { $b = $b.Substring(0, 150) + "... ($n chars)" }
    $line = "$method $path"; if ($body) { $line += "  body=$($body.Trim())" }
    $line += "  ->  HTTP $script:LastCode"; if ($b) { $line += "  $b" }; if ($note) { $line += "   <$note>" }
    $line
}
function J { try { $script:LastBody | ConvertFrom-Json } catch { $null } }

if ($Phase -eq 'deploy') {
    & {
        "run at $(Get-Date)"
        if (-not (Test-Path $ROOT)) {
            $z = Get-ChildItem $BASE -Filter '*.zip' | Select-Object -First 1
            if (-not $z) { throw "zip not found in $BASE" }
            "extracting $($z.FullName)"; Expand-Archive $z.FullName $BASE -Force
        }
        "--- prerequisites"
        "java:"; Run java -version; "javac:"; Run javac -version; Run psql --version
        "--- clean start: drop any database left from earlier testing, then follow README Option B"
        Run psql -U postgres -h localhost -d postgres -c "DROP DATABASE IF EXISTS $DB"
        Run psql -U postgres -h localhost -d postgres -c "DROP DATABASE IF EXISTS ${DB}_restore"
        Run psql -U postgres -h localhost -d postgres -c "DROP DATABASE IF EXISTS ${DB}_recovery"
        Run psql -U postgres -h localhost -d postgres -c "CREATE DATABASE $DB;"
        "--- schema.sql"
        Run psql -U postgres -h localhost -d $DB -v ON_ERROR_STOP=1 -f "$ROOT\database\schema.sql"
        "--- seed.sql (first run)"
        Run psql -U postgres -h localhost -d $DB -v ON_ERROR_STOP=1 -f "$ROOT\database\seed.sql"
        $cnt = "select 'staff' t,count(*) from staff union all select 'menu_category',count(*) from menu_category union all select 'menu_item',count(*) from menu_item union all select 'order_ticket',count(*) from order_ticket union all select 'order_line_item',count(*) from order_line_item"
        Q $cnt
        "--- seed.sql again (README says it is safe to run twice)"
        Run psql -U postgres -h localhost -d $DB -v ON_ERROR_STOP=1 -f "$ROOT\database\seed.sql" | Select-Object -Last 6
        Q $cnt
        "--- project's own database\03_verification_queries.sql (full output in a3_projectverify.txt, errors counted here)"
        $pv = Run psql -U postgres -h localhost -d $DB -f "$ROOT\database\03_verification_queries.sql"
        $pv | Out-File "$E\a3_projectverify.txt" -Encoding utf8
        "lines of output: $($pv.Count) ; lines containing ERROR: $(($pv | Select-String 'ERROR').Count)"
        "--- .env from .env.example (README step 3), postgres account"
        WriteEnv 'postgres' $PGA
        (Get-Content "$ROOT\.env" | ForEach-Object { if ($_ -match '^DB_PASSWORD') { 'DB_PASSWORD=********' } else { $_ } } | Where-Object { $_ -notmatch '^#' -and $_ })
        "--- database counts before the automated tests"
        Q $cnt
        "--- .\mvnw.cmd test (19 tests promised, needs the database)"
        $env:JAVA_HOME = if ($env:JAVA_HOME) { $env:JAVA_HOME } else { try { Split-Path (Split-Path (Get-Command javac -ErrorAction Stop).Source) } catch { $null } }
        $sw = [Diagnostics.Stopwatch]::StartNew()
        Push-Location $ROOT; cmd /c ".\mvnw.cmd test 2>&1" | Out-File "$E\a3_mvn_test_full.txt" -Encoding utf8; Pop-Location
        "elapsed seconds: $([math]::Round($sw.Elapsed.TotalSeconds))"
        Get-Content "$E\a3_mvn_test_full.txt" | Select-String 'Tests run:|BUILD|ERROR|FAIL' | Select-Object -Last 14 | ForEach-Object { $_.Line }
        "--- database counts after the automated tests (do the tests leave data behind?)"
        Q $cnt
        "--- start the app: .\mvnw.cmd spring-boot:run"
        StartApp
        Get-Content "$BASE\app_out.txt" -ErrorAction SilentlyContinue | Select-String 'Started BrewPosApplication|ERROR|WARN|HikariPool|Tomcat started' | Select-Object -First 8 | ForEach-Object { $_.Line }
        Get-Content "$BASE\app_err.txt" -ErrorAction SilentlyContinue | Select-Object -First 8
        "=== database verification ($DB)"
        Q "select table_name from information_schema.tables where table_schema='public' and table_type='BASE TABLE' order by 1"
        Q "select contype, count(*) from pg_constraint where connamespace='public'::regnamespace group by 1 order by 1"
        Q "select conrelid::regclass as tbl, conname, pg_get_constraintdef(oid) from pg_constraint where connamespace='public'::regnamespace and contype in ('c','f','u') order by 1,2"
        Q "select indexname, tablename from pg_indexes where schemaname='public' order by 2,1"
        Q "select sequencename from pg_sequences where schemaname='public' order by 1"
        Q "select count(*) as triggers, (select count(*) from pg_views where schemaname='public') as views from pg_trigger where not tgisinternal"
        Q "select staff_id, full_name, role from staff order by 1"
        Q "select usename, application_name, state, count(*) from pg_stat_activity where datname='$DB' group by 1,2,3"
        Q "select rolname, rolsuper from pg_roles where rolname = 'postgres' or rolname ~ '^(brewpos|app_)' order by 1"
        Q "select datname, datacl from pg_database where datname='$DB'"
        Q "select tablename, tableowner from pg_tables where schemaname='public' order by 1"
    } | Save "a3_deploy.txt"
    "The app is running at $URL. Leave it running."
}

if ($Phase -eq 'app') {
    & {
        "run at $(Get-Date)"
        StartApp
        $cash = Scalar "select staff_id from staff where role='CASHIER' order by 1 limit 1"
        $mgr  = Scalar "select staff_id from staff where role='MANAGER' order by 1 limit 1"
        $coffee = Scalar "select category_id from menu_category where category_name='Coffee'"
        $croiss = Scalar "select item_id from menu_item where item_name='Butter Croissant'"
        $pump = Scalar "select item_id from menu_item where item_name='Pumpkin Spice Latte'"
        "ids: cashier staff_id=$cash, manager staff_id=$mgr, category Coffee=$coffee, Butter Croissant=$croiss, Pumpkin Spice Latte=$pump"
        "=== pages and read endpoints"
        Api GET '/'
        Api GET '/api/staff'
        Api GET '/api/categories'
        Api GET '/api/menu/active'
        "   Pumpkin Spice Latte in the active menu: $($script:LastBody -match 'Pumpkin')"
        Api GET '/api/menu-items?activeOnly=false'
        "   Pumpkin Spice Latte in the full list: $($script:LastBody -match 'Pumpkin')"
        Api GET '/api/orders'
        Api GET '/api/reports/daily-sales?date=2026-11-06'
        "=== TESTING_GUIDE step 3: category and item"
        Api POST '/api/categories' '{"categoryName":"Tea Specials"}'
        $tea = (J).categoryId
        Api POST '/api/categories' '{"categoryName":"Coffee"}' 'duplicate category'
        Api POST '/api/categories' '{"categoryName":"   "}' 'blank name'
        Api POST '/api/categories' ('{"categoryName":"' + ('x' * 51) + '"}') '51 characters'
        Api POST '/api/menu-items' "{`"categoryId`":$tea,`"itemName`":`"Hojicha Latte`",`"price`":115.00,`"isActive`":true}"
        $hoj = (J).itemId
        Api POST '/api/menu-items' "{`"categoryId`":$tea,`"itemName`":`"Hojicha Latte`",`"price`":99.00}" 'duplicate item name in the same category'
        Api POST '/api/menu-items' "{`"categoryId`":$tea,`"itemName`":`"Neg`",`"price`":-1}" 'negative price'
        Api POST '/api/menu-items' "{`"categoryId`":$tea,`"itemName`":`"Frac`",`"price`":10.999}" '3 decimals'
        Api POST '/api/menu-items' "{`"categoryId`":$tea,`"itemName`":`"Huge`",`"price`":123456789.00}" '9 integer digits'
        Api POST '/api/menu-items' "{`"categoryId`":99999,`"itemName`":`"NoCat`",`"price`":5}" 'unknown category'
        Api POST '/api/menu-items' '{"itemName":"NoCatField","price":5}' 'missing categoryId'
        Api POST '/api/menu-items' "{`"categoryId`":$tea,`"itemName`":`"<script>alert(1)</script>`",`"price`":5}" 'markup in a name'
        Api POST '/api/menu-items' '{bad json' 'malformed JSON'
        "=== step 4: deactivate and reactivate"
        Api PATCH "/api/menu-items/$hoj/active" '{"isActive":false}'
        Api GET '/api/menu/active'; "   Hojicha in the active menu: $($script:LastBody -match 'Hojicha')"
        Api PATCH "/api/menu-items/$hoj/active" '{"isActive":true}'
        Api GET '/api/menu/active'; "   Hojicha in the active menu: $($script:LastBody -match 'Hojicha')"
        "=== step 5: cash order, same item on two lines must merge"
        Api POST '/api/orders' "{`"staffId`":$cash,`"paymentMethod`":`"CASH`",`"items`":[{`"itemId`":$hoj,`"quantity`":1},{`"itemId`":$hoj,`"quantity`":1},{`"itemId`":$croiss,`"quantity`":1}]}"
        $o1 = (J).orderId
        Q "select order_id, item_id, quantity, sold_price from order_line_item where order_id=$o1 order by item_id"
        Q "select sum(quantity*sold_price) as total from order_line_item where order_id=$o1"
        "=== step 6: price change must not alter old receipts"
        Api PUT "/api/menu-items/$hoj" "{`"categoryId`":$tea,`"itemName`":`"Hojicha Latte`",`"price`":150.00,`"isActive`":true}"
        Api GET "/api/orders/$o1"
        "=== step 7: online order and daily sales"
        Api POST '/api/orders' "{`"staffId`":$cash,`"paymentMethod`":`"ONLINE`",`"items`":[{`"itemId`":$hoj,`"quantity`":1}]}"
        $o2 = (J).orderId
        $today = Get-Date -Format 'yyyy-MM-dd'
        Api GET "/api/reports/daily-sales?date=$today"
        Api GET "/api/reports/daily-sales/by-payment?date=$today"
        Q "select coalesce(sum(l.quantity*l.sold_price),0) as net_sales, count(distinct t.order_id) as orders from order_ticket t join order_line_item l using(order_id) where t.order_timestamp >= current_date and t.order_timestamp < current_date + 1"
        Api GET "/api/orders?from=$today&to=$today"
        "=== step 8 and other order validation"
        Api POST '/api/orders' "{`"staffId`":$cash,`"paymentMethod`":`"CASH`",`"items`":[]}" 'empty order'
        Api POST '/api/orders' "{`"staffId`":$cash,`"paymentMethod`":`"CASH`",`"items`":[{`"itemId`":$croiss,`"quantity`":0}]}" 'quantity 0'
        Api POST '/api/orders' "{`"staffId`":$cash,`"paymentMethod`":`"CASH`",`"items`":[{`"itemId`":$croiss,`"quantity`":-3}]}" 'negative quantity'
        Api POST '/api/orders' "{`"staffId`":$cash,`"paymentMethod`":`"CARD`",`"items`":[{`"itemId`":$croiss,`"quantity`":1}]}" 'invalid payment method'
        Api POST '/api/orders' "{`"paymentMethod`":`"CASH`",`"items`":[{`"itemId`":$croiss,`"quantity`":1}]}" 'missing staffId'
        Api POST '/api/orders' "{`"staffId`":99999,`"paymentMethod`":`"CASH`",`"items`":[{`"itemId`":$croiss,`"quantity`":1}]}" 'unknown staff'
        Api POST '/api/orders' "{`"staffId`":$cash,`"paymentMethod`":`"CASH`",`"items`":[{`"itemId`":99999,`"quantity`":1}]}" 'unknown item'
        Api POST '/api/orders' "{`"staffId`":$cash,`"paymentMethod`":`"CASH`",`"items`":[{`"itemId`":$pump,`"quantity`":1}]}" 'inactive item (Pumpkin Spice Latte)'
        Api POST '/api/orders' "{`"staffId`":$cash,`"paymentMethod`":`"CASH`",`"price`":0.01,`"total`":1,`"items`":[{`"itemId`":$croiss,`"quantity`":1,`"price`":0.01}]}" 'client sends its own price and total'
        $o3 = (J).orderId
        Q "select item_id, quantity, sold_price from order_line_item where order_id=$o3"
        Api POST '/api/orders' "{`"staffId`":$cash,`"paymentMethod`":`"CASH`",`"items`":[{`"itemId`":$croiss,`"quantity`":2147483647}]}" 'quantity 2147483647'
        Q "select order_id, quantity, sold_price from order_line_item where quantity > 100000"
        "=== immutability and routing"
        Api DELETE "/api/orders/$o1" $null 'no delete endpoint'
        Api PUT "/api/orders/$o1" '{"paymentMethod":"ONLINE"}' 'no update endpoint'
        Api DELETE "/api/menu-items/$hoj" $null 'no delete endpoint for items'
        Api DELETE "/api/categories/$tea" $null 'category that still has an item'
        Api POST '/api/categories' '{"categoryName":"Temp Empty"}'
        $tmp = (J).categoryId
        Api DELETE "/api/categories/$tmp" $null 'empty category'
        Api GET '/api/orders/abc' $null 'text id'
        Api GET '/api/orders/999999' $null 'unknown id'
        Api GET '/api/reports/daily-sales?date=not-a-date'
        Api GET '/api/reports/daily-sales' $null 'no date'
        Api GET '/api/menu-items/999999'
        Api GET '/actuator/health' $null 'actuator not exposed?'
        Api GET '/api/staff/1'
        "=== headers and cross-origin"
        "--- response headers of GET /api/menu/active"
        Api GET '/api/menu/active' | Out-Null; Get-Content "$BASE\hdr.txt"
        "--- request with Origin: http://evil.example"
        Api GET '/api/staff' $null 'cross-origin read' @('-H', 'Origin: http://evil.example') | Out-Null; Get-Content "$BASE\hdr.txt" | Select-String 'Access-Control|HTTP/'
        "--- credentials sent? none of the calls above carried a cookie, token or password"
        "=== database after the tests"
        Q "select (select count(*) from menu_item) items, (select count(*) from order_ticket) orders, (select count(*) from order_line_item) lines, (select count(*) from menu_item where item_name like '<script>%') script_named_items"
        "=== direct database constraint checks (each rolled back or rejected)"
        Q "insert into menu_item(category_id,item_name,price) values ($coffee,'Neg',-1)"
        Q "insert into order_line_item(order_id,item_id,quantity,sold_price) values ($o1,$croiss,0,1)"
        Q "insert into order_ticket(staff_id,payment_method) values ($cash,'CARD')"
        Q "insert into staff(full_name,role) values ('X','OWNER')"
        Q "delete from menu_category where category_id=$coffee"
        Q "delete from menu_item where item_id=$hoj"
        "=== app log"
        Get-Content "$BASE\app_out.txt" -ErrorAction SilentlyContinue | Select-String 'ERROR|WARN|Exception' | Select-Object -Last 12 | ForEach-Object { $_.Line }
        Get-Content "$BASE\app_err.txt" -ErrorAction SilentlyContinue | Select-Object -Last 10
    } | Save "a3_app.txt"
    "The app keeps running at $URL for the screenshots."
}

if ($Phase -eq 'a4') {
    & {
        "run at $(Get-Date)"
        "=== PART A: documented role script database\05_create_app_role.sql, run as postgres (README optional step)"
        StopApp
        Run psql -U postgres -h localhost -d $DB -v ON_ERROR_STOP=1 -f "$ROOT\database\05_create_app_role.sql"
        Run psql -U postgres -h localhost -d $DB -c "ALTER ROLE brewpos_app WITH PASSWORD '$APPPW'"
        "--- second run must be harmless (idempotent)"
        Run psql -U postgres -h localhost -d $DB -v ON_ERROR_STOP=1 -f "$ROOT\database\05_create_app_role.sql" | Select-Object -Last 3
        Run psql -U postgres -h localhost -d $DB -c "ALTER ROLE brewpos_app WITH PASSWORD '$APPPW'"
        Q "select rolname, rolsuper, rolcreatedb, rolcreaterole, rolinherit, rolcanlogin, rolreplication, rolbypassrls, left(rolpassword,14) as pw_scheme from pg_authid where rolname='brewpos_app'"
        Q "select r.rolname, d.setconfig from pg_db_role_setting d join pg_roles r on r.oid=d.setrole where r.rolname='brewpos_app'"
        $tbls = 'staff','menu_category','menu_item','order_ticket','order_line_item'
        $parts = foreach ($pv in 'SELECT','INSERT','UPDATE','DELETE','TRUNCATE') { "case when has_table_privilege('brewpos_app',format('public.%I',tablename),'$pv') then '$($pv.Substring(0,1))' else '-' end as $($pv.ToLower())" }
        "--- privilege matrix for brewpos_app"
        Q "select tablename, $($parts -join ', ') from pg_tables where schemaname='public' order by 1"
        Q "select has_database_privilege('brewpos_app','$DB','CONNECT') connect, has_schema_privilege('brewpos_app','public','USAGE') usage, has_schema_privilege('brewpos_app','public','CREATE') create_in_schema, (select bool_and(has_sequence_privilege('brewpos_app', format('public.%I',sequencename), 'USAGE')) from pg_sequences where schemaname='public') seq_usage"
        "--- behaviour tests, real login as brewpos_app"
        $cash = Scalar "select staff_id from staff where role='CASHIER' order by 1 limit 1"
        $t = @(
          @('read staff', "select staff_id, full_name, role from staff order by 1"),
          @('INSERT staff', "insert into staff(full_name,role) values ('Intruder','MANAGER')"),
          @('UPDATE staff', "update staff set role='MANAGER' where false"),
          @('INSERT order (rolled back)', "BEGIN; insert into order_ticket(staff_id,payment_method) values ($cash,'CASH') returning order_id; ROLLBACK"),
          @('UPDATE order_ticket', "update order_ticket set payment_method='ONLINE' where false"),
          @('DELETE order_ticket', "delete from order_ticket where false"),
          @('UPDATE order_line_item sold_price', "update order_line_item set sold_price=0 where false"),
          @('DELETE order_line_item', "delete from order_line_item where false"),
          @('UPDATE menu_item price (rolled back)', "BEGIN; update menu_item set price=price+1 where item_id=1 returning item_id, price; ROLLBACK"),
          @('DELETE menu_item that has sales', "BEGIN; delete from menu_item where item_id=1; ROLLBACK"),
          @('DELETE menu_category that has items', "BEGIN; delete from menu_category where category_name='Coffee'; ROLLBACK"),
          @('TRUNCATE order_line_item', "truncate order_line_item"),
          @('CREATE TABLE', "create table public.zz(x int)"),
          @('DROP TABLE', "drop table menu_item"),
          @('ALTER TABLE', "alter table menu_item add column zz int"),
          @('CREATE ROLE', "create role zz_test"),
          @('VACUUM (not owner)', "vacuum public.menu_item"),
          @('pg_read_all_data style: read pg_authid', "select rolname from pg_authid limit 1"),
          @('SHOW statement_timeout, lock_timeout, search_path', "select current_setting('statement_timeout') st, current_setting('lock_timeout') lt, current_setting('search_path') sp"),
          @('statement_timeout works (pg_sleep 31 s)', "select pg_sleep(31)")
        )
        foreach ($x in $t) { "### $($x[0])"; QL $x[1] 'brewpos_app' $APPPW $DB }
        "### can brewpos_app connect to other databases? (PUBLIC keeps CONNECT by default)"
        QL "select current_database()" 'brewpos_app' $APPPW 'postgres'
        "=== PART B: group roles from docs/user-roles.md section 4 applied to the database"
        Q @"
DO `$`$ BEGIN
 IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='app_runtime_grp')  THEN CREATE ROLE app_runtime_grp  NOLOGIN; END IF;
 IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='app_readonly_grp') THEN CREATE ROLE app_readonly_grp NOLOGIN; END IF;
 IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname='app_admin_grp')    THEN CREATE ROLE app_admin_grp    NOLOGIN; END IF;
END `$`$
"@
        Q "GRANT CONNECT ON DATABASE $DB TO app_runtime_grp, app_readonly_grp, app_admin_grp"
        Q "GRANT USAGE ON SCHEMA public TO app_runtime_grp, app_readonly_grp, app_admin_grp"
        Q "GRANT SELECT ON public.staff TO app_runtime_grp"
        Q "GRANT SELECT, INSERT, UPDATE, DELETE ON public.menu_category, public.menu_item TO app_runtime_grp"
        Q "GRANT SELECT, INSERT ON public.order_ticket, public.order_line_item TO app_runtime_grp"
        Q "GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_runtime_grp"
        Q "GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_readonly_grp"
        Q "GRANT SELECT ON public.staff TO app_admin_grp"
        Q "GRANT ALL PRIVILEGES ON public.menu_category, public.menu_item TO app_admin_grp"
        Q "GRANT SELECT ON public.order_ticket, public.order_line_item TO app_admin_grp"
        Q "GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_admin_grp"
        "--- is brewpos_app a member of app_runtime_grp, as docs/user-roles.md says?"
        Q "select r.rolname as member, g.rolname as member_of from pg_auth_members m join pg_roles r on r.oid=m.member join pg_roles g on g.oid=m.roleid where r.rolname='brewpos_app'"
        $cols = foreach ($r in @(@('app_runtime_grp','runtime'), @('app_readonly_grp','readonly'), @('app_admin_grp','admin'))) {
            $parts = foreach ($pv in 'SELECT','INSERT','UPDATE','DELETE','TRUNCATE') { "case when has_table_privilege('$($r[0])',format('public.%I',tablename),'$pv') then '$($pv.Substring(0,1))' else '-' end" }
            "concat($($parts -join ',')) as $($r[1])"
        }
        "--- privilege matrix (S I U D T)"
        Q "select tablename, $($cols -join ', ') from pg_tables where schemaname='public' order by 1"
        $g = @(
          @('app_readonly_grp','read all five tables',"select (select count(*) from staff) s,(select count(*) from order_ticket) o"),
          @('app_readonly_grp','insert an order',"insert into order_ticket(staff_id,payment_method) values ($cash,'CASH')"),
          @('app_readonly_grp','read a sequence value',"select nextval('order_ticket_order_id_seq')"),
          @('app_runtime_grp','insert an order and a line (rolled back)',"BEGIN; insert into order_ticket(staff_id,payment_method) values ($cash,'CASH'); ROLLBACK"),
          @('app_runtime_grp','update a completed order',"update order_ticket set payment_method='ONLINE' where false"),
          @('app_runtime_grp','delete a menu category',"BEGIN; insert into menu_category(category_name) values ('zz_tmp'); delete from menu_category where category_name='zz_tmp'; ROLLBACK"),
          @('app_admin_grp','update a menu price (rolled back)',"BEGIN; update menu_item set price=price+1 where item_id=1; ROLLBACK"),
          @('app_admin_grp','TRUNCATE menu_item (ALL PRIVILEGES includes it)',"BEGIN; truncate menu_item cascade; ROLLBACK"),
          @('app_admin_grp','delete a completed order',"delete from order_ticket where false"),
          @('app_admin_grp','insert an order',"insert into order_ticket(staff_id,payment_method) values ($cash,'CASH')")
        )
        foreach ($x in $g) { "### [$($x[0])] $($x[1])"; Q $x[2] $DB $x[0] }
        "=== PART C: the application running as brewpos_app (what the README recommends)"
        WriteEnv 'brewpos_app' $APPPW
        StartApp
        Get-Content "$BASE\app_out.txt" -ErrorAction SilentlyContinue | Select-String 'Started BrewPosApplication|ERROR|HikariPool' | Select-Object -First 5 | ForEach-Object { $_.Line }
        Q "select usename, application_name, state, count(*) from pg_stat_activity where datname='$DB' group by 1,2,3"
        $coffee = Scalar "select category_id from menu_category where category_name='Coffee'"
        $croiss = Scalar "select item_id from menu_item where item_name='Butter Croissant'"
        Api GET '/api/menu/active'
        Api POST '/api/categories' '{"categoryName":"A4 Category"}'
        $c4 = (J).categoryId
        Api POST '/api/menu-items' "{`"categoryId`":$c4,`"itemName`":`"A4 Item`",`"price`":50.00}"
        $i4 = (J).itemId
        Api PUT "/api/menu-items/$i4" "{`"categoryId`":$c4,`"itemName`":`"A4 Item`",`"price`":60.00,`"isActive`":true}"
        Api POST '/api/orders' "{`"staffId`":$cash,`"paymentMethod`":`"CASH`",`"items`":[{`"itemId`":$croiss,`"quantity`":1}]}"
        Api GET "/api/reports/daily-sales?date=$(Get-Date -Format 'yyyy-MM-dd')"
        Api DELETE "/api/categories/$c4" $null 'category with an item'
        Api DELETE "/api/categories/$coffee" $null 'Coffee has items'
        "=== PART D: who is allowed to do what at the API? (no cookie, token or password in any call)"
        $mgr = Scalar "select staff_id from staff where role='MANAGER' order by 1 limit 1"
        Api POST '/api/menu-items' "{`"categoryId`":$c4,`"itemName`":`"Added by an anonymous caller`",`"price`":1.00}" 'a cashier-only user cannot do this in the UI'
        Api POST '/api/orders' "{`"staffId`":$mgr,`"paymentMethod`":`"CASH`",`"items`":[{`"itemId`":$croiss,`"quantity`":1}]}" 'order recorded under the manager id by anyone'
        Q "select t.order_id, s.full_name, s.role from order_ticket t join staff s using(staff_id) order by t.order_id desc limit 2"
        Api GET '/api/staff' $null 'staff list is public'
        Q "select staff_id, full_name, role from staff order by 1"
        "=== UI-only role switch"
        "grep for authentication in the source (security, login, password, token, @PreAuthorize):"
        $m = Get-ChildItem "$ROOT\src\main" -Recurse -File | Select-String -Pattern 'spring-security|SecurityFilterChain|@PreAuthorize|login|Authorization|Bearer' -SimpleMatch:$false | Select-Object -First 8
        if ($m) { $m | ForEach-Object { "$($_.Path.Replace($ROOT,'')):$($_.LineNumber): $($_.Line.Trim())" } } else { "no matches in src\main" }
        "spring-security in pom.xml: $((Select-String -Path "$ROOT\pom.xml" -Pattern 'security').Count) lines"
        "role check in the front end:"
        Get-ChildItem "$ROOT\src\main\resources\static" -Recurse -File | Select-String -Pattern 'MANAGER|isManager|currentStaff' | Select-Object -First 6 | ForEach-Object { "$($_.Path.Replace($ROOT,'')):$($_.LineNumber): $($_.Line.Trim())" }
        "=== pg_hba.conf rules"
        Q "select line_number, type, database, user_name, address, auth_method from pg_hba_file_rules order by line_number"
    } | Save "a4_access_tests.txt"
    "The app is running as brewpos_app."
}

if ($Phase -eq 'a56') {
    $RES = "${DB}_restore"; $REC = "${DB}_recovery"
    $F = "$HOME\dba\backups\${DB}_activity6.dump"
    $cnt = "select table_name, (xpath('/row/c/text()', query_to_xml(format('select count(*) as c from public.%I', table_name), false, true, '')))[1]::text::int as row_count from information_schema.tables where table_schema='public' and table_type='BASE TABLE' order by 1"
    & {
        "run at $(Get-Date)"
        if (PortPid 8081) { Api GET '/api/orders' | Out-Null; Api GET '/api/menu/active' | Out-Null }
        Q "select version()" postgres
        Q "select pg_size_pretty(pg_database_size('$DB')) as db_size"
        Q "select datname,numbackends,xact_commit,xact_rollback,blks_read,blks_hit,deadlocks,temp_files from pg_stat_database where datname='$DB'"
        Q "select pid,usename,application_name,state,left(query,60) as query from pg_stat_activity where datname='$DB'"
        Q "select relname,n_live_tup,n_dead_tup,last_vacuum,last_autovacuum,last_analyze,last_autoanalyze from pg_stat_user_tables order by relname"
        Q "select relname, pg_size_pretty(pg_total_relation_size(relid)) total, pg_size_pretty(pg_indexes_size(relid)) idx from pg_stat_user_tables order by pg_total_relation_size(relid) desc"
        Q $cnt
        Q "select indexrelname, relname, idx_scan from pg_stat_user_indexes order by relname, indexrelname"
        Q "show log_statement" postgres; Q "show log_min_duration_statement" postgres; Q "show max_connections" postgres; Q "show autovacuum" postgres
        "--- can brewpos_app run maintenance?"
        QL "VACUUM public.order_ticket" 'brewpos_app' $APPPW $DB
        QL "ANALYZE public.order_ticket" 'brewpos_app' $APPPW $DB
    } | Save "a5_health.txt"
    & {
        $dd = (Run psql -U postgres -h localhost -d postgres -At -c "show data_directory" | Out-String).Trim()
        $ld = (Run psql -U postgres -h localhost -d postgres -At -c "show log_directory" | Out-String).Trim()
        "data_directory=$dd"; "log_directory=$ld"
        $dir = if ([IO.Path]::IsPathRooted($ld)) { $ld } else { Join-Path $dd $ld }
        try {
            foreach ($f in (Get-ChildItem $dir -File -ErrorAction Stop | Sort-Object LastWriteTime -Descending | Select-Object -First 2)) {
                "== $($f.FullName) ($($f.Length) bytes, $($f.LastWriteTime))"
                Select-String -Path $f.FullName -Pattern "FATAL|ERROR|denied|failed|timeout" | Select-Object -Last 60 | ForEach-Object { $_.Line }
            }
        } catch { "Could not read the log folder: $($_.Exception.Message)" }
        "== app log (Spring Boot), warnings and errors"
        Get-Content "$BASE\app_out.txt" -ErrorAction SilentlyContinue | Select-String 'ERROR|WARN|Exception' | Select-Object -Last 25 | ForEach-Object { $_.Line }
        Get-Content "$BASE\app_err.txt" -ErrorAction SilentlyContinue | Select-Object -Last 15
        "== app log size: $((Get-Item "$BASE\app_out.txt" -ErrorAction SilentlyContinue).Length) bytes ; does the app write to a log file of its own?"
        (Get-ChildItem $ROOT -Recurse -Include *.log -ErrorAction SilentlyContinue | Select-Object -First 5 | ForEach-Object { $_.FullName })
    } | Save "a5_logs.txt"
    & {
        $q1 = "select t.order_id, t.order_timestamp, t.payment_method, s.full_name from order_ticket t join staff s on s.staff_id=t.staff_id order by t.order_timestamp desc, t.order_id desc"
        $q2 = "select sum(l.quantity*l.sold_price), count(distinct t.order_id) from order_ticket t join order_line_item l on l.order_id=t.order_id where t.order_timestamp >= current_date and t.order_timestamp < current_date + 1"
        $q3 = "select i.item_id, i.item_name, sum(l.quantity) from order_line_item l join menu_item i on i.item_id=l.item_id group by 1,2 order by 3 desc"
        Q "select relname,n_live_tup,n_dead_tup,last_vacuum,last_analyze from pg_stat_user_tables order by relname"
        Q "ANALYZE"
        Q "VACUUM (VERBOSE, ANALYZE) public.menu_item"
        Q "VACUUM (VERBOSE, ANALYZE) public.order_ticket"
        Q "select relname,n_live_tup,n_dead_tup,last_vacuum,last_analyze from pg_stat_user_tables order by relname"
        "--- query 1: the Orders list (newest first)"
        Q "EXPLAIN (ANALYZE, BUFFERS) $q1"
        "--- query 2: Daily Sales totals for today"
        Q "EXPLAIN (ANALYZE, BUFFERS) $q2"
        "--- query 3: best sellers"
        Q "EXPLAIN (ANALYZE, BUFFERS) $q3"
        "--- same Daily Sales query with sequential scans disabled, to see whether the index could be used at larger size"
        Q "BEGIN; SET LOCAL enable_seqscan = off; EXPLAIN (ANALYZE) $q2; ROLLBACK"
        Q "select indexname, tablename from pg_indexes where schemaname='public' order by 2,1"
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
        "--- README's own command from database\README.md: pg_dump -U postgres -Fc -d $DB -f brewpos_backup.dump (same format as used here)"
    } | Save "a6_backup.txt"
    & {
        foreach ($d in @($RES, $REC)) { Run psql -U postgres -h localhost -d postgres -c "DROP DATABASE IF EXISTS $d" }
        Run createdb -U postgres -h localhost $RES
        $sw = [Diagnostics.Stopwatch]::StartNew()
        $m = Run pg_restore -U postgres -h localhost -d $RES $F
        $ec = $LASTEXITCODE; $sw.Stop()
        "pg_restore exit code: $ec ; elapsed seconds: $([math]::Round($sw.Elapsed.TotalSeconds, 2))"
        if ($m) { "messages:"; $m } else { "no messages (no warnings or errors)" }
        "--- README's restore command with --clean --if-exists, run into the restored copy a second time"
        $m2 = Run pg_restore -U postgres -h localhost -d $RES --clean --if-exists $F
        "exit code: $LASTEXITCODE"; if ($m2) { $m2 | Select-Object -First 10 } else { "no messages" }
    } | Save "a6_restore.txt"
    & {
        foreach ($d in @($DB, $RES)) {
            "################ $d"
            Q "select (select count(*) from pg_tables where schemaname='public') tables,(select count(*) from pg_sequences where schemaname='public') sequences" $d
            Q $cnt $d
            Q "select contype,count(*) from pg_constraint where connamespace='public'::regnamespace group by contype order by contype" $d
            Q "select count(*) as indexes from pg_indexes where schemaname='public'" $d
            Q "select grantee, count(*) as table_grants from information_schema.role_table_grants where table_schema='public' group by 1 order by 1" $d
            Q "select md5(string_agg(t::text, '' order by t::text)) as order_line_checksum from order_line_item t" $d
            Q "select sequencename, last_value from pg_sequences where schemaname='public' order by 1" $d
            "--- constraint still enforced"
            Q "insert into order_line_item(order_id,item_id,quantity,sold_price) select order_id,item_id,0,1 from order_line_item limit 1" $d
            Q "insert into menu_item(category_id,item_name,price) values (1,'Neg',-1)" $d
        }
        "=== the application against the restored database"
        StopApp
        WriteEnv 'postgres' $PGA $RES
        StartApp
        Q "select datname, usename, count(*) from pg_stat_activity where datname like '$DB%' and usename is not null group by 1,2 order by 1" postgres
        Api GET '/api/orders' | Out-Null
        "orders returned by the app: " + ($script:LastBody | ConvertFrom-Json).Count
        Api GET '/api/menu/active'
        Q "select count(*) as orders_in_restored_copy from order_ticket" $RES
        StopApp
        WriteEnv 'postgres' $PGA $DB
    } | Save "a6_verify.txt"
    & {
        Q "select datname,datacl from pg_database where datname like '$DB%' order by 1" postgres
        Q "select rolname from pg_roles where rolname ~ '^(brewpos|app_)' order by 1"
        "--- table privileges of brewpos_app and the group roles: original vs restored copy"
        foreach ($d in @($DB, $RES)) {
            Q "select grantee, count(*) as grants from information_schema.role_table_grants where table_schema='public' and grantee ~ '^(brewpos|app_)' group by 1 order by 1" $d
        }
        "--- per-role settings (search_path, statement_timeout, lock_timeout) are stored per database, not in the dump"
        Q "select d.setdatabase::regdatabase as db, r.rolname, d.setconfig from pg_db_role_setting d join pg_roles r on r.oid=d.setrole order by 1" postgres
        "--- login as brewpos_app against the restored copy"
        QL "select current_setting('statement_timeout') st, current_setting('search_path') sp" 'brewpos_app' $APPPW $RES
        QL "select count(*) from order_ticket" 'brewpos_app' $APPPW $RES
        QL "delete from order_ticket where false" 'brewpos_app' $APPPW $RES
        QL "select current_setting('statement_timeout') st, current_setting('search_path') sp" 'brewpos_app' $APPPW $DB
        "--- owner of the objects"
        Q "select tablename, tableowner from pg_tables where schemaname='public' order by 1" $RES
    } | Save "a6_access.txt"
    & {
        $sum = "select count(*) as rows, md5(string_agg(t::text, '' order by t::text)) as table_checksum from public.order_line_item t"
        "target table: order_line_item (sales history)"
        "== BEFORE (restored copy)";     Q $sum $RES postgres
        "== INCIDENT: someone deletes the lines of the newest order directly in the database"
        Q "delete from public.order_line_item where order_id = (select max(order_id) from public.order_ticket)" $RES postgres
        "== AFTER LOSS";   Q $sum $RES postgres
        "== daily sales as the app would now report it"; Q "select coalesce(sum(quantity*sold_price),0) as net_sales from order_line_item" $RES postgres
        "== RECOVERY: restore the same dump into $REC"
        Run createdb -U postgres -h localhost $REC
        $m = Run pg_restore -U postgres -h localhost -d $REC $F
        "pg_restore exit code: $LASTEXITCODE"; if ($m) { $m }
        "== RECOVERED";    Q $sum $REC postgres
        Q "select coalesce(sum(quantity*sold_price),0) as net_sales from order_line_item" $REC postgres
        "== ORIGINAL DATABASE UNTOUCHED"; Q $sum $DB postgres
        "== whole-table recovery alternative: copy only the lost rows back (row-level repair from the recovery copy is not possible across databases without dblink, so the full restore was used)"
    } | Save "a6_recovery.txt"
    "Test databases $RES and $REC were left for screenshots. Drop later: dropdb -U postgres -h localhost <name>"
}

Remove-Item Env:PGPASSWORD -ErrorAction SilentlyContinue
""
"DONE ($Phase). Evidence in $E"
Get-ChildItem $E | Select-Object Name, Length | Format-Table | Out-String
