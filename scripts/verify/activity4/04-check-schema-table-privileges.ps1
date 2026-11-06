# Purpose: Verify schema USAGE and configured table privileges for app/read-only roles.
# Activity/Part: Activity 4 / Part C-D.
# Required account: Configured Activity 4 maintenance account with catalog visibility.
# Safety notes: Read-only privilege query; requires -Execute, or use -DryRun to preview.
# Expected result: Configured app DML works; read-only has SELECT and no write privileges.
[CmdletBinding()]
param([string]$Project='group-01',[string]$DbName,[string]$DbHost,[string]$DbPort,[string]$AdminUser,[string]$AppUser,[string]$ReadonlyUser,[string]$ConfigPath,[string]$EvidenceDir,[switch]$DryRun,[switch]$Execute,[switch]$LoadEnv)
. (Join-Path $PSScriptRoot '..\lib\common.ps1')
$ctx=Initialize-ConfiguredCheck -Activity 4 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -ConfigPath $ConfigPath -EvidenceDir $EvidenceDir -DbName $DbName -DbHost $DbHost -DbPort $DbPort -AdminUser $AdminUser -AppUser $AppUser -ReadonlyUser $ReadonlyUser -RequiredFields @('dbName','schemaName','appUser','readonlyUser','tablePrivileges') -LoadEnv:$LoadEnv -DryRun:$DryRun
if (-not $ctx.Ready) { exit (Complete-Verification) }
$cfg=$ctx.Config
$sqls=@("SELECT 'schema|' || has_schema_privilege(" + (ConvertTo-SqlLiteral ([string]$cfg.appUser)) + "," + (ConvertTo-SqlLiteral ([string]$cfg.schemaName)) + ",'USAGE') || '|' || has_schema_privilege(" + (ConvertTo-SqlLiteral ([string]$cfg.readonlyUser)) + "," + (ConvertTo-SqlLiteral ([string]$cfg.schemaName)) + ",'USAGE');")
foreach ($item in $cfg.tablePrivileges) {
    $table=Quote-QualifiedIdentifier ([string]$item.table)
    foreach ($privilege in @('SELECT','INSERT','UPDATE','DELETE')) {
        $sqls+= "SELECT " + (ConvertTo-SqlLiteral ([string]$item.table)) + " || '|' || " + (ConvertTo-SqlLiteral $privilege) + " || '|' || has_table_privilege(" + (ConvertTo-SqlLiteral ([string]$cfg.appUser)) + "," + (ConvertTo-SqlLiteral $table) + "," + (ConvertTo-SqlLiteral $privilege) + ") || '|' || has_table_privilege(" + (ConvertTo-SqlLiteral ([string]$cfg.readonlyUser)) + "," + (ConvertTo-SqlLiteral $table) + "," + (ConvertTo-SqlLiteral $privilege) + ");"
    }
}
$sql=$sqls -join "`n"
if ($DryRun) { Write-Output $sql; Write-Check SKIP 'schema/table privileges' 'Dry run; no database connection.'; exit (Complete-Verification) }
if (-not $Execute) { Write-Check BLOCKED 'schema/table privileges' 'Pass -DryRun or -Execute.'; exit (Complete-Verification) }
$result=Invoke-ProjectPsql $cfg $cfg.dbName $cfg.adminUser $sql -TupleOnly
Write-ResultOutput $result
if ($result.ExitCode -ne 0) { Write-Check BLOCKED 'schema/table privileges' 'Privilege inspection failed.'; exit (Complete-Verification) }
$rows=@($result.Output | Where-Object { $_ -match '\|' })
if ($rows.Count -eq 0) { Write-Check BLOCKED 'schema/table privileges' 'No results returned.' }
else {
    $schema=$rows[0].Split('|')
    if ($schema[1] -eq 't') { Write-Check PASS 'app schema USAGE' ([string]$cfg.schemaName) } else { Write-Check FAIL 'app schema USAGE' 'Missing required USAGE.' }
    if ($schema[2] -eq 't') { Write-Check PASS 'readonly schema USAGE' ([string]$cfg.schemaName) } else { Write-Check FAIL 'readonly schema USAGE' 'Missing required USAGE.' }
}
foreach ($item in $cfg.tablePrivileges) {
    $tableName=[string]$item.table
    foreach ($privilege in @('SELECT','INSERT','UPDATE','DELETE')) {
        $line=$rows | Where-Object { $_ -like ($tableName + '|' + $privilege + '|*') } | Select-Object -First 1
        if ($null -eq $line) { Write-Check BLOCKED ($tableName + ' ' + $privilege) 'Result missing.'; continue }
        $columns=$line.Split('|'); $appExpected=@($item.appPrivileges) -contains $privilege; $roExpected=(@($item.readonlyPrivileges) -contains $privilege)
        if (($columns[2] -eq 't') -eq $appExpected) { Write-Check PASS ('app ' + $tableName + ' ' + $privilege) 'Matches configured privilege plan.' } else { Write-Check FAIL ('app ' + $tableName + ' ' + $privilege) 'Differs from configured plan.' }
        if (($columns[3] -eq 't') -eq $roExpected) { Write-Check PASS ('readonly ' + $tableName + ' ' + $privilege) 'Matches configured privilege plan.' } else { Write-Check FAIL ('readonly ' + $tableName + ' ' + $privilege) 'Differs from configured plan.' }
    }
}
exit (Complete-Verification)
