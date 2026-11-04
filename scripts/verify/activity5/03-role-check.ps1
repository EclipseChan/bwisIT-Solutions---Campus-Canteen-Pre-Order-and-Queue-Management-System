# Purpose: Compare expected Activity 4 logins and group roles with PostgreSQL catalog state.
# Activity/Part: Activity 5 / Part A.
# Required account: Configured Activity 4 read-only/auditor account where role visibility permits.
# Safety notes: Read-only catalog query; reports differences, never changes roles.
# Expected result: No configured role is missing; unexpected configured-scope roles are reported.
[CmdletBinding()]
param([string]$Project='group-01',[string]$DbName,[string]$DbHost,[string]$DbPort,[string]$AdminUser,[string]$AppUser,[string]$ReadonlyUser,[string]$ConfigPath,[string]$EvidenceDir,[switch]$DryRun,[switch]$Execute,[switch]$LoadEnv)
. (Join-Path $PSScriptRoot '..\lib\common.ps1')
$ctx=Initialize-ConfiguredCheck -Activity 5 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -ConfigPath $ConfigPath -EvidenceDir $EvidenceDir -DbName $DbName -DbHost $DbHost -DbPort $DbPort -AdminUser $AdminUser -AppUser $AppUser -ReadonlyUser $ReadonlyUser -RequiredFields @('dbName','loginRoles','groupRoles') -LoadEnv:$LoadEnv -DryRun:$DryRun
if (-not $ctx.Ready) { exit (Complete-Verification) }
$cfg=$ctx.Config
$names=@($cfg.loginRoles | ForEach-Object { ConvertTo-SqlLiteral ([string]$_.name) }) + @($cfg.groupRoles | ForEach-Object { ConvertTo-SqlLiteral ([string]$_.name) })
$sql='SELECT rolname,rolcanlogin FROM pg_roles WHERE rolname IN (' + ($names -join ',') + ') ORDER BY rolname;'
if ($DryRun) { Write-Output $sql; Write-Check SKIP 'Activity 4 roles' 'Dry run; no database connection.'; exit (Complete-Verification) }
if (-not $Execute) { Write-Check BLOCKED 'Activity 4 roles' 'Pass -DryRun or -Execute.'; exit (Complete-Verification) }
$result=Invoke-ProjectPsql $cfg $cfg.dbName $cfg.readonlyUser $sql -TupleOnly
Write-ResultOutput $result
if ($result.ExitCode -ne 0) { Write-Check BLOCKED 'Activity 4 roles' 'Role catalog visibility is limited.'; exit (Complete-Verification) }
$actual=@($result.Output | Where-Object { $_ -match '\|' })
foreach ($role in $cfg.loginRoles) {
    $match=$actual | Where-Object { $_.Split('|')[0] -eq [string]$role.name } | Select-Object -First 1
    if ($null -eq $match) { Write-Check FAIL ('missing login ' + $role.name) 'Expected Activity 4 login role was not found.' }
    elseif ($match.Split('|')[1] -eq 't') { Write-Check PASS ('login ' + $role.name) 'Present with LOGIN.' }
    else { Write-Check FAIL ('login ' + $role.name) 'Present but lacks LOGIN.' }
}
foreach ($role in $cfg.groupRoles) {
    $match=$actual | Where-Object { $_.Split('|')[0] -eq [string]$role.name } | Select-Object -First 1
    if ($null -eq $match) { Write-Check FAIL ('missing group ' + $role.name) 'Expected Activity 4 group role was not found.' }
    elseif ($match.Split('|')[1] -eq 'f') { Write-Check PASS ('group ' + $role.name) 'Present with NOLOGIN.' }
    else { Write-Check FAIL ('group ' + $role.name) 'Group role unexpectedly has LOGIN.' }
}
exit (Complete-Verification)
