# Purpose: Delete one unique disposable marker row only from a restored test DB, restore archive to a fresh DB, and compare.
# Activity/Part: Activity 6 / Part D.
# Required account: Instructor-approved setup/maintenance account; marker row must already exist in the verified backup.
# Safety notes: Requires -Execute and -Confirm, a *_a6_restore_* target, unique marker row, and fresh recovery database. Never targets original DB.
# Expected result: Marker row is removed only from restored test DB, recovered from archive into fresh DB, and exact row JSON matches.
[CmdletBinding()]
param([string]$Project='group-01',[string]$DbName,[string]$DbHost,[string]$DbPort,[string]$AdminUser,[string]$ConfigPath,[string]$EvidenceDir,[string]$BackupFile,[string]$RestoreDbName,[string]$RecoveryDbName,[string]$RPO,[switch]$DryRun,[switch]$Execute,[switch]$Confirm,[switch]$LoadEnv)
. (Join-Path $PSScriptRoot '..\lib\common.ps1')
$ctx=Initialize-ConfiguredCheck -Activity 6 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -ConfigPath $ConfigPath -EvidenceDir $EvidenceDir -DbName $DbName -DbHost $DbHost -DbPort $DbPort -AdminUser $AdminUser -RequiredFields @('dbName','adminUser','recoveryTest') -LoadEnv:$LoadEnv -DryRun:$DryRun
if (-not $ctx.Ready) { exit (Complete-Verification) }
if ([string]::IsNullOrWhiteSpace($RestoreDbName) -or $RestoreDbName -eq [string]$ctx.Config.dbName -or $RestoreDbName -notmatch '^[A-Za-z0-9_]+_a6_restore_[0-9]{8}$') { Write-Check BLOCKED 'recovery source database' 'Use only the distinct restored test database matching *_a6_restore_YYYYMMDD.'; exit (Complete-Verification) }
if ([string]::IsNullOrWhiteSpace($RecoveryDbName)) { $RecoveryDbName=$RestoreDbName -replace '_a6_restore_','_a6_recovery_' }
if ($RecoveryDbName -eq [string]$ctx.Config.dbName -or $RecoveryDbName -eq $RestoreDbName -or $RecoveryDbName -notmatch '^[A-Za-z0-9_]+_a6_recovery_[0-9]{8}$') { Write-Check BLOCKED 'recovery target safety' 'Recovery database must be a fresh distinct *_a6_recovery_YYYYMMDD database.'; exit (Complete-Verification) }
$test=$ctx.Config.recoveryTest
foreach ($field in @('table','markerColumn','markerValue')) { $value=Get-ConfigProperty $test $field; if ([string]::IsNullOrWhiteSpace([string]$value) -or [string]$value -match '^<.*>$') { Write-Check BLOCKED 'disposable marker configuration' ('Configure recoveryTest.'+$field+' using a clearly disposable unique test row.'); exit (Complete-Verification) } }
try {
    $qualified=Quote-QualifiedIdentifier ([string]$test.table)
    if ($qualified -notmatch '^\w+\.\w+$') { throw 'Table must include schema and table name.' }
    $markerColumn=ConvertTo-SqlIdentifier ([string]$test.markerColumn)
} catch { Write-Check BLOCKED 'recovery marker identifiers' 'Use verified simple identifiers and a schema-qualified table.'; exit (Complete-Verification) }
$marker=ConvertTo-SqlLiteral ([string]$test.markerValue)
$select="SELECT row_to_json(t)::text FROM (SELECT * FROM $qualified WHERE $markerColumn=$marker) t;"
$countSql="SELECT count(*) FROM $qualified WHERE $markerColumn=$marker;"
$delete="DELETE FROM $qualified WHERE $markerColumn=$marker;"
if ($DryRun) { Write-Output ('Source restored test DB: '+$RestoreDbName); Write-Output ('Recovery target: '+$RecoveryDbName); Write-Output $select; Write-Output $delete; Write-Output ('RPO context: '+$RPO); Write-Check SKIP 'recovery simulation' 'Dry run; no records changed and no database created.'; exit (Complete-Verification) }
if (-not $Execute -or -not $Confirm) { Write-Check BLOCKED 'recovery simulation' 'Requires both -Execute and -Confirm after verifying the marker row is disposable and included in the backup.'; exit (Complete-Verification) }
if ([string]::IsNullOrWhiteSpace($BackupFile) -or -not (Test-Path -LiteralPath $BackupFile -PathType Leaf)) { Write-Check BLOCKED 'recovery backup' 'Supply the verified protected -BackupFile.'; exit (Complete-Verification) }
if (-not (Get-Command 'pg_restore' -ErrorAction SilentlyContinue)) { Write-Check BLOCKED 'pg_restore availability' 'Install/use the approved PostgreSQL client tools and ensure pg_restore is on PATH; no marker will be changed.'; exit (Complete-Verification) }
$backupFull=[IO.Path]::GetFullPath($BackupFile); $repoPrefix=(Get-RepoRoot).TrimEnd('\')+'\'
if ($backupFull.StartsWith($repoPrefix,[StringComparison]::OrdinalIgnoreCase)) { Write-Check BLOCKED 'recovery backup path' 'Data-bearing backup must remain outside repository.'; exit (Complete-Verification) }
$canCreate=Invoke-ProjectPsql $ctx.Config 'postgres' $ctx.Config.adminUser ("SELECT rolcreatedb FROM pg_roles WHERE rolname="+(ConvertTo-SqlLiteral ([string]$ctx.Config.adminUser))+';') -TupleOnly
if ($canCreate.ExitCode -ne 0 -or @($canCreate.Output | Where-Object { $_ -eq 't' }).Count -eq 0) { Write-Check BLOCKED 'CREATEDB permission' 'Configured account cannot create the fresh recovery database. Request an instructor/setup account before deleting the test marker; no marker was changed.'; exit (Complete-Verification) }
$exists=Invoke-ProjectPsql $ctx.Config 'postgres' $ctx.Config.adminUser ("SELECT 1 FROM pg_database WHERE datname="+(ConvertTo-SqlLiteral $RecoveryDbName)+';') -TupleOnly
if ($exists.ExitCode -ne 0) { Write-Check BLOCKED 'recovery database existence' 'Could not check target.'; exit (Complete-Verification) }
if (@($exists.Output | Where-Object { $_ -eq '1' }).Count -gt 0) { Write-Check BLOCKED 'recovery database existence' 'Target already exists; choose a fresh name. No existing database will be modified.'; exit (Complete-Verification) }
$archiveList=@(& pg_restore --list $backupFull 2>&1); $archiveCode=$LASTEXITCODE
if ($archiveCode -ne 0 -or @($archiveList).Count -eq 0) { Write-Check BLOCKED 'recovery archive preflight' 'Archive could not be listed; no marker will be changed.'; exit (Complete-Verification) }
Write-Output ('Archive TOC entries verified: '+@($archiveList).Count)
$beforeCount=Invoke-ProjectPsql $ctx.Config $RestoreDbName $ctx.Config.adminUser $countSql -TupleOnly
if ($beforeCount.ExitCode -ne 0 -or @($beforeCount.Output | Where-Object { $_ -eq '1' }).Count -ne 1) { Write-Check BLOCKED 'disposable marker precondition' 'Expected exactly one marker row in restored test DB. Add/verify one unique disposable row before backup; original database must remain untouched.'; exit (Complete-Verification) }
$before=Invoke-ProjectPsql $ctx.Config $RestoreDbName $ctx.Config.adminUser $select -TupleOnly
if ($before.ExitCode -ne 0 -or $before.Output.Count -ne 1) { Write-Check BLOCKED 'record before state' 'Could not capture exactly one marker row.'; exit (Complete-Verification) }
$beforeJson=[string]$before.Output[0]
$sha=[Security.Cryptography.SHA256]::Create()
$beforeHash=[BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($beforeJson))).Replace('-','').ToLowerInvariant()
$sha.Dispose()
Write-Output ('Before-state SHA256: '+$beforeHash)
Write-Check PASS 'record before state' 'Unique marker row captured as SHA-256; row values are not written to evidence.'
$create="CREATE DATABASE "+(ConvertTo-SqlIdentifier $RecoveryDbName)+' OWNER '+(ConvertTo-SqlIdentifier ([string]$ctx.Config.adminUser))+' TEMPLATE template0;'
$createResult=Invoke-ProjectPsql $ctx.Config 'postgres' $ctx.Config.adminUser $create
Write-ResultOutput $createResult
if ($createResult.ExitCode -ne 0) { Write-Check BLOCKED 'fresh recovery database' 'Creation failed; request instructor-approved setup account. No marker was changed.'; exit (Complete-Verification) }
$deleteResult=Invoke-ProjectPsql $ctx.Config $RestoreDbName $ctx.Config.adminUser $delete
Write-ResultOutput $deleteResult
if ($deleteResult.ExitCode -ne 0) { Write-Check FAIL 'simulated loss' 'DELETE failed in restored test database.'; exit (Complete-Verification) }
$afterCount=Invoke-ProjectPsql $ctx.Config $RestoreDbName $ctx.Config.adminUser $countSql -TupleOnly
Write-Output ('After-loss marker count: '+($afterCount.Output -join ''))
if ($afterCount.ExitCode -eq 0 -and @($afterCount.Output | Where-Object { $_ -eq '0' }).Count -gt 0) { Write-Check PASS 'simulated loss' 'Disposable marker row absent from restored test database.' } else { Write-Check FAIL 'simulated loss verification' 'Marker row still exists or count verification failed.'; exit (Complete-Verification) }
$hostName=[string](Get-ConfigProperty $ctx.Config 'dbHost'); if ([string]::IsNullOrWhiteSpace($hostName)) { $hostName='localhost' }; $port=[string](Get-ConfigProperty $ctx.Config 'dbPort'); if ([string]::IsNullOrWhiteSpace($port)) { $port='5432' }
$restoreArgs=@('-w','-h',$hostName,'-p',$port,'-U',[string]$ctx.Config.adminUser,'-d',$RecoveryDbName,$backupFull)
try { $restore=@(& pg_restore @restoreArgs 2>&1 | ForEach-Object { [string]$_ }); $restoreCode=$LASTEXITCODE }
catch { $restore=@($_.Exception.Message); $restoreCode=127 }
Write-ResultOutput ([pscustomobject]@{Output=$restore;ExitCode=$restoreCode})
if ($restoreCode -ne 0) { Write-Check FAIL 'recovery restore' ('pg_restore exited '+$restoreCode+'; fresh recovery database left intact.'); exit (Complete-Verification) }
$recovered=Invoke-ProjectPsql $ctx.Config $RecoveryDbName $ctx.Config.adminUser $select -TupleOnly
$recoveredHash=''
if ($recovered.ExitCode -eq 0 -and $recovered.Output.Count -eq 1) {
    $sha=[Security.Cryptography.SHA256]::Create()
    $recoveredHash=[BitConverter]::ToString($sha.ComputeHash([Text.Encoding]::UTF8.GetBytes([string]$recovered.Output[0]))).Replace('-','').ToLowerInvariant()
    $sha.Dispose()
}
if ($recovered.ExitCode -eq 0 -and $recovered.Output.Count -eq 1 -and $recoveredHash -ceq $beforeHash) {
    Write-Output ('Recovered-state SHA256: '+$recoveredHash)
    Write-Check PASS 'recovery comparison' 'Recovered row exactly matches recorded before-state.'
} else {
    Write-Output ('Before-state SHA256: '+$beforeHash)
    Write-Output ('Recovered-state SHA256: '+$recoveredHash)
    Write-Check FAIL 'recovery comparison' 'Recovered row missing or differs from before-state.'
}
if ([string]::IsNullOrWhiteSpace($RPO)) { Write-Check BLOCKED 'RPO implications' 'Record the project RPO and explain possible data loss since the backup.' }
else { Write-Check PASS 'RPO implications' ('RPO recorded for report: '+$RPO+'; explain schedule/data loss in recovery-simulation.md.') }
$record=@("Restore test database (mutated disposable row only): $RestoreDbName","Fresh recovery database: $RecoveryDbName","Backup file: $([IO.Path]::GetFileName($backupFull))","Disposable table: $($test.table)","Marker column: $($test.markerColumn)","Marker value: <redacted from evidence>","Before-state SHA256: $beforeHash","Recovered-state SHA256: $recoveredHash","Delete exit code: $($deleteResult.ExitCode)","Restore exit code: $restoreCode","RPO: $RPO","Original database target: Not used")
$evidence=Join-Path (Join-Path (Get-RepoRoot) 'db-backup-recovery') (Join-Path $Project 'recovery-simulation.md')
Add-Content -LiteralPath $evidence -Value ("`r`n## Executed simulation metadata`r`n" + ($record -join "`r`n")) -Encoding UTF8
exit (Complete-Verification)
