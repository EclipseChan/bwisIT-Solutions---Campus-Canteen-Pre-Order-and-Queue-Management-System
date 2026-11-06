# Purpose: Compare configured login-to-group memberships with PostgreSQL memberships.
# Activity/Part: Activity 4 / Part C.
# Required account: Configured Activity 4 maintenance account with catalog visibility.
# Safety notes: Read-only query; requires -Execute, or use -DryRun to preview.
# Expected result: Intended memberships exist and no unexpected configured-role memberships appear.
[CmdletBinding()]
param([string]$Project='group-01',[string]$DbName,[string]$DbHost,[string]$DbPort,[string]$AdminUser,[string]$AppUser,[string]$ReadonlyUser,[string]$ConfigPath,[string]$EvidenceDir,[switch]$DryRun,[switch]$Execute,[switch]$LoadEnv)
. (Join-Path $PSScriptRoot '..\lib\common.ps1')
$ctx=Initialize-ConfiguredCheck -Activity 4 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -ConfigPath $ConfigPath -EvidenceDir $EvidenceDir -DbName $DbName -DbHost $DbHost -DbPort $DbPort -AdminUser $AdminUser -AppUser $AppUser -ReadonlyUser $ReadonlyUser -RequiredFields @('dbName','memberships','loginRoles','groupRoles') -LoadEnv:$LoadEnv -DryRun:$DryRun
if (-not $ctx.Ready) { exit (Complete-Verification) }
$cfg=$ctx.Config
$sql='SELECT member.rolname, parent.rolname FROM pg_auth_members m JOIN pg_roles member ON member.oid=m.member JOIN pg_roles parent ON parent.oid=m.roleid ORDER BY 1,2;'
if ($DryRun) { Write-Output $sql; Write-Check SKIP 'role memberships' 'Dry run; no database connection.'; exit (Complete-Verification) }
if (-not $Execute) { Write-Check BLOCKED 'role memberships' 'Pass -DryRun to preview or -Execute to query PostgreSQL.'; exit (Complete-Verification) }
$result=Invoke-ProjectPsql $cfg $cfg.dbName $cfg.adminUser $sql -TupleOnly
Write-ResultOutput $result
if ($result.ExitCode -ne 0) { Write-Check BLOCKED 'role memberships' 'Could not inspect memberships.'; exit (Complete-Verification) }
$actual=@($result.Output | Where-Object { $_ -match '\|' })
$knownLogins=@($cfg.loginRoles | ForEach-Object { [string]$_.name })
$knownGroups=@($cfg.groupRoles | ForEach-Object { [string]$_.name })
foreach ($membership in $cfg.memberships) {
    $expected=([string]$membership.member + '|' + [string]$membership.role)
    if ($actual -contains $expected) { Write-Check PASS ('membership ' + $expected) 'Intended membership present.' } else { Write-Check FAIL ('membership ' + $expected) 'Intended membership is missing.' }
}
foreach ($line in $actual) {
    $parts=$line.Split('|')
    if (($knownLogins -contains $parts[0]) -and ($knownGroups -contains $parts[1])) {
        $allowed=@($cfg.memberships | ForEach-Object { [string]$_.member + '|' + [string]$_.role })
        if ($allowed -notcontains $line) { Write-Check FAIL ('unexpected membership ' + $line) 'Known login is assigned to an unplanned group role.' }
    }
}
Write-Output 'Membership comparison limited to configured login/group role pairs.'
exit (Complete-Verification)
