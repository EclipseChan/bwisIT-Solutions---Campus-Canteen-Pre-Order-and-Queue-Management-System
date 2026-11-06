# Purpose: Compute SHA-256 and file metadata for an existing protected backup.
# Activity/Part: Activity 6 / Part B.
# Required account: None.
# Safety notes: Read-only file operation; backup must be outside the repository.
# Expected result: Filename, size, SHA-256, and timestamp are appended to checksums.txt.
[CmdletBinding()]
param([string]$Project='group-01',[string]$BackupFile,[string]$EvidenceDir,[switch]$DryRun,[switch]$Execute)
. (Join-Path $PSScriptRoot '..\lib\common.ps1')
Start-Verification -Activity 6 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -EvidenceDir $EvidenceDir -DryRun:$DryRun
if ([string]::IsNullOrWhiteSpace($BackupFile) -or -not (Test-Path -LiteralPath $BackupFile -PathType Leaf)) { Write-Check BLOCKED 'backup checksum' 'Supply an existing protected -BackupFile.'; exit (Complete-Verification) }
$full=[IO.Path]::GetFullPath($BackupFile); $root=(Get-RepoRoot).TrimEnd('\')+'\'
if ($full.StartsWith($root,[StringComparison]::OrdinalIgnoreCase)) { Write-Check BLOCKED 'backup checksum' 'Backup file is inside the repository; move it to protected storage outside Git.'; exit (Complete-Verification) }
if ($DryRun) { Write-Output ('Get-FileHash -LiteralPath <protected backup> -Algorithm SHA256'); Write-Check SKIP 'backup checksum' 'Dry run; no file read.'; exit (Complete-Verification) }
if (-not $Execute) { Write-Check BLOCKED 'backup checksum' 'Pass -DryRun or -Execute.'; exit (Complete-Verification) }
$file=Get-Item -LiteralPath $full; $hash=Get-FileHash -LiteralPath $full -Algorithm SHA256
$record=@("File: $($file.Name)","Size bytes: $($file.Length)","SHA256: $($hash.Hash)","Timestamp: $((Get-Date).ToString('o'))")
$target=Join-Path (Join-Path (Get-RepoRoot) 'db-backup-recovery') (Join-Path $Project 'checksums.txt')
Add-Content -LiteralPath $target -Value ("`r`n" + ($record -join "`r`n")) -Encoding UTF8
$record | ForEach-Object { Write-Output $_ }
Write-Check PASS 'backup checksum' 'SHA-256 and file metadata appended to checksums.txt.'
exit (Complete-Verification)
