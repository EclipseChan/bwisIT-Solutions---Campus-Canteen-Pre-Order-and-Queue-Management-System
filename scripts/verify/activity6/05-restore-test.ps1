# Purpose: Create an isolated restore-test database and restore a verified custom archive.
# Activity/Part: Activity 6 / Part C.
# Required account: Instructor-approved setup/maintenance account with CREATEDB and restore privileges.
# Safety notes: Requires both -Execute and -Confirm; target must be a new *_a6_restore_* DB distinct from source.
# Expected result: Empty test DB is created and restore output/warnings are recorded; original DB is untouched.
[CmdletBinding()]
param([string]$Project='group-01',[string]$DbName,[string]$DbHost,[string]$DbPort,[string]$AdminUser,[string]$ConfigPath,[string]$EvidenceDir,[string]$BackupFile,[string]$RestoreDbName,[switch]$DryRun,[switch]$Execute,[switch]$Confirm,[switch]$LoadEnv)
. (Join-Path $PSScriptRoot '..\lib\common.ps1')
$ctx=Initialize-ConfiguredCheck -Activity 6 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -ConfigPath $ConfigPath -EvidenceDir $EvidenceDir -DbName $DbName -DbHost $DbHost -DbPort $DbPort -AdminUser $AdminUser -RequiredFields @('dbName','adminUser') -LoadEnv:$LoadEnv -DryRun:$DryRun
if (-not $ctx.Ready) { exit (Complete-Verification) }
if ([string]::IsNullOrWhiteSpace($RestoreDbName)) { Write-Check BLOCKED 'restore target' 'Supply a distinct -RestoreDbName ending in _a6_restore_<date>.'; exit (Complete-Verification) }
if ($RestoreDbName -eq [string]$ctx.Config.dbName -or $RestoreDbName -notmatch '^[A-Za-z0-9_]+_a6_restore_[0-9]{8}$') { Write-Check BLOCKED 'restore target safety' 'Target must be a distinct identifier matching <name>_a6_restore_YYYYMMDD; original database is never a valid target.'; exit (Complete-Verification) }
$create="CREATE DATABASE " + (ConvertTo-SqlIdentifier $RestoreDbName) + ' OWNER ' + (ConvertTo-SqlIdentifier ([string]$ctx.Config.adminUser)) + ' TEMPLATE template0;'
if ($DryRun) { Write-Output $create; Write-Output ('pg_restore -w -h <DB_HOST> -p <DB_PORT> -U <SETUP_ACCOUNT> -d ' + $RestoreDbName + ' <protected backup>'); Write-Check SKIP 'restore test' 'Dry run; no database created or restored.'; exit (Complete-Verification) }
if ([string]::IsNullOrWhiteSpace($BackupFile) -or -not (Test-Path -LiteralPath $BackupFile -PathType Leaf)) { Write-Check BLOCKED 'restore source' 'Supply an existing verified protected -BackupFile.'; exit (Complete-Verification) }
$full=[IO.Path]::GetFullPath($BackupFile); $root=(Get-RepoRoot).TrimEnd('\')+'\'
if ($full.StartsWith($root,[StringComparison]::OrdinalIgnoreCase)) { Write-Check BLOCKED 'restore source safety' 'Move data-bearing backup outside repository.'; exit (Complete-Verification) }
if (-not $Execute -or -not $Confirm) { Write-Check BLOCKED 'restore test' 'Requires both -Execute and -Confirm. If CREATEDB is unavailable, request instructor/setup account to create the empty test database.'; exit (Complete-Verification) }
if (-not (Get-Command 'pg_restore' -ErrorAction SilentlyContinue)) { Write-Check BLOCKED 'pg_restore availability' 'Install/use the approved PostgreSQL client tools and ensure pg_restore is on PATH.'; exit (Complete-Verification) }
$canCreate=Invoke-ProjectPsql $ctx.Config 'postgres' $ctx.Config.adminUser ("SELECT rolcreatedb FROM pg_roles WHERE rolname=" + (ConvertTo-SqlLiteral ([string]$ctx.Config.adminUser)) + ';') -TupleOnly
if ($canCreate.ExitCode -ne 0 -or @($canCreate.Output | Where-Object { $_ -eq 't' }).Count -eq 0) { Write-Check BLOCKED 'CREATEDB permission' 'Configured account cannot create a test database. Request an instructor-approved setup account to create a new empty restore database owned by the configured maintenance account; do not grant broad privileges merely for the test.'; exit (Complete-Verification) }
$exists=Invoke-ProjectPsql $ctx.Config 'postgres' $ctx.Config.adminUser ("SELECT 1 FROM pg_database WHERE datname=" + (ConvertTo-SqlLiteral $RestoreDbName) + ';') -TupleOnly
if ($exists.ExitCode -ne 0) { Write-Check BLOCKED 'restore target check' 'Could not verify target database existence.'; exit (Complete-Verification) }
if (@($exists.Output | Where-Object { $_ -eq '1' }).Count -gt 0) { Write-Check BLOCKED 'restore target check' 'Target already exists; choose a fresh name. The script will not replace or clean it.'; exit (Complete-Verification) }
Write-Output ('Creating separate target: ' + $RestoreDbName)
$createResult=Invoke-ProjectPsql $ctx.Config 'postgres' $ctx.Config.adminUser $create
Write-ResultOutput $createResult
if ($createResult.ExitCode -ne 0) { Write-Check FAIL 'create restore database' 'CREATE DATABASE failed.'; exit (Complete-Verification) }
$hostName=[string](Get-ConfigProperty $ctx.Config 'dbHost'); if ([string]::IsNullOrWhiteSpace($hostName)) { $hostName='localhost' }; $port=[string](Get-ConfigProperty $ctx.Config 'dbPort'); if ([string]::IsNullOrWhiteSpace($port)) { $port='5432' }
$restoreArgs=@('-w','-h',$hostName,'-p',$port,'-U',[string]$ctx.Config.adminUser,'-d',$RestoreDbName,$full)
Write-Output ('Command: pg_restore -w -h ' + $hostName + ' -p ' + $port + ' -U ' + $ctx.Config.adminUser + ' -d ' + $RestoreDbName + ' <protected backup>')
try { $restore=@(& pg_restore @restoreArgs 2>&1 | ForEach-Object { [string]$_ }); $restoreCode=$LASTEXITCODE }
catch { $restore=@($_.Exception.Message); $restoreCode=127 }
Write-ResultOutput ([pscustomobject]@{Output=$restore;ExitCode=$restoreCode})
$record=@("Restore database: $RestoreDbName","Backup file: $([IO.Path]::GetFileName($full))","Restore timestamp: $((Get-Date).ToString('o'))","Restore exit code: $restoreCode","Restore output: $($restore -join ' ')")
$evidence=Join-Path (Join-Path (Get-RepoRoot) 'db-backup-recovery') (Join-Path $Project 'restore-evidence.txt')
Add-Content -LiteralPath $evidence -Value ("`r`n" + ($record -join "`r`n")) -Encoding UTF8
$record | ForEach-Object { Write-Output $_ }
if ($restoreCode -eq 0) { Write-Check PASS 'restore test' ('Restore completed in separate database ' + $RestoreDbName) }
else { Write-Check FAIL 'restore test' ('Restore exited ' + $restoreCode + '; investigate output. Test database was left intact for inspection.') }
exit (Complete-Verification)
