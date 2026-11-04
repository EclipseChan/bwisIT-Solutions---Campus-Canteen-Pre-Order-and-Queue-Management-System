# Purpose: Run all Activity 5 maintenance and monitoring checks for one project.
# Activity/Part: Activity 5 / all automated parts.
# Required account: Configured Activity 4 maintenance/read-only accounts as appropriate.
# Safety notes: Maintenance and query actions require -Execute; -DryRun previews without database operations.
# Expected result: Each check reports PASS/FAIL/SKIP/BLOCKED and a final summary is printed.
[CmdletBinding()]
param([string]$Project='group-01',[string]$DbName,[string]$DbHost,[string]$DbPort,[string]$AdminUser,[string]$AppUser,[string]$ReadonlyUser,[string]$ConfigPath,[string]$EvidenceDir,[string]$MaintenanceTable,[string]$SqlFile,[string]$QueryUser,[switch]$DryRun,[switch]$Execute,[switch]$LoadEnv)
. (Join-Path $PSScriptRoot 'lib\common.ps1')
Start-Verification -Activity 5 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -EvidenceDir $EvidenceDir -DryRun:$DryRun
$base=@('-Project',$Project)
foreach ($pair in @(@{Name='-DbName';Value=$DbName},@{Name='-DbHost';Value=$DbHost},@{Name='-DbPort';Value=$DbPort},@{Name='-AdminUser';Value=$AdminUser},@{Name='-AppUser';Value=$AppUser},@{Name='-ReadonlyUser';Value=$ReadonlyUser},@{Name='-ConfigPath';Value=$ConfigPath},@{Name='-EvidenceDir';Value=$EvidenceDir})) { if (-not [string]::IsNullOrWhiteSpace($pair.Value)) { $base+=@($pair.Name,$pair.Value) } }
if ($DryRun) { $base+= '-DryRun' }; if ($Execute) { $base+= '-Execute' }; if ($LoadEnv) { $base+= '-LoadEnv' }
$per=@{}
if (-not [string]::IsNullOrWhiteSpace($MaintenanceTable)) { $per['05-maintenance-check.ps1']=@('-Table',$MaintenanceTable) }
if (-not [string]::IsNullOrWhiteSpace($SqlFile)) { $per['06-query-plan.ps1']=@('-SqlFile',$SqlFile) }
if (-not [string]::IsNullOrWhiteSpace($QueryUser)) { $per['06-query-plan.ps1']+=@('-QueryUser',$QueryUser) }
$scripts=@('activity5\01-health-check.ps1','activity5\02-activity-check.ps1','activity5\03-role-check.ps1','activity5\04-log-check.ps1','activity5\05-maintenance-check.ps1','activity5\06-query-plan.ps1')
Invoke-VerificationBatch -Scripts $scripts -BaseArguments $base -PerScriptArguments $per
exit (Complete-Verification)
