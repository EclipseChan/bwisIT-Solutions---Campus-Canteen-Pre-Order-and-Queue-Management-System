# Purpose: Collect PostgreSQL version, database size, objects, database stats, and session metadata.
# Activity/Part: Activity 5 / Part A.
# Required account: Configured Activity 4 read-only/auditor account where possible.
# Safety notes: Read-only; query text is excluded to avoid saving sensitive SQL literals.
# Expected result: Health queries return and evidence records output or permission limitations.
[CmdletBinding()]
param([string]$Project='group-01',[string]$DbName,[string]$DbHost,[string]$DbPort,[string]$AdminUser,[string]$AppUser,[string]$ReadonlyUser,[string]$ConfigPath,[string]$EvidenceDir,[switch]$DryRun,[switch]$Execute,[switch]$LoadEnv)
. (Join-Path $PSScriptRoot '..\lib\common.ps1')
$ctx=Initialize-ConfiguredCheck -Activity 5 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -ConfigPath $ConfigPath -EvidenceDir $EvidenceDir -DbName $DbName -DbHost $DbHost -DbPort $DbPort -AdminUser $AdminUser -AppUser $AppUser -ReadonlyUser $ReadonlyUser -RequiredFields @('dbName','readonlyUser') -LoadEnv:$LoadEnv -DryRun:$DryRun
if (-not $ctx.Ready) { exit (Complete-Verification) }
$sql=@"
SELECT version();
SELECT current_database();
SELECT pg_size_pretty(pg_database_size(current_database()));
SELECT table_schema, count(*) AS user_tables FROM information_schema.tables
 WHERE table_type='BASE TABLE' AND table_schema NOT IN ('information_schema','pg_catalog') GROUP BY table_schema ORDER BY table_schema;
SELECT schemaname, count(*) AS indexes FROM pg_indexes WHERE schemaname NOT IN ('information_schema','pg_catalog') GROUP BY schemaname ORDER BY schemaname;
SELECT schemaname, count(*) AS sequences FROM pg_sequences WHERE schemaname NOT IN ('information_schema','pg_catalog') GROUP BY schemaname ORDER BY schemaname;
SELECT datname,numbackends,xact_commit,xact_rollback,blks_read,blks_hit,deadlocks,conflicts,temp_files,temp_bytes FROM pg_stat_database WHERE datname=current_database();
SELECT pid,usename,application_name,state,wait_event_type,wait_event,query_start,clock_timestamp()-query_start AS duration FROM pg_stat_activity WHERE datname=current_database() ORDER BY query_start NULLS LAST;
"@
if ($DryRun) { Write-Output $sql; Write-Check SKIP 'database health' 'Dry run; no database connection.'; exit (Complete-Verification) }
if (-not $Execute) { Write-Check BLOCKED 'database health' 'Pass -DryRun or -Execute.'; exit (Complete-Verification) }
$result=Invoke-ProjectPsql $ctx.Config $ctx.Config.dbName $ctx.Config.readonlyUser $sql
Write-ResultOutput $result
if ($result.ExitCode -eq 0) { Write-Check PASS 'database health' 'Version, database, size, object counts, stats, and permitted session metadata captured.' }
else { Write-Check BLOCKED 'database health' 'One or more catalog/statistics queries were unavailable; inspect output and record the permission limitation.' }
exit (Complete-Verification)
