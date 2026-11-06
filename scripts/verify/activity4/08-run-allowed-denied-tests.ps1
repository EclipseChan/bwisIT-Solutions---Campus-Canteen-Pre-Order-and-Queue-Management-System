# Purpose: Run project-adapted Activity 4 allowed/denied SQL tests.
# Activity/Part: Activity 4 / Part E.
# Required account: The configured account for each named test.
# Safety notes: No SQL runs without -Execute; -DryRun previews file/account pairs. Inspect adapted SQL first.
# Expected result: Allowed tests succeed, denied tests fail as expected, and all results are captured.
[CmdletBinding()]
param([string]$Project='group-01',[string]$DbName,[string]$DbHost,[string]$DbPort,[string]$AdminUser,[string]$AppUser,[string]$ReadonlyUser,[string]$ConfigPath,[string]$EvidenceDir,[switch]$DryRun,[switch]$Execute,[switch]$LoadEnv)
. (Join-Path $PSScriptRoot '..\lib\common.ps1')
$ctx=Initialize-ConfiguredCheck -Activity 4 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -ConfigPath $ConfigPath -EvidenceDir $EvidenceDir -DbName $DbName -DbHost $DbHost -DbPort $DbPort -AdminUser $AdminUser -AppUser $AppUser -ReadonlyUser $ReadonlyUser -RequiredFields @('dbName','appUser','readonlyUser') -LoadEnv:$LoadEnv -DryRun:$DryRun
if (-not $ctx.Ready) { exit (Complete-Verification) }
$testDir=Join-Path (Join-Path (Get-RepoRoot) 'db-access-control') (Join-Path $Project 'tests')
$testMap=@(
    @{Name='runtime-allowed'; User=[string]$ctx.Config.appUser; File=(Join-Path $testDir 'runtime-allowed.sql'); Expected=0},
    @{Name='runtime-denied'; User=[string]$ctx.Config.appUser; File=(Join-Path $testDir 'runtime-denied.sql'); Expected=1},
    @{Name='readonly-allowed'; User=[string]$ctx.Config.readonlyUser; File=(Join-Path $testDir 'readonly-allowed.sql'); Expected=0},
    @{Name='readonly-denied'; User=[string]$ctx.Config.readonlyUser; File=(Join-Path $testDir 'readonly-denied.sql'); Expected=1}
)
if ($DryRun) { foreach ($item in $testMap) { Write-Output ('psql -w -v ON_ERROR_STOP=1 -P pager=off -U ' + $item.User + ' -d ' + $ctx.Config.dbName + ' -f ' + $item.File + ' ; expected exit ' + $item.Expected) }; Write-Check SKIP 'allowed/denied SQL tests' 'Dry run; no SQL executed.'; exit (Complete-Verification) }
if (-not $Execute) { Write-Check BLOCKED 'allowed/denied SQL tests' 'Pass -DryRun or -Execute after inspecting project-adapted SQL.'; exit (Complete-Verification) }
foreach ($item in $testMap) {
    if (-not (Test-Path -LiteralPath $item.File -PathType Leaf)) { Write-Check BLOCKED $item.Name 'Project-adapted SQL file is missing; copy/adapt approved Activity 4 test SQL under this project folder.'; continue }
    $result=Invoke-ProjectPsql $ctx.Config $ctx.Config.dbName $item.User $null $item.File
    Write-Output ('Test ' + $item.Name + ' account=' + $item.User + ' expected_exit=' + $item.Expected)
    Write-ResultOutput $result
    if ($result.ExitCode -eq $item.Expected) { Write-Check PASS $item.Name 'Exit code matched expected behavior; inspect output for the specific intended operation.' }
    else { Write-Check FAIL $item.Name ('Expected exit ' + $item.Expected + ', got ' + $result.ExitCode + '.') }
}
exit (Complete-Verification)
