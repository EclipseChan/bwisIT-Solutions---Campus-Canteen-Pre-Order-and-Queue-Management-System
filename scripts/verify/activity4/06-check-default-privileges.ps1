# Purpose: Detect default ACL grants to PUBLIC or configured application roles.
# Activity/Part: Activity 4 / Part C-D.
# Required account: Configured Activity 4 maintenance account with pg_default_acl visibility.
# Safety notes: Read-only catalog query; requires -Execute, or use -DryRun to preview.
# Expected result: No unplanned default grants exist for PUBLIC or app/readonly roles.
[CmdletBinding()]
param([string]$Project='group-01',[string]$DbName,[string]$DbHost,[string]$DbPort,[string]$AdminUser,[string]$AppUser,[string]$ReadonlyUser,[string]$ConfigPath,[string]$EvidenceDir,[switch]$DryRun,[switch]$Execute,[switch]$LoadEnv)
. (Join-Path $PSScriptRoot '..\lib\common.ps1')
$ctx=Initialize-ConfiguredCheck -Activity 4 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -ConfigPath $ConfigPath -EvidenceDir $EvidenceDir -DbName $DbName -DbHost $DbHost -DbPort $DbPort -AdminUser $AdminUser -AppUser $AppUser -ReadonlyUser $ReadonlyUser -RequiredFields @('dbName','appUser','readonlyUser') -LoadEnv:$LoadEnv -DryRun:$DryRun
if (-not $ctx.Ready) { exit (Complete-Verification) }
$cfg=$ctx.Config
$sql="SELECT defaclrole::regrole, defaclnamespace::regnamespace, defaclobjtype, x.grantee::regrole, x.privilege_type FROM pg_default_acl d CROSS JOIN LATERAL aclexplode(d.defaclacl) x WHERE x.grantee IN (0, (SELECT oid FROM pg_roles WHERE rolname IN (" + (ConvertTo-SqlLiteral ([string]$cfg.appUser)) + "," + (ConvertTo-SqlLiteral ([string]$cfg.readonlyUser)) + "))) ORDER BY 1,2,3,4,5;"
if ($DryRun) { Write-Output $sql; Write-Check SKIP 'default privileges' 'Dry run; no database connection.'; exit (Complete-Verification) }
if (-not $Execute) { Write-Check BLOCKED 'default privileges' 'Pass -DryRun or -Execute.'; exit (Complete-Verification) }
$result=Invoke-ProjectPsql $cfg $cfg.dbName $cfg.adminUser $sql -TupleOnly
Write-ResultOutput $result
if ($result.ExitCode -ne 0) { Write-Check BLOCKED 'default privileges' 'Could not inspect pg_default_acl.' }
elseif (@($result.Output | Where-Object { $_ -match '\|' }).Count -eq 0) { Write-Check PASS 'default privileges' 'No default ACL grants to PUBLIC or configured app/readonly logins.' }
else { Write-Check FAIL 'default privileges' 'Review the listed default ACL entries against the approved plan; unexpected grants were found.' }
exit (Complete-Verification)
