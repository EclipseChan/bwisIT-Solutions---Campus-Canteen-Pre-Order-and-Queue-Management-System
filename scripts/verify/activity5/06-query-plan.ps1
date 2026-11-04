# Purpose: Capture EXPLAIN and optional EXPLAIN ANALYZE/BUFFERS for one reviewed application SELECT.
# Activity/Part: Activity 5 / Part D.
# Required account: Configured Activity 4 account authorized to run the selected SELECT.
# Safety notes: Requires -SqlFile; inspect for safety. EXPLAIN ANALYZE executes the query and requires -Execute.
# Expected result: Plans are saved; actual rows/timing/buffers are available when ANALYZE was safely run.
[CmdletBinding()]
param([string]$Project='group-01',[string]$DbName,[string]$DbHost,[string]$DbPort,[string]$AdminUser,[string]$AppUser,[string]$ReadonlyUser,[string]$ConfigPath,[string]$EvidenceDir,[string]$SqlFile,[string]$QueryUser,[switch]$DryRun,[switch]$Execute,[switch]$LoadEnv)
. (Join-Path $PSScriptRoot '..\lib\common.ps1')
$ctx=Initialize-ConfiguredCheck -Activity 5 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -ConfigPath $ConfigPath -EvidenceDir $EvidenceDir -DbName $DbName -DbHost $DbHost -DbPort $DbPort -AdminUser $AdminUser -AppUser $AppUser -ReadonlyUser $ReadonlyUser -RequiredFields @('dbName','readonlyUser') -LoadEnv:$LoadEnv -DryRun:$DryRun
if (-not $ctx.Ready) { exit (Complete-Verification) }
if ([string]::IsNullOrWhiteSpace($SqlFile) -or -not (Test-Path -LiteralPath $SqlFile -PathType Leaf)) { Write-Check BLOCKED 'query SQL' 'Supply -SqlFile containing a reviewed single SELECT statement.'; exit (Complete-Verification) }
$query=(Get-Content -LiteralPath $SqlFile -Raw).Trim()
$normalized=$query -replace '(?s)/\*.*?\*/','' -replace '(?m)--.*$',''
$normalized=$normalized.Trim()
if ($normalized -notmatch '^(?i:SELECT)\b' -or $normalized -match ';.+\S' -or $normalized -match '(?i)\b(INSERT|UPDATE|DELETE|MERGE|DROP|ALTER|CREATE|TRUNCATE|COPY|CALL|DO|GRANT|REVOKE)\b') {
    Write-Check BLOCKED 'query SQL safety' 'Only a single reviewed SELECT is accepted; CTEs and multi-statement files are not accepted by this guard.'
    exit (Complete-Verification)
}
$user=$QueryUser
if ([string]::IsNullOrWhiteSpace($user)) { $user=[string]$ctx.Config.readonlyUser }
$explain='EXPLAIN ' + $normalized
$analyze='EXPLAIN (ANALYZE, BUFFERS) ' + $normalized
if ($DryRun) { Write-Output $explain; if ($Execute) { Write-Output $analyze }; Write-Check SKIP 'query plan' 'Dry run; no query executed.'; exit (Complete-Verification) }
if (-not $Execute) { Write-Check BLOCKED 'query plan' 'Pass -DryRun or -Execute; -Execute permits EXPLAIN ANALYZE to execute the SELECT.'; exit (Complete-Verification) }
$plan=Invoke-ProjectPsql $ctx.Config $ctx.Config.dbName $user $explain
Write-Output 'EXPLAIN'; Write-ResultOutput $plan
if ($plan.ExitCode -eq 0) { Write-Check PASS 'EXPLAIN plan' 'Estimated plan captured.' } else { Write-Check FAIL 'EXPLAIN plan' 'Query plan failed; inspect permissions/query.'; exit (Complete-Verification) }
$actual=Invoke-ProjectPsql $ctx.Config $ctx.Config.dbName $user $analyze
Write-Output 'EXPLAIN ANALYZE BUFFERS'; Write-ResultOutput $actual
if ($actual.ExitCode -eq 0) { Write-Check PASS 'EXPLAIN ANALYZE BUFFERS' 'Actual rows, execution time, and buffer data captured for interpretation.' }
else { Write-Check BLOCKED 'EXPLAIN ANALYZE BUFFERS' 'Safe SELECT plan could not be executed; retain estimated plan and document the limitation.' }
exit (Complete-Verification)
