# Purpose: Inspect PUBLIC database CONNECT, schema, and table privileges.
# Activity/Part: Activity 4 / Part C-D.
# Required account: Configured Activity 4 maintenance account with catalog visibility.
# Safety notes: Read-only query; expected PUBLIC CONNECT policy must be explicit in config.
# Expected result: PUBLIC is restricted as configured with no unintended schema/table grants.
[CmdletBinding()]
param([string]$Project='group-01',[string]$DbName,[string]$DbHost,[string]$DbPort,[string]$AdminUser,[string]$AppUser,[string]$ReadonlyUser,[string]$ConfigPath,[string]$EvidenceDir,[switch]$DryRun,[switch]$Execute,[switch]$LoadEnv)
. (Join-Path $PSScriptRoot '..\lib\common.ps1')
$ctx=Initialize-ConfiguredCheck -Activity 4 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -ConfigPath $ConfigPath -EvidenceDir $EvidenceDir -DbName $DbName -DbHost $DbHost -DbPort $DbPort -AdminUser $AdminUser -AppUser $AppUser -ReadonlyUser $ReadonlyUser -RequiredFields @('dbName','schemaName','restrictPublicConnect') -LoadEnv:$LoadEnv -DryRun:$DryRun
if (-not $ctx.Ready) { exit (Complete-Verification) }
$cfg=$ctx.Config
$sql="SELECT 'db|' || datname || '|' || COALESCE(bool_or(x.privilege_type='CONNECT'),false) FROM pg_database d LEFT JOIN LATERAL aclexplode(COALESCE(d.datacl,acldefault('d',d.datdba))) x ON x.grantee=0 WHERE datname=" + (ConvertTo-SqlLiteral ([string]$cfg.dbName)) + ' GROUP BY datname;'
$sql+="`nSELECT 'schema|' || nspname || '|' || COALESCE(string_agg(x.privilege_type,','), '') FROM pg_namespace n LEFT JOIN LATERAL aclexplode(COALESCE(n.nspacl,acldefault('n',n.nspowner))) x ON x.grantee=0 WHERE nspname=" + (ConvertTo-SqlLiteral ([string]$cfg.schemaName)) + ' GROUP BY nspname;'
$sql+="`nSELECT 'table|' || schemaname || '.' || tablename || '|' || COALESCE(string_agg(x.privilege_type,','), '') FROM pg_tables t LEFT JOIN LATERAL aclexplode(COALESCE((SELECT c.relacl FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname=t.schemaname AND c.relname=t.tablename),acldefault('r',(SELECT c.relowner FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname=t.schemaname AND c.relname=t.tablename)))) x ON x.grantee=0 WHERE schemaname=" + (ConvertTo-SqlLiteral ([string]$cfg.schemaName)) + ' GROUP BY schemaname,tablename;'
if ($DryRun) { Write-Output $sql; Write-Check SKIP 'PUBLIC restrictions' 'Dry run; no database connection.'; exit (Complete-Verification) }
if (-not $Execute) { Write-Check BLOCKED 'PUBLIC restrictions' 'Pass -DryRun or -Execute.'; exit (Complete-Verification) }
$result=Invoke-ProjectPsql $cfg $cfg.dbName $cfg.adminUser $sql -TupleOnly
Write-ResultOutput $result
if ($result.ExitCode -ne 0) { Write-Check BLOCKED 'PUBLIC restrictions' 'Could not inspect PUBLIC ACLs.'; exit (Complete-Verification) }
$dbLine=$result.Output | Where-Object { $_ -like 'db|*' } | Select-Object -First 1
if ($null -eq $dbLine) { Write-Check BLOCKED 'PUBLIC CONNECT' 'Database ACL result missing.' }
else {
    $hasConnect=($dbLine.Split('|')[-1] -eq 'true')
    if ([bool]$cfg.restrictPublicConnect -and -not $hasConnect) { Write-Check PASS 'PUBLIC CONNECT' 'Revoked as configured.' }
    elseif (-not [bool]$cfg.restrictPublicConnect -and $hasConnect) { Write-Check PASS 'PUBLIC CONNECT' 'Allowed as configured.' }
    else { Write-Check FAIL 'PUBLIC CONNECT' 'Effective PUBLIC CONNECT differs from configured policy.' }
}
$unexpected=@($result.Output | Where-Object { $_ -match '^(schema|table)\|.*\|.*(CREATE|INSERT|UPDATE|DELETE|TRUNCATE|REFERENCES|TRIGGER)' })
if ($unexpected.Count -eq 0) { Write-Check PASS 'PUBLIC schema/table write grants' 'No PUBLIC schema/table write privileges found in inspected schema.' }
else { $unexpected | ForEach-Object { Write-Output $_ }; Write-Check FAIL 'PUBLIC schema/table write grants' 'Unexpected write privileges found; review before changing.' }
exit (Complete-Verification)
