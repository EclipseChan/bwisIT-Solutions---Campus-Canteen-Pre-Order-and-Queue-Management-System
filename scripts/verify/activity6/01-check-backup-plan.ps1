# Purpose: Check that the per-project backup plan covers required topics and is not template-only.
# Activity/Part: Activity 6 / Part A.
# Required account: None.
# Safety notes: Reads a repository Markdown file only; no database actions.
# Expected result: Required plan topics have project-specific non-placeholder content.
[CmdletBinding()]
param([string]$Project='group-01',[string]$ConfigPath,[string]$EvidenceDir,[switch]$DryRun,[switch]$Execute)
. (Join-Path $PSScriptRoot '..\lib\common.ps1')
Start-Verification -Activity 6 -ScriptName $MyInvocation.MyCommand.Name -Project $Project -EvidenceDir $EvidenceDir -DryRun:$DryRun
$path=Join-Path (Join-Path (Get-RepoRoot) 'db-backup-recovery') (Join-Path $Project 'backup-plan.md')
if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { Write-Check BLOCKED 'backup plan' 'Per-project backup-plan.md is missing.'; exit (Complete-Verification) }
$content=Get-Content -LiteralPath $path -Raw
$topics=@(
    @{Name='database/objects';Pattern='(?im)^\s*(#{1,6}\s+.*database.*(object|schema)|[-*]\s+database\s+and\s+.*(object|schema))'},
    @{Name='method';Pattern='(?im)^\s*(#{1,6}\s+.*method|[-*]\s+method\s*:)'},
    @{Name='storage';Pattern='(?im)^\s*(#{1,6}\s+.*storage|[-*]\s+storage\s*:)'},
    @{Name='access';Pattern='(?im)^\s*(#{1,6}\s+.*access|[-*]\s+access\s*:)'},
    @{Name='verification';Pattern='(?im)^\s*(#{1,6}\s+.*verification|[-*]\s+verification\s*:)'},
    @{Name='schedule';Pattern='(?im)^\s*(#{1,6}\s+.*schedule|[-*]\s+schedule\s*:)'},
    @{Name='retention';Pattern='(?im)^\s*(#{1,6}\s+.*retention|[-*]\s+retention\s*:)'},
    @{Name='RPO';Pattern='(?im)^\s*(#{1,6}\s+.*RPO|[-*]\s+RPO\s*(and rationale)?\s*:)'},
    @{Name='RTO';Pattern='(?im)^\s*(#{1,6}\s+.*RTO|[-*]\s+RTO\s*(and rationale)?\s*:)'},
    @{Name='role recreation';Pattern='(?im)^\s*(#{1,6}\s+.*role recreation|[-*]\s+role recreation\s*:?)'}
)
$missing=@($topics | Where-Object { $content -notmatch $_.Pattern } | ForEach-Object { $_.Name })
if ($missing.Count -gt 0) { Write-Check FAIL 'backup plan sections' ('Missing topics: ' + ($missing -join ', ')) }
else { Write-Check PASS 'backup plan sections' 'All required topics are mentioned.' }
if ($content -match '<[^>]+>|TEMPLATE ONLY|<NOT_CREATED>|<NOT_RUN>') { Write-Check BLOCKED 'backup plan completion' 'Placeholders remain; replace with project-specific reviewed plan before execution.' }
else { Write-Check PASS 'backup plan completion' 'No obvious template markers remain; human review is still required.' }
exit (Complete-Verification)
