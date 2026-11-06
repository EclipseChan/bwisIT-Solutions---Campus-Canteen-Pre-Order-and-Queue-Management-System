# Purpose: Summarize active, idle, idle-in-transaction, waiting, and long-running sessions.
# Activity/Part: Activity 5 / Part A.
# Required account: Configured Activity 4 read-only/auditor account where possible.
# Safety notes: Read-only; query text is intentionally omitted from saved output.
# Expected result: Session summary is captured; long-running/waiting sessions are flagged.
[CmdletBinding()]
param([string]$Project='group-01',[string]$DbName,[string]$DbHost,[string]$DbPort,[string]$AdminUser,[string]$AppUser,[string]$ReadonlyUser,[string]$ConfigPath,[string]$EvidenceDir,[int]$LongRunningSeconds=60,[switch]$DryRun,[switch]$Execute,[switch]$LoadEnv)
. (Join-Path $PSScriptRoot '..\lib\common.ps1')
$ctx=Initialize-ConfiguredCheck -Activity 5 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -ConfigPath $ConfigPath -EvidenceDir $EvidenceDir -DbName $DbName -DbHost $DbHost -DbPort $DbPort -AdminUser $AdminUser -AppUser $AppUser -ReadonlyUser $ReadonlyUser -RequiredFields @('dbName','readonlyUser') -LoadEnv:$LoadEnv -DryRun:$DryRun
if (-not $ctx.Ready) { exit (Complete-Verification) }
$sql="SELECT state, count(*) AS sessions FROM pg_stat_activity WHERE datname=current_database() GROUP BY state ORDER BY state; SELECT pid,usename,application_name,state,wait_event_type,wait_event,query_start,extract(epoch FROM clock_timestamp()-query_start)::int AS duration_seconds FROM pg_stat_activity WHERE datname=current_database() AND (state='active' OR state='idle in transaction' OR wait_event_type IS NOT NULL) ORDER BY query_start NULLS LAST;"
if ($DryRun) { Write-Output $sql; Write-Output ('Long-running threshold seconds: ' + $LongRunningSeconds); Write-Check SKIP 'session activity' 'Dry run; no database connection.'; exit (Complete-Verification) }
if (-not $Execute) { Write-Check BLOCKED 'session activity' 'Pass -DryRun or -Execute.'; exit (Complete-Verification) }
$result=Invoke-ProjectPsql $ctx.Config $ctx.Config.dbName $ctx.Config.readonlyUser $sql -TupleOnly
Write-ResultOutput $result
if ($result.ExitCode -ne 0) { Write-Check BLOCKED 'session activity' 'pg_stat_activity not accessible with configured account.'; exit (Complete-Verification) }
$sessions=@($result.Output | Where-Object { $_ -match '\|' })
$flagged=@($sessions | Where-Object { $_ -match '^\d+\|.*\|(active|idle in transaction)\|.*\|\d+$' -and [int]($_.Split('|')[-1]) -ge $LongRunningSeconds })
if ($flagged.Count -gt 0) { $flagged | ForEach-Object { Write-Output ('FLAGGED session: ' + $_) }; Write-Check FAIL 'long-running/waiting sessions' ($flagged.Count.ToString() + ' session(s) meet the configured threshold or state condition; review with owner.') }
else { Write-Check PASS 'session activity' 'Session summary captured; no active/idle-in-transaction session exceeded the configured threshold.' }
exit (Complete-Verification)
