# Purpose: Verify restored objects, configured tables/sequences, constraints, roles, and optional access/query tests.
# Activity/Part: Activity 6 / Part C.
# Required account: Configured Activity 4 maintenance/read-only accounts suited to each check.
# Safety notes: Read-only by default; allowed/denied test SQL files must be reviewed and supplied explicitly.
# Expected result: Expected objects and access tests match the project plan; differences are recorded.
[CmdletBinding()]
param([string]$Project='group-01',[string]$DbName,[string]$DbHost,[string]$DbPort,[string]$AdminUser,[string]$AppUser,[string]$ReadonlyUser,[string]$ConfigPath,[string]$EvidenceDir,[string]$RestoreDbName,[string]$AllowedSqlFile,[string]$DeniedSqlFile,[string]$SelectSqlFile,[switch]$DryRun,[switch]$Execute,[switch]$LoadEnv)
. (Join-Path $PSScriptRoot '..\lib\common.ps1')
$ctx=Initialize-ConfiguredCheck -Activity 6 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -ConfigPath $ConfigPath -EvidenceDir $EvidenceDir -DbName $DbName -DbHost $DbHost -DbPort $DbPort -AdminUser $AdminUser -AppUser $AppUser -ReadonlyUser $ReadonlyUser -RequiredFields @('dbName','adminUser','appUser','readonlyUser','schemaName') -LoadEnv:$LoadEnv -DryRun:$DryRun
if (-not $ctx.Ready) { exit (Complete-Verification) }
if ([string]::IsNullOrWhiteSpace($RestoreDbName) -or $RestoreDbName -eq [string]$ctx.Config.dbName -or $RestoreDbName -notmatch '^[A-Za-z0-9_]+_a6_restore_[0-9]{8}$') { Write-Check BLOCKED 'restore target safety' 'Supply a confirmed distinct *_a6_restore_YYYYMMDD database.'; exit (Complete-Verification) }
$sql=@"
SELECT n.nspname,c.relname,c.relkind FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
 WHERE n.nspname NOT IN ('information_schema','pg_catalog') AND c.relkind IN ('r','p','S','v','m') ORDER BY 1,2;
SELECT conrelid::regclass,conname,contype,pg_get_constraintdef(oid) FROM pg_constraint WHERE connamespace NOT IN ('information_schema'::regnamespace,'pg_catalog'::regnamespace) ORDER BY 1,2;
SELECT schemaname,sequencename,last_value FROM pg_sequences WHERE schemaname NOT IN ('information_schema','pg_catalog') ORDER BY 1,2;
SELECT rolname,rolcanlogin,rolcreatedb,rolcreaterole FROM pg_roles WHERE rolname NOT LIKE 'pg\_%' ESCAPE '\' ORDER BY rolname;
SELECT member.rolname,parent.rolname FROM pg_auth_members m JOIN pg_roles member ON member.oid=m.member JOIN pg_roles parent ON parent.oid=m.roleid ORDER BY 1,2;
"@
if ($DryRun) { Write-Output ('Database: ' + $RestoreDbName); Write-Output $sql; Write-Output 'Expected tables: config.expectedTables; sequences: config.expectedSequences'; Write-Check SKIP 'restore verification' 'Dry run; no connection or test operation.'; exit (Complete-Verification) }
if (-not $Execute) { Write-Check BLOCKED 'restore verification' 'Pass -DryRun or -Execute.'; exit (Complete-Verification) }
$result=Invoke-ProjectPsql $ctx.Config $RestoreDbName $ctx.Config.adminUser $sql -TupleOnly
Write-ResultOutput $result
if ($result.ExitCode -ne 0) { Write-Check BLOCKED 'restore catalog verification' 'Catalog verification failed or target is unavailable.'; exit (Complete-Verification) }
$tableRows=@($result.Output | Where-Object { $_ -match '\|' -and $_ -match '\|(r|p)$' })
$actualTables=@($tableRows | ForEach-Object { $parts=$_.Split('|'); $parts[0]+'.'+$parts[1] })
if (@((Get-ConfigProperty $ctx.Config 'expectedTables' @())).Count -eq 0) { Write-Check BLOCKED 'expected tables' 'Populate expectedTables in local project config from authoritative schema.' }
else {
    foreach ($table in (Get-ConfigProperty $ctx.Config 'expectedTables' @())) {
        $name=[string]$table
        if ($actualTables -contains $name -or ($actualTables | Where-Object { $_.EndsWith('.'+$name) }).Count -gt 0) { Write-Check PASS ('restored table ' + $name) 'Present.' }
        else { Write-Check FAIL ('restored table ' + $name) 'Expected table missing.' }
        $parts=$name.Split('.'); if ($parts.Count -eq 1) { $qualified=(ConvertTo-SqlIdentifier ([string](Get-ConfigProperty $ctx.Config 'schemaName')))+'.'+(ConvertTo-SqlIdentifier $parts[0]) } else { $qualified=Quote-QualifiedIdentifier $name }
        $count=Invoke-ProjectPsql $ctx.Config $RestoreDbName $ctx.Config.adminUser ('SELECT count(*) FROM '+$qualified+';') -TupleOnly
        if ($count.ExitCode -eq 0) { Write-Output ('ROW COUNT '+$name+': '+($count.Output -join '')) } else { Write-Check FAIL ('row count '+$name) 'Could not count restored table.' }
    }
}
if (@((Get-ConfigProperty $ctx.Config 'expectedSequences' @())).Count -eq 0) { Write-Check BLOCKED 'expected sequences' 'Populate expectedSequences in local project config or explicitly document that none are expected.' }
else {
    foreach ($sequence in (Get-ConfigProperty $ctx.Config 'expectedSequences' @())) {
        $sequenceCheck=Invoke-ProjectPsql $ctx.Config $RestoreDbName $ctx.Config.adminUser ("SELECT to_regclass("+(ConvertTo-SqlLiteral ([string]$sequence))+') IS NOT NULL;') -TupleOnly
        if ($sequenceCheck.ExitCode -eq 0 -and @($sequenceCheck.Output | Where-Object { $_ -eq 't' }).Count -gt 0) { Write-Check PASS ('restored sequence '+$sequence) 'Present in catalog.' }
        else { Write-Check FAIL ('restored sequence '+$sequence) 'Expected sequence missing or could not be queried.' }
    }
}
$constraints=@($result.Output | Where-Object { $_ -match '\|' -and $_ -match '\|[pcfuxt]\|' })
$primaryKeys=@($constraints | Where-Object { $_ -match '\|p\|' })
$foreignKeys=@($constraints | Where-Object { $_ -match '\|f\|' })
if ($primaryKeys.Count -gt 0) { Write-Check PASS 'restored primary keys' ($primaryKeys.Count.ToString()+' captured; compare definitions to source schema.') } else { Write-Check BLOCKED 'restored primary keys' 'No primary-key rows parsed; confirm expected objects from source schema.' }
if ($foreignKeys.Count -gt 0) { Write-Check PASS 'restored foreign keys' ($foreignKeys.Count.ToString()+' captured; compare definitions to source schema.') } else { Write-Check BLOCKED 'restored foreign keys' 'No foreign-key rows parsed; confirm expected objects from source schema.' }
if ($constraints.Count -gt 0) { Write-Check PASS 'restored constraints' ($constraints.Count.ToString()+' constraint rows captured; compare definitions to source schema.') } else { Write-Check BLOCKED 'restored constraints' 'No constraint rows parsed; confirm whether constraints are expected and inspect raw output.' }
$roleNames=@($result.Output | Where-Object { $_ -match '\|' } | ForEach-Object { $_.Split('|')[0] })
foreach ($role in @((Get-ConfigProperty $ctx.Config 'loginRoles' @()) | ForEach-Object { [string]$_.name })) {
    if ($roleNames -contains $role) { Write-Check PASS ('role present in cluster '+$role) 'Present; roles are cluster-wide, separately verify memberships/privileges.' }
    else { Write-Check BLOCKED ('role '+$role) 'Not present in restored cluster; recreate using approved Activity 4 role scripts and re-run verification.' }
}
foreach ($membership in @((Get-ConfigProperty $ctx.Config 'memberships' @()))) {
    $member=[string]$membership.member; $role=[string]$membership.role
    if ([string]::IsNullOrWhiteSpace($member) -or [string]::IsNullOrWhiteSpace($role) -or $member -match '^<.*>$' -or $role -match '^<.*>$') { Write-Check BLOCKED 'restored role memberships' 'Complete memberships in local configuration.'; break }
    $membershipResult=Invoke-ProjectPsql $ctx.Config 'postgres' $ctx.Config.adminUser ("SELECT pg_has_role("+(ConvertTo-SqlLiteral $member)+','+(ConvertTo-SqlLiteral $role)+",'member');") -TupleOnly
    if ($membershipResult.ExitCode -eq 0 -and @($membershipResult.Output | Where-Object { $_ -eq 't' }).Count -gt 0) { Write-Check PASS ('role membership '+$member+' -> '+$role) 'Present in cluster.' }
    else { Write-Check BLOCKED ('role membership '+$member+' -> '+$role) 'Missing or cluster-level roles are not available; rerun approved Activity 4 role/membership scripts.' }
}
Write-Check BLOCKED 'Activity 4 privilege revalidation' 'Run the Activity 4 database/schema/table/sequence/default privilege and PUBLIC checks against this restored database; role presence alone is insufficient.'
foreach ($pair in @(@{File=$AllowedSqlFile;User=[string]$ctx.Config.appUser;Name='permitted operation';Expected=0},@{File=$DeniedSqlFile;User=[string]$ctx.Config.readonlyUser;Name='denied operation';Expected=1})) {
    if ([string]::IsNullOrWhiteSpace($pair.File) -or -not (Test-Path -LiteralPath $pair.File -PathType Leaf)) { Write-Check BLOCKED $pair.Name 'Provide reviewed project-adapted allowed/denied SQL file.'; continue }
    $test=Invoke-ProjectPsql $ctx.Config $RestoreDbName $pair.User $null $pair.File
    Write-ResultOutput $test
    if ($test.ExitCode -eq $pair.Expected) { Write-Check PASS $pair.Name 'Operation outcome matched expected policy.' } else { Write-Check FAIL $pair.Name ('Expected exit '+$pair.Expected+', got '+$test.ExitCode+'.') }
}
if ([string]::IsNullOrWhiteSpace($SelectSqlFile) -or -not (Test-Path -LiteralPath $SelectSqlFile -PathType Leaf)) { Write-Check BLOCKED 'representative SELECT' 'Supply reviewed -SelectSqlFile.' }
else {
    $selectText=(Get-Content -LiteralPath $SelectSqlFile -Raw).Trim()
    if ($selectText -notmatch '^(?i:SELECT)\b' -or $selectText -match '(?i)\b(INSERT|UPDATE|DELETE|DROP|ALTER|CREATE|TRUNCATE|COPY|CALL|DO)\b') { Write-Check BLOCKED 'representative SELECT' 'File failed simple SELECT-only safety check.' }
    else { $select=Invoke-ProjectPsql $ctx.Config $RestoreDbName $ctx.Config.readonlyUser $selectText; Write-ResultOutput $select; if ($select.ExitCode -eq 0) { Write-Check PASS 'representative SELECT' 'Query completed; compare rows with expected source result.' } else { Write-Check FAIL 'representative SELECT' 'Query failed.' } }
}
$app=Invoke-ProjectPsql $ctx.Config $RestoreDbName $ctx.Config.appUser 'SELECT 1;'
if ($app.ExitCode -eq 0) { Write-Check PASS 'application database connection' 'Runtime account connected to restored database.' } else { Write-Check BLOCKED 'application database connection' 'Connection failed; inspect local configuration and grants.' }
exit (Complete-Verification)
