# Purpose: Shared safe configuration, psql, check-output, and evidence helpers.
# Activity/Part: Activities 4-6 / shared.
# Required account: Supplied by local project configuration or explicit parameter.
# Safety notes: Never accepts or prints passwords; callers must opt in with -Execute.
# Expected result: Consistent check lines, evidence paths, and psql exit codes.

Set-StrictMode -Version 2
$script:VerifyRoot = Split-Path -Parent $PSScriptRoot

function Write-Check {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('PASS', 'FAIL', 'SKIP', 'BLOCKED')]
        [string] $Status,
        [Parameter(Mandatory = $true)]
        [string] $Name,
        [Parameter(Mandatory = $true)]
        [string] $Evidence
    )
    $line = '{0}  {1} - {2}' -f $Status, $Name, ($Evidence -replace '[\r\n]+', ' ')
    Write-Output $line
    switch ($Status) {
        'PASS' { $script:CheckCounts.PASS++ }
        'FAIL' { $script:CheckCounts.FAIL++ }
        'SKIP' { $script:CheckCounts.SKIP++ }
        'BLOCKED' { $script:CheckCounts.BLOCKED++ }
    }
}

function New-EvidencePath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('4', '5', '6')][string] $Activity,
        [Parameter(Mandatory = $true)][string] $Project,
        [Parameter(Mandatory = $true)][string] $ScriptName,
        [string] $Root,
        [switch] $PreviewOnly
    )
    if ($Project -notmatch '^[A-Za-z0-9][A-Za-z0-9_-]*$') {
        throw 'Project must be a simple identifier such as group-01; path separators are not allowed.'
    }
    if ([string]::IsNullOrWhiteSpace($Root)) {
        $Root = Join-Path (Get-RepoRoot) 'evidence'
    }
    $date = Get-Date -Format 'yyyy-MM-dd'
    $directory = Join-Path $Root (Join-Path ('activity-' + $Activity) (Join-Path $Project $date))
    if (-not $PreviewOnly) {
        New-Item -ItemType Directory -Force -Path $directory | Out-Null
    }
    $base = [IO.Path]::GetFileNameWithoutExtension($ScriptName)
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    return Join-Path $directory ($base + '-' + $stamp + '.txt')
}

function Save-Evidence {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string] $Path,
        [Parameter(Mandatory = $true)][AllowEmptyString()][string] $Content
    )
    $parent = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    Set-Content -LiteralPath $Path -Value $Content -Encoding UTF8
}

function Start-Verification {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('4', '5', '6')][string] $Activity,
        [Parameter(Mandatory = $true)][string] $ScriptName,
        [Parameter(Mandatory = $true)][string] $Project,
        [string] $EvidenceDir,
        [switch] $DryRun
    )
    $script:CheckCounts = @{ PASS = 0; FAIL = 0; SKIP = 0; BLOCKED = 0 }
    $script:TranscriptStarted = $false
    if ($DryRun) {
        $preview = New-EvidencePath -Activity $Activity -Project $Project -ScriptName $ScriptName -Root $EvidenceDir -PreviewOnly
        $script:EvidenceFile = $null
        Write-Host ('Evidence file: none (dry run) - would be written to ' + $preview)
        return
    }
    $script:EvidenceFile = New-EvidencePath -Activity $Activity -Project $Project -ScriptName $ScriptName -Root $EvidenceDir
    try {
        Start-Transcript -Path $script:EvidenceFile -Force | Out-Null
        $script:TranscriptStarted = $true
    } catch {
        Write-Warning ('Could not start transcript: ' + $_.Exception.Message)
    }
    Write-Host ('Evidence file: ' + $script:EvidenceFile)
}

function Complete-Verification {
    [CmdletBinding()]
    param()
    Write-Host ('PASS: ' + $script:CheckCounts.PASS)
    Write-Host ('FAIL: ' + $script:CheckCounts.FAIL)
    Write-Host ('SKIP: ' + $script:CheckCounts.SKIP)
    Write-Host ('BLOCKED: ' + $script:CheckCounts.BLOCKED)
    $exitCode = 0
    if ($script:CheckCounts.FAIL -gt 0 -or $script:CheckCounts.BLOCKED -gt 0) {
        $exitCode = 1
    }
    if ($script:TranscriptStarted) {
        Stop-Transcript | Out-Null
    }
    return $exitCode
}

function Load-DotEnv {
    [CmdletBinding()]
    param([string] $Path = (Join-Path (Get-Location) '.env'))
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $false
    }
    foreach ($line in (Get-Content -LiteralPath $Path)) {
        if ($line -match '^\s*#' -or $line -notmatch '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*?)\s*$') {
            continue
        }
        $name = $Matches[1]
        $value = $Matches[2]
        if (($value.Length -ge 2) -and (($value.StartsWith('"') -and $value.EndsWith('"')) -or ($value.StartsWith("'") -and $value.EndsWith("'")))) {
            $value = $value.Substring(1, $value.Length - 2)
        }
        [Environment]::SetEnvironmentVariable($name, $value, 'Process')
    }
    return $true
}

function Get-ProjectConfig {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string] $Project,
        [string] $ConfigPath
    )
    if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
        $repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\..'))
        $ConfigPath = Join-Path $repoRoot 'config\projects.local.json'
    }
    if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
        return $null
    }
    try {
        $raw = Get-Content -LiteralPath $ConfigPath -Raw | ConvertFrom-Json
    } catch {
        throw ('Project configuration JSON is invalid: ' + $_.Exception.Message)
    }
    $items = @()
    if ($raw -is [System.Array]) {
        $items = @($raw)
    } elseif ($null -ne $raw) {
        $items = @($raw)
    }
    $config = $items | Where-Object { $_.group -eq $Project } | Select-Object -First 1
    if ($null -eq $config) {
        return $null
    }
    foreach ($property in $config.PSObject.Properties) {
        if ($property.Name -match '(?i)password|passwd|token|secret|credential|connectionstring') {
            throw ('Project configuration contains a prohibited secret-like property name: ' + $property.Name)
        }
    }
    return $config
}

function Test-ConfigReady {
    [CmdletBinding()]
    param([Parameter(Mandatory = $true)]$Config)
    foreach ($name in @('projectName', 'dbName', 'adminUser', 'appUser', 'readonlyUser', 'schemaName')) {
        $value = [string]$Config.$name
        if ([string]::IsNullOrWhiteSpace($value) -or $value -match '^<.*>$' -or $value -eq 'unknown') {
            return $false
        }
    }
    return $true
}

function ConvertTo-SqlLiteral {
    param([Parameter(Mandatory = $true)][string] $Value)
    return "'" + $Value.Replace("'", "''") + "'"
}

function ConvertTo-SqlIdentifier {
    param([Parameter(Mandatory = $true)][string] $Value)
    if ([string]::IsNullOrWhiteSpace($Value) -or $Value.Contains('.') -or $Value.Contains([char]0)) {
        throw 'Supply a single verified SQL identifier, not a qualified name.'
    }
    return '"' + $Value.Replace('"', '""') + '"'
}

function Invoke-Psql {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string] $Database,
        [string] $HostName = $env:PGHOST,
        [string] $Port = $env:PGPORT,
        [string] $User = $env:PGUSER,
        [string] $Sql,
        [string] $File,
        [switch] $TupleOnly
    )
    if ([string]::IsNullOrWhiteSpace($Database)) {
        return [pscustomobject]@{ Output = @(); ExitCode = 2 }
    }
    if ([string]::IsNullOrWhiteSpace($HostName)) { $HostName = 'localhost' }
    if ([string]::IsNullOrWhiteSpace($Port)) { $Port = '5432' }
    if ([string]::IsNullOrWhiteSpace($User)) { $User = $env:PGUSER }
    if ([string]::IsNullOrWhiteSpace($User)) {
        return [pscustomobject]@{ Output = @('Database username is not configured.'); ExitCode = 2 }
    }
    $arguments = @('-w', '-v', 'ON_ERROR_STOP=1', '-P', 'pager=off', '-h', $HostName, '-p', $Port, '-U', $User, '-d', $Database)
    if ($TupleOnly) { $arguments += @('-t', '-A') }
    if (-not [string]::IsNullOrWhiteSpace($File)) {
        if (-not (Test-Path -LiteralPath $File -PathType Leaf)) {
            return [pscustomobject]@{ Output = @('SQL file does not exist.'); ExitCode = 2 }
        }
        $arguments += @('-f', $File)
    } elseif (-not [string]::IsNullOrWhiteSpace($Sql)) {
        $arguments += @('-c', $Sql)
    } else {
        return [pscustomobject]@{ Output = @('No SQL or SQL file supplied.'); ExitCode = 2 }
    }
    $output = @()
    try {
        $output = @(& psql @arguments 2>&1 | ForEach-Object { [string]$_ })
        $code = $LASTEXITCODE
        return [pscustomobject]@{ Output = $output; ExitCode = $code }
    } catch {
        return [pscustomobject]@{ Output = @($_.Exception.Message); ExitCode = 127 }
    }
}

function Assert-Contains {
    param([string]$Text, [string]$Pattern)
    return ($Text -match $Pattern)
}

function Assert-NotContains {
    param([string]$Text, [string]$Pattern)
    return ($Text -notmatch $Pattern)
}

function Assert-ExitCode {
    param([int]$Actual, [int]$Expected = 0)
    return ($Actual -eq $Expected)
}

function Assert-Equals {
    param($Actual, $Expected)
    return ([string]$Actual -ceq [string]$Expected)
}

function Get-RepoRoot {
    return [IO.Path]::GetFullPath((Join-Path $script:VerifyRoot '..\..'))
}

function Get-VerifiedConfig {
    param([string]$Project, [string]$ConfigPath, [string]$Database, [string]$HostName, [string]$Port, [string]$AdminUser, [string]$AppUser, [string]$ReadonlyUser)
    $config = Get-ProjectConfig -Project $Project -ConfigPath $ConfigPath
    if ($null -eq $config) { $config = [pscustomobject]@{} }
    if (-not [string]::IsNullOrWhiteSpace($Database)) { Set-ConfigProperty $config 'dbName' $Database }
    if (-not [string]::IsNullOrWhiteSpace($AdminUser)) { Set-ConfigProperty $config 'adminUser' $AdminUser }
    if (-not [string]::IsNullOrWhiteSpace($AppUser)) { Set-ConfigProperty $config 'appUser' $AppUser }
    if (-not [string]::IsNullOrWhiteSpace($ReadonlyUser)) { Set-ConfigProperty $config 'readonlyUser' $ReadonlyUser }
    if (-not [string]::IsNullOrWhiteSpace($HostName)) { Set-ConfigProperty $config 'dbHost' $HostName }
    if (-not [string]::IsNullOrWhiteSpace($Port)) { Set-ConfigProperty $config 'dbPort' $Port }
    return $config
}

function Get-ConfigProperty {
    param($Config, [string]$Name, $Default = $null)
    if ($null -eq $Config) { return $Default }
    $property = $Config.PSObject.Properties[$Name]
    if ($null -eq $property) { return $Default }
    return $property.Value
}

function Set-ConfigProperty {
    param($Config, [string]$Name, $Value)
    if ($null -eq $Config.PSObject.Properties[$Name]) {
        $Config | Add-Member -NotePropertyName $Name -NotePropertyValue $Value
    } else {
        $Config.$Name = $Value
    }
}

function Initialize-ConfiguredCheck {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][ValidateSet('4', '5', '6')][string]$Activity,
        [Parameter(Mandatory = $true)][string]$ScriptName,
        [Parameter(Mandatory = $true)][string]$Project,
        [string]$ConfigPath,
        [string]$EvidenceDir,
        [string]$DbName,
        [string]$DbHost,
        [string]$DbPort,
        [string]$AdminUser,
        [string]$AppUser,
        [string]$ReadonlyUser,
        [string[]]$RequiredFields = @('dbName'),
        [switch]$LoadEnv,
        [switch]$DryRun
    )
    Start-Verification -Activity $Activity -ScriptName $ScriptName -Project $Project -EvidenceDir $EvidenceDir -DryRun:$DryRun
    if ($LoadEnv) {
        $loaded = Load-DotEnv -Path (Join-Path (Get-RepoRoot) '.env')
        if (-not $loaded) { Write-Host 'No .env file loaded; psql may use approved PG* environment or .pgpass.' }
    }
    $config = Get-VerifiedConfig -Project $Project -ConfigPath $ConfigPath -Database $DbName -HostName $DbHost -Port $DbPort -AdminUser $AdminUser -AppUser $AppUser -ReadonlyUser $ReadonlyUser
    $missing = Get-ConfigBlockers -Config $config -RequiredFields $RequiredFields
    if ($missing.Count -gt 0) {
        Write-Check -Status 'BLOCKED' -Name 'project configuration' -Evidence ('Missing project facts/config: ' + ($missing -join ', ') + '. Populate config/projects.local.json with non-secret values.') | Out-Host
        return [pscustomobject]@{ Ready = $false; Config = $config }
    }
    return [pscustomobject]@{ Ready = $true; Config = $config }
}

function Invoke-ProjectPsql {
    param($Config, [string]$Database, [string]$User, [string]$Sql, [string]$File, [switch]$TupleOnly)
    if ([string]::IsNullOrWhiteSpace($Database)) { $Database = [string]$Config.dbName }
    $hostName = [string](Get-ConfigProperty $Config 'dbHost')
    $port = [string](Get-ConfigProperty $Config 'dbPort')
    return Invoke-Psql -Database $Database -HostName $hostName -Port $port -User $User -Sql $Sql -File $File -TupleOnly:$TupleOnly
}

function Write-ResultOutput {
    param($Result)
    foreach ($line in @($Result.Output)) {
        if (-not [string]::IsNullOrWhiteSpace([string]$line)) { Write-Output ([string]$line) }
    }
}

function Get-ConfigBlockers {
    param($Config, [string[]]$RequiredFields)
    $missing = @()
    if ($null -eq $Config) { return ,@('No project configuration or complete parameter set was supplied.') }
    foreach ($connectionField in @('dbHost', 'dbPort')) {
        $connectionValue = Get-ConfigProperty $Config $connectionField
        if ($connectionValue -is [string] -and $connectionValue -match '^<.*>$') { $missing += $connectionField }
    }
    foreach ($field in $RequiredFields) {
        $value = Get-ConfigProperty $Config $field
        if ($null -eq $value -or ($value -is [string] -and ([string]::IsNullOrWhiteSpace($value) -or $value -match '^<.*>$' -or $value -eq 'unknown'))) {
            $missing += $field
        }
    }
    return ,$missing
}

function Quote-QualifiedIdentifier {
    param([Parameter(Mandatory = $true)][string]$Value)
    $parts = $Value.Split('.')
    if ($parts.Count -lt 1 -or $parts.Count -gt 2) { throw 'Expected an identifier or schema-qualified identifier.' }
    return (($parts | ForEach-Object { ConvertTo-SqlIdentifier -Value $_ }) -join '.')
}

function Write-ActionResult {
    param([string]$Name, [bool]$DryRun, [switch]$Execute)
    if ($DryRun) {
        Write-Check -Status 'SKIP' -Name $Name -Evidence 'Dry run: action preview only; no command executed.'
        return $false
    }
    if (-not $Execute) {
        Write-Check -Status 'BLOCKED' -Name $Name -Evidence 'Pass -DryRun to preview or -Execute to perform this action.'
        return $false
    }
    return $true
}

function Invoke-VerificationBatch {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string[]]$Scripts,
        [Parameter(Mandatory = $true)][string[]]$BaseArguments,
        [hashtable]$PerScriptArguments = @{}
    )
    $shell = Get-Command 'powershell.exe' -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $shell) { $shell = Get-Command 'pwsh.exe' -ErrorAction SilentlyContinue | Select-Object -First 1 }
    if ($null -eq $shell) {
        Write-Check BLOCKED 'verification runner' 'PowerShell executable was not found to isolate child script exit codes.'
        return
    }
    foreach ($script in $Scripts) {
        $scriptPath = Join-Path $script:VerifyRoot $script
        if (-not (Test-Path -LiteralPath $scriptPath -PathType Leaf)) {
            Write-Check BLOCKED ('script ' + $script) 'Expected verification script is missing.'
            continue
        }
        Write-Output ('--- ' + $script + ' ---')
        $arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $scriptPath) + $BaseArguments
        $scriptName = [IO.Path]::GetFileName($script)
        if ($PerScriptArguments.ContainsKey($scriptName)) { $arguments += @($PerScriptArguments[$scriptName]) }
        $output = @(& $shell.Source @arguments 2>&1 | ForEach-Object { [string]$_ })
        $childExit = $LASTEXITCODE
        $statusLines = @($output | Where-Object { $_ -match '^(PASS|FAIL|SKIP|BLOCKED)\s{1,}.+?\s+-\s+.+$' })
        foreach ($line in $output) {
            if ($line -notmatch '^(PASS|FAIL|SKIP|BLOCKED)\s{1,}.+?\s+-\s+.+$' -and $line -notmatch '^(PASS|FAIL|SKIP|BLOCKED):\s+\d+') {
                Write-Output $line
            }
        }
        foreach ($line in $statusLines) {
            if ($line -match '^(PASS|FAIL|SKIP|BLOCKED)\s+(.+?)\s+-\s+(.+)$') {
                Write-Check -Status $Matches[1] -Name $Matches[2] -Evidence $Matches[3]
            }
        }
        if ($statusLines.Count -eq 0 -or ($childExit -ne 0 -and @($statusLines | Where-Object { $_ -match '^FAIL\s' -or $_ -match '^BLOCKED\s' }).Count -eq 0)) {
            Write-Check BLOCKED ('script ' + $script) ('Child process exit code: ' + $childExit + '; inspect captured output.')
        }
    }
}
