# Purpose: Inspect PostgreSQL logging settings and explicitly configured log files.
# Activity/Part: Activity 5 / Part B.
# Required account: Configured Activity 4 read-only/auditor account; server log access may require approval.
# Safety notes: Only configured, explicit log paths are read; query text/credentials are not logged.
# Expected result: Real reviewed log findings are captured, or logging/access limitation is BLOCKED.
[CmdletBinding()]
param([string]$Project='group-01',[string]$DbName,[string]$DbHost,[string]$DbPort,[string]$AdminUser,[string]$AppUser,[string]$ReadonlyUser,[string]$ConfigPath,[string]$EvidenceDir,[switch]$DryRun,[switch]$Execute,[switch]$LoadEnv)
. (Join-Path $PSScriptRoot '..\lib\common.ps1')
$ctx=Initialize-ConfiguredCheck -Activity 5 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -ConfigPath $ConfigPath -EvidenceDir $EvidenceDir -DbName $DbName -DbHost $DbHost -DbPort $DbPort -AdminUser $AdminUser -AppUser $AppUser -ReadonlyUser $ReadonlyUser -RequiredFields @('dbName','readonlyUser') -LoadEnv:$LoadEnv -DryRun:$DryRun
if (-not $ctx.Ready) { exit (Complete-Verification) }
$cfg=$ctx.Config
$sql="SELECT name,setting FROM pg_settings WHERE name IN ('log_destination','logging_collector','log_directory','log_filename','log_connections','log_disconnections','log_min_duration_statement','log_statement','log_line_prefix','log_lock_waits') ORDER BY name;"
if ($DryRun) { Write-Output $sql; Write-Output ('Configured explicit log files: ' + (@((Get-ConfigProperty $cfg 'logFiles' @())) -join ', ')); Write-Check SKIP 'PostgreSQL log review' 'Dry run; no database/log access.'; exit (Complete-Verification) }
if (-not $Execute) { Write-Check BLOCKED 'PostgreSQL log review' 'Pass -DryRun or -Execute.'; exit (Complete-Verification) }
$settings=Invoke-ProjectPsql $cfg $cfg.dbName $cfg.readonlyUser $sql
Write-ResultOutput $settings
if ($settings.ExitCode -ne 0) { Write-Check BLOCKED 'logging settings' 'Could not query pg_settings.' }
else { Write-Check PASS 'logging settings' 'Current configuration captured; this is not itself proof that log files were reviewed.' }
$files=@((Get-ConfigProperty $cfg 'logFiles' @()))
if ($files.Count -eq 0) { Write-Check BLOCKED 'log file review' 'No explicit authorized logFiles configured. Confirm log source/path and time range with the owner; do not guess paths or invent findings.'; exit (Complete-Verification) }
foreach ($path in $files) {
    if (-not (Test-Path -LiteralPath ([string]$path) -PathType Leaf)) { Write-Check BLOCKED ('log file ' + [IO.Path]::GetFileName([string]$path)) 'Configured log is unavailable or access denied.'; continue }
    try {
        $content=Get-Content -LiteralPath ([string]$path)
        $counts=[ordered]@{
            authenticationFailures=@($content | Where-Object { $_ -match '(?i)(authentication failed|password authentication failed|login failed)' }).Count
            errors=@($content | Where-Object { $_ -match '(?i)\b(ERROR|FATAL|PANIC)\b' }).Count
            warnings=@($content | Where-Object { $_ -match '(?i)\bWARNING\b' }).Count
            deadlocks=@($content | Where-Object { $_ -match '(?i)\bdeadlock\b' }).Count
        }
        Write-Output ('Log name: ' + [IO.Path]::GetFileName([string]$path))
        Write-Output ('Line count: ' + $content.Count)
        foreach ($key in $counts.Keys) { Write-Output ($key + ': ' + $counts[$key]) }
        Write-Check PASS ('log file ' + [IO.Path]::GetFileName([string]$path)) 'Reviewed without copying raw log lines; inspect findings locally and document only redacted summaries.'
    } catch { Write-Check BLOCKED ('log file ' + [IO.Path]::GetFileName([string]$path)) 'Read failed; record access limitation and request approved log access.' }
}
exit (Complete-Verification)
