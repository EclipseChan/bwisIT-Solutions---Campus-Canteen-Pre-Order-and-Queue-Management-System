# Purpose: Detect tracked data-bearing dumps/backups and backup directories.
# Activity/Part: Activity 6 / Part F.
# Required account: Git access to this repository.
# Safety notes: Read-only `git ls-files`; no database or backup file is opened.
# Expected result: No tracked *.dump, *.backup, *.sql.gz, or backups/ paths.
[CmdletBinding()]
param([string]$Project='group-01',[string]$EvidenceDir,[switch]$DryRun,[switch]$Execute)
. (Join-Path $PSScriptRoot '..\lib\common.ps1')
Start-Verification -Activity 6 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -EvidenceDir $EvidenceDir -DryRun:$DryRun
$root=Get-RepoRoot
if ($DryRun) { Write-Output 'git ls-files'; Write-Output 'Filter for *.dump, *.backup, *.sql.gz, backups/'; Write-Check SKIP 'tracked backup scan' 'Dry run; no git command executed.'; exit (Complete-Verification) }
if (-not $Execute) { Write-Check BLOCKED 'tracked backup scan' 'Pass -DryRun or -Execute.'; exit (Complete-Verification) }
if (-not (Get-Command 'git' -ErrorAction SilentlyContinue)) { Write-Check BLOCKED 'git availability' 'Install Git or run from a system with git on PATH.'; exit (Complete-Verification) }
$tracked=@(& git -C $root ls-files 2>&1 | ForEach-Object { [string]$_ }); $code=$LASTEXITCODE
if ($code -ne 0) { Write-ResultOutput ([pscustomobject]@{Output=$tracked;ExitCode=$code}); Write-Check BLOCKED 'tracked backup scan' 'git ls-files failed.'; exit (Complete-Verification) }
$matches=@($tracked | Where-Object { $_ -match '(?i)(^|/)(backups?/|dumps?/)|\.(dump|backup|sql\.gz|pgdump|bak)$' })
if ($matches.Count -eq 0) { Write-Check PASS 'tracked backup scan' 'No configured data-bearing backup patterns are tracked.' }
else { $matches | ForEach-Object { Write-Output ('TRACKED: '+$_) }; Write-Check FAIL 'tracked backup scan' ($matches.Count.ToString()+' matching tracked path(s) found; remove from submission and ensure backups are protected outside Git.') }
exit (Complete-Verification)
