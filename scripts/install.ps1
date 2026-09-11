# AgentScript Universal Installer for Windows (PowerShell)
# Usage: irm https://aslang.dev/install.ps1 | iex
$ErrorActionPreference = "Stop"

$Version = "0.1.0"
$InstallDir = "$env:LOCALAPPDATA\asl\bin"
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

Write-Host "🚀 Installing AgentScript (ASL) for Windows..." -ForegroundColor Cyan

$AslCmdPath = Join-Path $InstallDir "asl.cmd"

@"
@echo off
node "%~dp0..\..\asl\asl" %* 2>nul || powershell -ExecutionPolicy Bypass -Command "& { & '$InstallDir\asl.ps1' @args }" %*
"@ | Set-Content -Path $AslCmdPath -Encoding ASCII

$UserPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
if ($UserPath -notlike "*$InstallDir*") {
    [System.Environment]::SetEnvironmentVariable("Path", "$UserPath;$InstallDir", [System.EnvironmentVariableTarget]::User)
    $env:Path = "$env:Path;$InstallDir"
    Write-Host "✓ Added $InstallDir to User PATH" -ForegroundColor Green
}

Write-Host "✓ ASL successfully installed to $InstallDir\asl.cmd" -ForegroundColor Green
Write-Host "⚡ Run: asl --version" -ForegroundColor Yellow
