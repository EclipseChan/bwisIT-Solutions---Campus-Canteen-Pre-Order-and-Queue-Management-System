<#
Loads .env into environment variables, then starts the API on port 8080.
The Spring Boot app reads environment variables, not the .env file itself.
Usage (from the repository root):
  powershell -ExecutionPolicy Bypass -File .\scripts\run-backend.ps1
#>
$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)
if (-not (Test-Path .env)) { throw "Missing .env. Run: Copy-Item .env.example .env and edit it." }

Get-Content .env | ForEach-Object {
    if ($_ -match '^\s*#' -or $_ -notmatch '=') { return }
    $k, $v = $_ -split '=', 2
    Set-Item -Path "Env:$($k.Trim())" -Value $v
}
mvn spring-boot:run
