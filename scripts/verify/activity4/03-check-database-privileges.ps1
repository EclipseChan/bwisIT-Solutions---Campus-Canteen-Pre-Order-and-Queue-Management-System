# Purpose: Check intended CONNECT, forbidden unrelated CONNECT, and CREATE database privileges.
# Activity/Part: Activity 4 / Part C-D.
# Required account: Configured Activity 4 maintenance account; target roles are checked by name.
# Safety notes: Read-only privilege query; requires -Execute, or use -DryRun to preview.
# Expected result: App/readonly CONNECT only as configured, CREATE denied, unrelated access denied.
[CmdletBinding()]
param([string]$Project='group-01',[string]$DbName,[string]$DbHost,[string]$DbPort,[string]$AdminUser,[string]$AppUser,[string]$ReadonlyUser,[string]$ConfigPath,[string]$EvidenceDir,[switch]$DryRun,[switch]$Execute,[switch]$LoadEnv)
. (Join-Path $PSScriptRoot '..\lib\common.ps1')
$ctx=Initialize-ConfiguredCheck -Activity 4 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -ConfigPath $ConfigPath -EvidenceDir $EvidenceDir -DbName $DbName -DbHost $DbHost -DbPort $DbPort -AdminUser $AdminUser -AppUser $AppUser -ReadonlyUser $ReadonlyUser -RequiredFields @('dbName','appUser','readonlyUser','unrelatedDatabases') -LoadEnv:$LoadEnv -DryRun:$DryRun
if (-not $ctx.Ready) { exit (Complete-Verification) }
$cfg=$ctx.Config
$roles=@([string]$cfg.appUser,[string]$cfg.readonlyUser)
$checks=@()
foreach ($role in $roles) {
    $checks+= "SELECT " + (ConvertTo-SqlLiteral $role) + " AS role, " + (ConvertTo-SqlLiteral ([string]$cfg.dbName)) + " AS database_name, has_database_privilege(" + (ConvertTo-SqlLiteral $role) + "," + (ConvertTo-SqlLiteral ([string]$cfg.dbName)) + ",'CONNECT'), has_database_privilege(" + (ConvertTo-SqlLiteral $role) + "," + (ConvertTo-SqlLiteral ([string]$cfg.dbName)) + ",'CREATE');"
    foreach ($otherDb in $cfg.unrelatedDatabases) { $checks+= "SELECT " + (ConvertTo-SqlLiteral $role) + "," + (ConvertTo-SqlLiteral ([string]$otherDb)) + ",has_database_privilege(" + (ConvertTo-SqlLiteral $role) + "," + (ConvertTo-SqlLiteral ([string]$otherDb)) + ",'CONNECT');" }
}
$sql=$checks -join "`n"
if ($DryRun) { Write-Output $sql; Write-Check SKIP 'database privileges' 'Dry run; no database connection.'; exit (Complete-Verification) }
if (-not $Execute) { Write-Check BLOCKED 'database privileges' 'Pass -DryRun or -Execute.'; exit (Complete-Verification) }
$result=Invoke-ProjectPsql $cfg 'postgres' $cfg.adminUser $sql -TupleOnly
Write-ResultOutput $result
if ($result.ExitCode -ne 0) { Write-Check BLOCKED 'database privileges' 'Could not connect to maintenance database or inspect privileges.'; exit (Complete-Verification) }
$rows=@($result.Output | Where-Object { $_ -match '\|' })
foreach ($role in $roles) {
    $line=$rows | Where-Object { $_ -match ('^' + [regex]::Escape($role) + '\|') -and $_ -match ([regex]::Escape([string]$cfg.dbName)) } | Select-Object -First 1
    if ($null -eq $line) { Write-Check BLOCKED ('privileges for ' + $role) 'Expected result row missing.'; continue }
    $cols=$line.Split('|')
    if ($cols[2] -eq 't') { Write-Check PASS ($role + ' CONNECT target DB') 'CONNECT is allowed as intended.' } else { Write-Check FAIL ($role + ' CONNECT target DB') 'Expected CONNECT privilege.' }
    if ($cols[3] -eq 'f') { Write-Check PASS ($role + ' CREATE target DB') 'CREATE is denied.' } else { Write-Check FAIL ($role + ' CREATE target DB') 'Unexpected CREATE privilege.' }
}
foreach ($otherDb in $cfg.unrelatedDatabases) {
    foreach ($role in $roles) {
        $line=$rows | Where-Object { $_ -match ('^' + [regex]::Escape($role) + '\|' + [regex]::Escape([string]$otherDb) + '\|') } | Select-Object -First 1
        if ($null -eq $line) { Write-Check BLOCKED ($role + ' unrelated DB ' + $otherDb) 'Privilege result missing.' }
        elseif ($line.Split('|')[-1] -eq 'f') { Write-Check PASS ($role + ' unrelated DB ' + $otherDb) 'CONNECT is denied.' }
        else { Write-Check FAIL ($role + ' unrelated DB ' + $otherDb) 'Unexpected CONNECT privilege.' }
    }
}
if (@($cfg.unrelatedDatabases).Count -eq 0) { Write-Check BLOCKED 'unrelated database access' 'No unrelatedDatabases configured; add authorized test database names, not guessed names.' }
exit (Complete-Verification)
