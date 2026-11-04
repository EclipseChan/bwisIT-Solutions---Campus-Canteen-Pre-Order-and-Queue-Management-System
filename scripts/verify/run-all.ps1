# Purpose: Run the Activity 4, 5, and 6 verification batches for one project.
# Activity/Part: Activities 4-6 / automated verification.
# Required account: Configured project accounts as required by the selected checks.
# Safety notes: -DryRun is the safe preview. Restore/recovery require -Execute and -Confirm.
# Expected result: Combined PASS/FAIL/SKIP/BLOCKED lines and final summary are saved.
[CmdletBinding()]
param([string]$Project='group-01',[string]$DbName,[string]$DbHost,[string]$DbPort,[string]$AdminUser,[string]$AppUser,[string]$ReadonlyUser,[string]$ConfigPath,[string]$EvidenceDir,[string]$BackupDir,[string]$BackupFile,[string]$RestoreDbName,[string]$RecoveryDbName,[string]$AllowedSqlFile,[string]$DeniedSqlFile,[string]$SelectSqlFile,[string]$MaintenanceTable,[string]$SqlFile,[string]$QueryUser,[string]$RPO,[switch]$DryRun,[switch]$Execute,[switch]$Confirm,[switch]$LoadEnv)
. (Join-Path $PSScriptRoot 'lib\common.ps1')
Start-Verification -Activity 4 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -EvidenceDir $EvidenceDir -DryRun:$DryRun
$base=@('-Project',$Project)
foreach ($pair in @(@{Name='-DbName';Value=$DbName},@{Name='-DbHost';Value=$DbHost},@{Name='-DbPort';Value=$DbPort},@{Name='-AdminUser';Value=$AdminUser},@{Name='-AppUser';Value=$AppUser},@{Name='-ReadonlyUser';Value=$ReadonlyUser},@{Name='-ConfigPath';Value=$ConfigPath},@{Name='-EvidenceDir';Value=$EvidenceDir})) { if (-not [string]::IsNullOrWhiteSpace($pair.Value)) { $base+=@($pair.Name,$pair.Value) } }
if ($DryRun) { $base+= '-DryRun' }; if ($Execute) { $base+= '-Execute' }; if ($LoadEnv) { $base+= '-LoadEnv' }
$common=@('run-activity4.ps1','run-activity5.ps1','run-activity6.ps1')
$per=@{}
if (-not [string]::IsNullOrWhiteSpace($MaintenanceTable)) { $per['run-activity5.ps1']=@('-MaintenanceTable',$MaintenanceTable) }
if (-not [string]::IsNullOrWhiteSpace($SqlFile)) { $per['run-activity5.ps1']+=@('-SqlFile',$SqlFile) }
if (-not [string]::IsNullOrWhiteSpace($QueryUser)) { $per['run-activity5.ps1']+=@('-QueryUser',$QueryUser) }
foreach ($arg in @(@{Name='-BackupDir';Value=$BackupDir},@{Name='-BackupFile';Value=$BackupFile},@{Name='-RestoreDbName';Value=$RestoreDbName},@{Name='-RecoveryDbName';Value=$RecoveryDbName},@{Name='-AllowedSqlFile';Value=$AllowedSqlFile},@{Name='-DeniedSqlFile';Value=$DeniedSqlFile},@{Name='-SelectSqlFile';Value=$SelectSqlFile},@{Name='-RPO';Value=$RPO})) { if (-not [string]::IsNullOrWhiteSpace($arg.Value)) { $per['run-activity6.ps1']+=@($arg.Name,$arg.Value) } }
if ($Confirm) { $per['run-activity6.ps1']+= '-Confirm' }
Invoke-VerificationBatch -Scripts $common -BaseArguments $base -PerScriptArguments $per
exit (Complete-Verification)
