# Purpose: Run all Activity 6 backup and recovery checks for one project.
# Activity/Part: Activity 6 / all automated parts.
# Required account: Configured backup/maintenance account; setup privileges may be needed for restore.
# Safety notes: Data actions require -Execute; restore/recovery additionally require -Confirm; targets must be disposable DBs.
# Expected result: Each check reports PASS/FAIL/SKIP/BLOCKED and a final summary is printed.
[CmdletBinding()]
param([string]$Project='group-01',[string]$DbName,[string]$DbHost,[string]$DbPort,[string]$AdminUser,[string]$AppUser,[string]$ReadonlyUser,[string]$ConfigPath,[string]$EvidenceDir,[string]$BackupDir,[string]$BackupFile,[string]$RestoreDbName,[string]$RecoveryDbName,[string]$AllowedSqlFile,[string]$DeniedSqlFile,[string]$SelectSqlFile,[string]$RPO,[switch]$DryRun,[switch]$Execute,[switch]$Confirm,[switch]$LoadEnv)
. (Join-Path $PSScriptRoot 'lib\common.ps1')
Start-Verification -Activity 6 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -EvidenceDir $EvidenceDir -DryRun:$DryRun
$base=@('-Project',$Project)
if (-not [string]::IsNullOrWhiteSpace($EvidenceDir)) { $base+=@('-EvidenceDir',$EvidenceDir) }
$dbArgs=@()
foreach ($pair in @(@{Name='-DbName';Value=$DbName},@{Name='-DbHost';Value=$DbHost},@{Name='-DbPort';Value=$DbPort},@{Name='-AdminUser';Value=$AdminUser},@{Name='-ConfigPath';Value=$ConfigPath})) { if (-not [string]::IsNullOrWhiteSpace($pair.Value)) { $dbArgs+=@($pair.Name,$pair.Value) } }
$modeArgs=@()
if ($DryRun) { $modeArgs+= '-DryRun' }; if ($Execute) { $modeArgs+= '-Execute' }
$loadEnvArgs=@(); if ($LoadEnv) { $loadEnvArgs+= '-LoadEnv' }
$per=@{}
$backupArgs=@($dbArgs)+@($loadEnvArgs)
if (-not [string]::IsNullOrWhiteSpace($AppUser)) { $backupArgs+=@('-AppUser',$AppUser) }
if (-not [string]::IsNullOrWhiteSpace($BackupDir)) { $backupArgs+=@('-BackupDir',$BackupDir) }
$per['02-create-backup.ps1']=$backupArgs
if (-not [string]::IsNullOrWhiteSpace($BackupFile)) {
    foreach ($scriptName in @('03-checksum.ps1','04-archive-list.ps1')) { $per[$scriptName]=@('-BackupFile',$BackupFile) }
}
$restoreArgs=@($dbArgs)+@($loadEnvArgs)
if (-not [string]::IsNullOrWhiteSpace($BackupFile)) { $restoreArgs+=@('-BackupFile',$BackupFile) }
if (-not [string]::IsNullOrWhiteSpace($RestoreDbName)) { $restoreArgs+=@('-RestoreDbName',$RestoreDbName) }
if ($Confirm) { $restoreArgs+= '-Confirm' }
$per['05-restore-test.ps1']=$restoreArgs
$verifyArgs=@($dbArgs)+@($loadEnvArgs)
if (-not [string]::IsNullOrWhiteSpace($AppUser)) { $verifyArgs+=@('-AppUser',$AppUser) }
if (-not [string]::IsNullOrWhiteSpace($ReadonlyUser)) { $verifyArgs+=@('-ReadonlyUser',$ReadonlyUser) }
if (-not [string]::IsNullOrWhiteSpace($RestoreDbName)) { $verifyArgs+=@('-RestoreDbName',$RestoreDbName) }
foreach ($pair in @(@{Name='-AllowedSqlFile';Value=$AllowedSqlFile},@{Name='-DeniedSqlFile';Value=$DeniedSqlFile},@{Name='-SelectSqlFile';Value=$SelectSqlFile})) { if (-not [string]::IsNullOrWhiteSpace($pair.Value)) { $verifyArgs+=@($pair.Name,$pair.Value) } }
$per['06-verify-restore.ps1']=$verifyArgs
$recoveryArgs=@($dbArgs)+@($loadEnvArgs)
if (-not [string]::IsNullOrWhiteSpace($BackupFile)) { $recoveryArgs+=@('-BackupFile',$BackupFile) }
if (-not [string]::IsNullOrWhiteSpace($RestoreDbName)) { $recoveryArgs+=@('-RestoreDbName',$RestoreDbName) }
if (-not [string]::IsNullOrWhiteSpace($RecoveryDbName)) { $recoveryArgs+=@('-RecoveryDbName',$RecoveryDbName) }
if (-not [string]::IsNullOrWhiteSpace($RPO)) { $recoveryArgs+=@('-RPO',$RPO) }
if ($Confirm) { $recoveryArgs+= '-Confirm' }
$per['07-recovery-simulation.ps1']=$recoveryArgs
$scripts=@('activity6\01-check-backup-plan.ps1','activity6\02-create-backup.ps1','activity6\03-checksum.ps1','activity6\04-archive-list.ps1','activity6\05-restore-test.ps1','activity6\06-verify-restore.ps1','activity6\07-recovery-simulation.ps1','activity6\08-check-no-dumps-committed.ps1')
Invoke-VerificationBatch -Scripts $scripts -BaseArguments (@($base)+@($modeArgs)) -PerScriptArguments $per
exit (Complete-Verification)
