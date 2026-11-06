# Purpose: Verify configured group/login role existence and restrictive attributes.
# Activity/Part: Activity 4 / Part C-D.
# Required account: Configured Activity 4 maintenance account with catalog visibility.
# Safety notes: Read-only catalog query; requires -Execute, or use -DryRun to preview.
# Expected result: Group roles are NOLOGIN; login roles exist; app/readonly roles are unprivileged.
[CmdletBinding()]
param([string]$Project='group-01',[string]$DbName,[string]$DbHost,[string]$DbPort,[string]$AdminUser,[string]$AppUser,[string]$ReadonlyUser,[string]$ConfigPath,[string]$EvidenceDir,[switch]$DryRun,[switch]$Execute,[switch]$LoadEnv)
. (Join-Path $PSScriptRoot '..\lib\common.ps1')
$ctx=Initialize-ConfiguredCheck -Activity 4 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -ConfigPath $ConfigPath -EvidenceDir $EvidenceDir -DbName $DbName -DbHost $DbHost -DbPort $DbPort -AdminUser $AdminUser -AppUser $AppUser -ReadonlyUser $ReadonlyUser -RequiredFields @('dbName','adminUser','appUser','readonlyUser','groupRoles','loginRoles') -LoadEnv:$LoadEnv -DryRun:$DryRun
if (-not $ctx.Ready) { exit (Complete-Verification) }
$cfg=$ctx.Config
$sql="SELECT rolname, rolsuper, rolcreatedb, rolcreaterole, rolcanlogin, rolreplication, rolbypassrls FROM pg_roles WHERE rolname IN (" + ((@($cfg.groupRoles | ForEach-Object { ConvertTo-SqlLiteral ([string]$_.name) }) + @($cfg.loginRoles | ForEach-Object { ConvertTo-SqlLiteral ([string]$_.name) })) -join ',') + ') ORDER BY rolname;'
if ($DryRun) { Write-Output $sql; Write-Check SKIP 'role attributes' 'Dry run; no database connection.'; exit (Complete-Verification) }
if (-not $Execute) { Write-Check BLOCKED 'role attributes' 'Pass -DryRun to preview or -Execute to query PostgreSQL.'; exit (Complete-Verification) }
$result=Invoke-ProjectPsql $cfg $cfg.dbName $cfg.adminUser $sql -TupleOnly
Write-ResultOutput $result
if ($result.ExitCode -ne 0) { Write-Check BLOCKED 'role attributes' 'Catalog query failed or account lacks visibility.'; exit (Complete-Verification) }
$rows=@($result.Output | Where-Object { $_ -match '\|' })
foreach ($groupRole in $cfg.groupRoles) {
    $row=$rows | Where-Object { $_.Split('|')[0] -eq [string]$groupRole.name } | Select-Object -First 1
    if ($null -eq $row) { Write-Check FAIL ('group role ' + $groupRole.name) 'Role does not exist.'; continue }
    $columns=$row.Split('|')
    if ($columns[5] -eq 'f') { Write-Check PASS ('group role ' + $groupRole.name) 'Exists and NOLOGIN.' } else { Write-Check FAIL ('group role ' + $groupRole.name) 'Expected NOLOGIN.' }
}
foreach ($loginRole in $cfg.loginRoles) {
    $row=$rows | Where-Object { $_.Split('|')[0] -eq [string]$loginRole.name } | Select-Object -First 1
    if ($null -eq $row) { Write-Check FAIL ('login role ' + $loginRole.name) 'Role does not exist.'; continue }
    $columns=$row.Split('|')
    if ($columns[4] -ne 't') { Write-Check FAIL ('login role ' + $loginRole.name) 'Expected LOGIN.'; continue }
    $restricted=$loginRole.name -eq [string]$cfg.appUser -or $loginRole.name -eq [string]$cfg.readonlyUser
    if ($restricted -and ($columns[1] -eq 't' -or $columns[2] -eq 't' -or $columns[3] -eq 't' -or $columns[5] -eq 't' -or $columns[6] -eq 't')) {
        Write-Check FAIL ('login role ' + $loginRole.name) 'Unexpected elevated role attribute.'
    } else { Write-Check PASS ('login role ' + $loginRole.name) 'Exists with LOGIN and expected attributes.' }
}
exit (Complete-Verification)
