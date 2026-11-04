# Purpose: Inspect a custom-format PostgreSQL archive with pg_restore --list.
# Activity/Part: Activity 6 / Part B.
# Required account: None.
# Safety notes: Read-only archive operation; backup must be outside the repository.
# Expected result: Non-empty archive TOC listing is saved under the project folder and timestamped evidence.
[CmdletBinding()]
param([string]$Project='group-01',[string]$BackupFile,[string]$EvidenceDir,[switch]$DryRun,[switch]$Execute)
. (Join-Path $PSScriptRoot '..\lib\common.ps1')
Start-Verification -Activity 6 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -EvidenceDir $EvidenceDir -DryRun:$DryRun
if ([string]::IsNullOrWhiteSpace($BackupFile) -or -not (Test-Path -LiteralPath $BackupFile -PathType Leaf)) { Write-Check BLOCKED 'archive listing' 'Supply an existing protected -BackupFile.'; exit (Complete-Verification) }
$full=[IO.Path]::GetFullPath($BackupFile); $root=(Get-RepoRoot).TrimEnd('\')+'\'
if ($full.StartsWith($root,[StringComparison]::OrdinalIgnoreCase)) { Write-Check BLOCKED 'archive listing' 'Data-bearing backup must be outside the repository.'; exit (Complete-Verification) }
if ($DryRun) { Write-Output 'pg_restore --list <protected backup path>'; Write-Check SKIP 'archive listing' 'Dry run; archive was not read.'; exit (Complete-Verification) }
if (-not $Execute) { Write-Check BLOCKED 'archive listing' 'Pass -DryRun or -Execute.'; exit (Complete-Verification) }
if (-not (Get-Command 'pg_restore' -ErrorAction SilentlyContinue)) { Write-Check BLOCKED 'pg_restore availability' 'Install/use the approved PostgreSQL client tools and ensure pg_restore is on PATH.'; exit (Complete-Verification) }
try { $output=@(& pg_restore --list $full 2>&1 | ForEach-Object { [string]$_ }); $code=$LASTEXITCODE }
catch { $output=@($_.Exception.Message); $code=127 }
Write-ResultOutput ([pscustomobject]@{Output=$output;ExitCode=$code})
if ($code -ne 0 -or $output.Count -eq 0) { Write-Check FAIL 'pg_restore --list' ('Archive listing failed or was empty; exit code ' + $code); exit (Complete-Verification) }
$projectFile=Join-Path (Join-Path (Get-RepoRoot) 'db-backup-recovery') (Join-Path $Project 'archive-listing.txt')
Set-Content -LiteralPath $projectFile -Value $output -Encoding UTF8
Write-Check PASS 'pg_restore --list' ('Saved ' + $output.Count + ' TOC lines to project archive-listing.txt.')
exit (Complete-Verification)
