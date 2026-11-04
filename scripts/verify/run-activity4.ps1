# Purpose: Run all Activity 4 access-control checks for one project.
# Activity/Part: Activity 4 / all automated parts.
# Required account: Configured Activity 4 maintenance, runtime, and read-only accounts.
# Safety notes: No database operation occurs without -Execute; -DryRun previews all checks.
# Expected result: Each check reports PASS/FAIL/SKIP/BLOCKED and a final summary is printed.
[CmdletBinding()]
param([string]$Project='group-01',[string]$DbName,[string]$DbHost,[string]$DbPort,[string]$AdminUser,[string]$AppUser,[string]$ReadonlyUser,[string]$ConfigPath,[string]$EvidenceDir,[switch]$DryRun,[switch]$Execute,[switch]$LoadEnv)
. (Join-Path $PSScriptRoot 'lib\common.ps1')
Start-Verification -Activity 4 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -EvidenceDir $EvidenceDir -DryRun:$DryRun
$base=@('-Project',$Project)
foreach ($pair in @(@{Name='-DbName';Value=$DbName},@{Name='-DbHost';Value=$DbHost},@{Name='-DbPort';Value=$DbPort},@{Name='-AdminUser';Value=$AdminUser},@{Name='-AppUser';Value=$AppUser},@{Name='-ReadonlyUser';Value=$ReadonlyUser},@{Name='-ConfigPath';Value=$ConfigPath},@{Name='-EvidenceDir';Value=$EvidenceDir})) { if (-not [string]::IsNullOrWhiteSpace($pair.Value)) { $base+=@($pair.Name,$pair.Value) } }
if ($DryRun) { $base+= '-DryRun' }; if ($Execute) { $base+= '-Execute' }; if ($LoadEnv) { $base+= '-LoadEnv' }
$scripts=@('activity4\01-check-roles.ps1','activity4\02-check-memberships.ps1','activity4\03-check-database-privileges.ps1','activity4\04-check-schema-table-privileges.ps1','activity4\05-check-sequence-privileges.ps1','activity4\06-check-default-privileges.ps1','activity4\07-check-public-restrictions.ps1','activity4\08-run-allowed-denied-tests.ps1')
Invoke-VerificationBatch -Scripts $scripts -BaseArguments $base
exit (Complete-Verification)
