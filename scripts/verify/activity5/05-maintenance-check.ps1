# Purpose: Capture before/after table statistics and optionally run ANALYZE and standalone VACUUM.
# Activity/Part: Activity 5 / Part C.
# Required account: Configured Activity 4 maintenance-owner account, never the runtime account.
# Safety notes: -DryRun previews; both maintenance commands require -Execute and a verified -Table. Never VACUUM FULL.
# Expected result: ANALYZE and VACUUM complete; before/after statistics and output are saved.
[CmdletBinding()]
param([string]$Project='group-01',[string]$DbName,[string]$DbHost,[string]$DbPort,[string]$AdminUser,[string]$AppUser,[string]$ReadonlyUser,[string]$ConfigPath,[string]$EvidenceDir,[string]$Table,[switch]$DryRun,[switch]$Execute,[switch]$LoadEnv)
. (Join-Path $PSScriptRoot '..\lib\common.ps1')
$required=@('dbName','adminUser')
if ([string]::IsNullOrWhiteSpace($Table)) { $required+=@('maintenanceTable') }
$ctx=Initialize-ConfiguredCheck -Activity 5 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -ConfigPath $ConfigPath -EvidenceDir $EvidenceDir -DbName $DbName -DbHost $DbHost -DbPort $DbPort -AdminUser $AdminUser -AppUser $AppUser -ReadonlyUser $ReadonlyUser -RequiredFields $required -LoadEnv:$LoadEnv -DryRun:$DryRun
if (-not $ctx.Ready) { exit (Complete-Verification) }
$cfg=$ctx.Config
if ([string]::IsNullOrWhiteSpace($Table)) { $Table=[string]$cfg.maintenanceTable }
try { $qualified=Quote-QualifiedIdentifier $Table } catch { Write-Check BLOCKED 'maintenance target' 'Provide a verified schema.table identifier in -Table.'; exit (Complete-Verification) }
$parts=$Table.Split('.'); if ($parts.Count -eq 1) { $schema=[string]$cfg.schemaName; $tableName=$parts[0] } else { $schema=$parts[0]; $tableName=$parts[1] }
$pre="SELECT schemaname,relname,n_live_tup,n_dead_tup,seq_scan,idx_scan,last_vacuum,last_autovacuum,last_analyze,last_autoanalyze FROM pg_stat_user_tables WHERE schemaname=" + (ConvertTo-SqlLiteral $schema) + ' AND relname=' + (ConvertTo-SqlLiteral $tableName) + ';'
$analyze='ANALYZE ' + $qualified + ';'
$vacuum='VACUUM (VERBOSE, ANALYZE) ' + $qualified + ';'
$post=$pre
if ($DryRun) { Write-Output $pre; Write-Output $analyze; Write-Output $vacuum; Write-Check SKIP 'maintenance' 'Dry run; no SQL executed.'; exit (Complete-Verification) }
if (-not $Execute) { Write-Check BLOCKED 'maintenance' 'Pass -DryRun or -Execute after confirming target and maintenance window.'; exit (Complete-Verification) }
if ($ctx.Config.adminUser -eq $ctx.Config.appUser) { Write-Check FAIL 'maintenance account' 'Runtime account cannot be used for maintenance.'; exit (Complete-Verification) }
$before=Invoke-ProjectPsql $cfg $cfg.dbName $cfg.adminUser $pre
Write-Output 'BEFORE STATISTICS'; Write-ResultOutput $before
if ($before.ExitCode -ne 0) { Write-Check BLOCKED 'before statistics' 'Could not inspect target table statistics.'; exit (Complete-Verification) }
$a=Invoke-ProjectPsql $cfg $cfg.dbName $cfg.adminUser $analyze
Write-Output 'ANALYZE OUTPUT'; Write-ResultOutput $a
if ($a.ExitCode -eq 0) { Write-Check PASS 'ANALYZE' ('Completed for ' + $Table) } else { Write-Check FAIL 'ANALYZE' 'Command failed; inspect output and permissions.'; exit (Complete-Verification) }
$v=Invoke-ProjectPsql $cfg $cfg.dbName $cfg.adminUser $vacuum
Write-Output 'VACUUM OUTPUT'; Write-ResultOutput $v
if ($v.ExitCode -eq 0) { Write-Check PASS 'VACUUM (VERBOSE, ANALYZE)' ('Completed as standalone command for ' + $Table) } else { Write-Check FAIL 'VACUUM' 'Command failed; inspect output and permissions.' }
$after=Invoke-ProjectPsql $cfg $cfg.dbName $cfg.adminUser $post
Write-Output 'AFTER STATISTICS'; Write-ResultOutput $after
if ($after.ExitCode -eq 0) { Write-Check PASS 'after statistics' 'After-state captured.' } else { Write-Check BLOCKED 'after statistics' 'Could not query after-state.' }
exit (Complete-Verification)
