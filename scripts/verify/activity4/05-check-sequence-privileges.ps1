# Purpose: Verify sequence usage/select needs for app and readonly accounts.
# Activity/Part: Activity 4 / Part C-D.
# Required account: Configured Activity 4 maintenance account with catalog visibility.
# Safety notes: Read-only privilege query; requires -Execute, or use -DryRun to preview.
# Expected result: App has configured sequence privileges; readonly has none unless explicitly planned.
[CmdletBinding()]
param([string]$Project='group-01',[string]$DbName,[string]$DbHost,[string]$DbPort,[string]$AdminUser,[string]$AppUser,[string]$ReadonlyUser,[string]$ConfigPath,[string]$EvidenceDir,[switch]$DryRun,[switch]$Execute,[switch]$LoadEnv)
. (Join-Path $PSScriptRoot '..\lib\common.ps1')
$ctx=Initialize-ConfiguredCheck -Activity 4 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -ConfigPath $ConfigPath -EvidenceDir $EvidenceDir -DbName $DbName -DbHost $DbHost -DbPort $DbPort -AdminUser $AdminUser -AppUser $AppUser -ReadonlyUser $ReadonlyUser -RequiredFields @('dbName','appUser','readonlyUser','sequencePrivileges') -LoadEnv:$LoadEnv -DryRun:$DryRun
if (-not $ctx.Ready) { exit (Complete-Verification) }
$cfg=$ctx.Config
$sqls=@()
foreach ($item in $cfg.sequencePrivileges) {
    $sequence=Quote-QualifiedIdentifier ([string]$item.sequence)
    foreach ($privilege in @('USAGE','SELECT','UPDATE')) {
        $sqls+= "SELECT " + (ConvertTo-SqlLiteral ([string]$item.sequence)) + " || '|' || " + (ConvertTo-SqlLiteral $privilege) + " || '|' || has_sequence_privilege(" + (ConvertTo-SqlLiteral ([string]$cfg.appUser)) + "," + (ConvertTo-SqlLiteral $sequence) + "," + (ConvertTo-SqlLiteral $privilege) + ") || '|' || has_sequence_privilege(" + (ConvertTo-SqlLiteral ([string]$cfg.readonlyUser)) + "," + (ConvertTo-SqlLiteral $sequence) + "," + (ConvertTo-SqlLiteral $privilege) + ");"
    }
}
$sql=$sqls -join "`n"
if ($DryRun) { Write-Output $sql; Write-Check SKIP 'sequence privileges' 'Dry run; no database connection.'; exit (Complete-Verification) }
if (-not $Execute) { Write-Check BLOCKED 'sequence privileges' 'Pass -DryRun or -Execute.'; exit (Complete-Verification) }
if ($sqls.Count -eq 0) { Write-Check BLOCKED 'sequence privileges' 'No target sequences configured.'; exit (Complete-Verification) }
$result=Invoke-ProjectPsql $cfg $cfg.dbName $cfg.adminUser $sql -TupleOnly
Write-ResultOutput $result
if ($result.ExitCode -ne 0) { Write-Check BLOCKED 'sequence privileges' 'Privilege query failed.'; exit (Complete-Verification) }
foreach ($item in $cfg.sequencePrivileges) {
    foreach ($privilege in @('USAGE','SELECT','UPDATE')) {
        $line=$result.Output | Where-Object { $_ -like ([string]$item.sequence + '|' + $privilege + '|*') } | Select-Object -First 1
        if ($null -eq $line) { Write-Check BLOCKED ([string]$item.sequence + ' ' + $privilege) 'Result missing.'; continue }
        $c=$line.Split('|')
        $appExpected=@($item.appPrivileges) -contains $privilege
        $roExpected=@($item.readonlyPrivileges) -contains $privilege
        if (($c[2] -eq 't') -eq $appExpected) { Write-Check PASS ('app sequence ' + $privilege) ([string]$item.sequence) } else { Write-Check FAIL ('app sequence ' + $privilege) 'Differs from configured plan.' }
        if (($c[3] -eq 't') -eq $roExpected) { Write-Check PASS ('readonly sequence ' + $privilege) ([string]$item.sequence) } else { Write-Check FAIL ('readonly sequence ' + $privilege) 'Differs from configured plan.' }
    }
}
exit (Complete-Verification)
