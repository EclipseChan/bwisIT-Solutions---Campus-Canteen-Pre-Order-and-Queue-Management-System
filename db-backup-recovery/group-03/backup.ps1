# TEMPLATE ONLY — no backup has been created.
# Configure PGHOST, PGPORT, PGDATABASE, PGUSER and BACKUP_DIR in this local
# PowerShell session after confirming the target and authorization. Do not put
# passwords in this file or command line. Use approved .pgpass or prompt-based
# credential handling; this script never prints credential values.
$ErrorActionPreference = 'Stop'

$required = @('PGHOST', 'PGPORT', 'PGDATABASE', 'PGUSER', 'BACKUP_DIR')
foreach ($name in $required) {
    if ([string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($name))) {
        throw "Required environment variable $name is not set."
    }
}
if (-not [IO.Path]::IsPathRooted($env:BACKUP_DIR)) {
    throw 'BACKUP_DIR must be an absolute path outside this repository.'
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path.TrimEnd('\')
$backupRoot = [IO.Path]::GetFullPath($env:BACKUP_DIR).TrimEnd('\')
$repoPrefix = $repoRoot + '\'
if ($backupRoot.Equals($repoRoot, [StringComparison]::OrdinalIgnoreCase) -or
    $backupRoot.StartsWith($repoPrefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'BACKUP_DIR must be outside this repository.'
}

New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$safeDatabaseName = $env:PGDATABASE -replace '[^A-Za-z0-9_.-]', '_'
$dumpPath = Join-Path $backupRoot ($safeDatabaseName + '_activity6_' + $stamp + '.dump')
$pgDumpArgs = @(
    '--host', $env:PGHOST,
    '--port', $env:PGPORT,
    '--username', $env:PGUSER,
    '--dbname', $env:PGDATABASE,
    '--format=custom',
    '--file', $dumpPath
)

& pg_dump @pgDumpArgs
if ($LASTEXITCODE -ne 0) {
    throw "pg_dump failed with exit code $LASTEXITCODE. Do not treat a partial file as a valid backup."
}

$file = Get-Item -LiteralPath $dumpPath
$hash = Get-FileHash -LiteralPath $dumpPath -Algorithm SHA256
Write-Output ("Backup created: {0}; bytes={1}; SHA256={2}; local_time={3}" -f `
    $file.Name, $file.Length, $hash.Hash, (Get-Date -Format o))
Write-Output 'Keep this data-bearing dump outside Git and the submission ZIP.'
