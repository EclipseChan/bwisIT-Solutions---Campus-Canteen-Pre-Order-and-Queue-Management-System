# Purpose: Create a PostgreSQL custom-format logical backup and record non-secret metadata.
# Activity/Part: Activity 6 / Part B.
# Required account: Configured Activity 4 maintenance/backup account, not the application runtime account.
# Safety notes: Requires -Execute and a protected absolute -BackupDir outside the repository; no password argument.
# Expected result: pg_dump succeeds; dump, size, SHA-256, versions, account, time, and errors are recorded.
[CmdletBinding()]
param([string]$Project='group-01',[string]$DbName,[string]$DbHost,[string]$DbPort,[string]$AdminUser,[string]$AppUser,[string]$ConfigPath,[string]$EvidenceDir,[string]$BackupDir,[switch]$DryRun,[switch]$Execute,[switch]$LoadEnv)
. (Join-Path $PSScriptRoot '..\lib\common.ps1')
$ctx=Initialize-ConfiguredCheck -Activity 6 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -ConfigPath $ConfigPath -EvidenceDir $EvidenceDir -DbName $DbName -DbHost $DbHost -DbPort $DbPort -AdminUser $AdminUser -AppUser $AppUser -RequiredFields @('dbName','adminUser','appUser') -LoadEnv:$LoadEnv -DryRun:$DryRun
if (-not $ctx.Ready) { exit (Complete-Verification) }
if ([string]::IsNullOrWhiteSpace($BackupDir)) { Write-Check BLOCKED 'backup path' 'Supply -BackupDir as a protected absolute directory outside the repository.'; exit (Complete-Verification) }
if (-not [IO.Path]::IsPathRooted($BackupDir)) { Write-Check BLOCKED 'backup path' 'BackupDir must be an absolute path.'; exit (Complete-Verification) }
$root=Get-RepoRoot; $backupFull=[IO.Path]::GetFullPath($BackupDir).TrimEnd('\'); $prefix=$root.TrimEnd('\')+'\'
if ($backupFull.Equals($root.TrimEnd('\'),[StringComparison]::OrdinalIgnoreCase) -or $backupFull.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)) { Write-Check BLOCKED 'backup path' 'Data-bearing dumps must be outside this repository.'; exit (Complete-Verification) }
$command="pg_dump -w -h <DB_HOST> -p <DB_PORT> -U <A4_BACKUP_ACCOUNT> -Fc -d <DATABASE_NAME> -f <PROTECTED_PATH>"
if ($DryRun) { Write-Output $command; Write-Check SKIP 'custom-format backup' 'Dry run; no directory or dump created.'; exit (Complete-Verification) }
if (-not $Execute) { Write-Check BLOCKED 'custom-format backup' 'Pass -DryRun or -Execute.'; exit (Complete-Verification) }
if ($ctx.Config.adminUser -eq $ctx.Config.appUser) { Write-Check FAIL 'backup account' 'Application runtime account is not permitted for backup.'; exit (Complete-Verification) }
if (-not (Get-Command 'pg_dump' -ErrorAction SilentlyContinue)) { Write-Check BLOCKED 'pg_dump availability' 'Install/use the approved PostgreSQL client tools and ensure pg_dump is on PATH.'; exit (Complete-Verification) }
New-Item -ItemType Directory -Force -Path $backupFull | Out-Null
$stamp=Get-Date -Format 'yyyyMMdd-HHmmss'; $safeDb=[string]$ctx.Config.dbName -replace '[^A-Za-z0-9_.-]','_'
$dump=Join-Path $backupFull ($safeDb+'_activity6_'+$stamp+'.dump')
$hostName=[string](Get-ConfigProperty $ctx.Config 'dbHost'); if ([string]::IsNullOrWhiteSpace($hostName)) { $hostName='localhost' }
$port=[string](Get-ConfigProperty $ctx.Config 'dbPort'); if ([string]::IsNullOrWhiteSpace($port)) { $port='5432' }
$arguments=@('-w','-h',$hostName,'-p',$port,'-U',[string]$ctx.Config.adminUser,'-Fc','-d',[string]$ctx.Config.dbName,'-f',$dump)
Write-Output ('Command: pg_dump -w -h ' + $hostName + ' -p ' + $port + ' -U ' + $ctx.Config.adminUser + ' -Fc -d ' + $ctx.Config.dbName + ' -f <protected dump path>')
try { $out=@(& pg_dump @arguments 2>&1 | ForEach-Object { [string]$_ }); $code=$LASTEXITCODE }
catch { $out=@($_.Exception.Message); $code=127 }
Write-ResultOutput ([pscustomobject]@{Output=$out;ExitCode=$code})
if ($code -ne 0) {
    Add-Content -LiteralPath (Join-Path (Join-Path (Get-RepoRoot) 'db-backup-recovery') (Join-Path $Project 'checksums.txt')) -Value ("`r`nBackup attempt: $((Get-Date).ToString('o'))`r`nFile: $([IO.Path]::GetFileName($dump))`r`nExit code: $code`r`nError: $($out -join ' ')") -Encoding UTF8
    Write-Check FAIL 'pg_dump' ('pg_dump exited with code ' + $code + '; any partial file is not a valid backup. Error captured in checksums.txt.')
    exit (Complete-Verification)
}
$item=Get-Item -LiteralPath $dump; $hash=Get-FileHash -LiteralPath $dump -Algorithm SHA256
$version=@(& pg_dump --version 2>&1 | ForEach-Object { [string]$_ })
$server=Invoke-ProjectPsql $ctx.Config $ctx.Config.dbName $ctx.Config.adminUser 'SELECT version();'
$record=@("Project: $Project","Database: $($ctx.Config.dbName)","File: $($item.Name)","Protected path: $backupFull","Size bytes: $($item.Length)","SHA256: $($hash.Hash)","Timestamp: $((Get-Date).ToString('o'))","Backup account: $($ctx.Config.adminUser)","pg_dump version: $($version -join ' ')","Server version: $($server.Output -join ' ')","Command exit code: $code","pg_dump output: $($out -join ' ')")
$metadata=Join-Path (Join-Path (Get-RepoRoot) 'db-backup-recovery') (Join-Path $Project 'checksums.txt')
Add-Content -LiteralPath $metadata -Value ("`r`n" + ($record -join "`r`n")) -Encoding UTF8
$record | ForEach-Object { Write-Output $_ }
Write-Check PASS 'pg_dump custom archive' 'Protected dump created and non-secret metadata appended to checksums.txt.'
exit (Complete-Verification)
