# certgun installer for Windows
# Usage: irm https://raw.githubusercontent.com/takielias/certgun/main/install.ps1 | iex

$Version = "0.1.0"
$Repo = "takielias/certgun"
$Binary = "certgun"

$ErrorActionPreference = "Stop"

function Info($msg) { Write-Host "[certgun] $msg" -ForegroundColor Cyan }
function Ok($msg) { Write-Host "[certgun] $msg" -ForegroundColor Green }
function Warn($msg) { Write-Host "[certgun] $msg" -ForegroundColor Yellow }
function Err($msg) { Write-Host "[certgun] $msg" -ForegroundColor Red; exit 1 }

# Detect architecture
$Arch = if ([Environment]::Is64BitOperatingSystem) { "amd64" } else { Err "32-bit not supported" }
if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { $Arch = "arm64" }

Info "Downloading certgun v$Version for windows/$Arch..."

$Archive = "$Binary-$Version-windows-$Arch.tar.gz"
$Url = "https://github.com/$Repo/releases/download/v$Version/$Archive"

$TmpDir = New-TemporaryFile | ForEach-Object { Remove-Item $_; New-Item -ItemType Directory -Path $_ }

try {
    Invoke-WebRequest -Uri $Url -OutFile "$TmpDir\$Archive" -UseBasicParsing

    Info "Extracting..."
    tar -xzf "$TmpDir\$Archive" -C $TmpDir

    $InstallDir = "$env:LOCALAPPDATA\certgun"
    if (-not (Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    }

    Move-Item "$TmpDir\$Binary.exe" "$InstallDir\$Binary.exe" -Force

    # Add to PATH if not already there
    $UserPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($UserPath -notlike "*$InstallDir*") {
        [Environment]::SetEnvironmentVariable("PATH", "$UserPath;$InstallDir", "User")
        Warn "Added $InstallDir to PATH. Restart your terminal."
    }

    Ok "Installed to $InstallDir\$Binary.exe"
}
catch {
    Warn "Binary download failed, trying go install..."

    if (-not (Get-Command go -ErrorAction SilentlyContinue)) {
        Err "Go is not installed. Install from https://go.dev/dl/"
    }

    go install "-ldflags=-s -w -X 'github.com/taki/certgun/cmd.Version=$Version'" github.com/taki/certgun@latest
    Ok "Installed via go install"
}
finally {
    Remove-Item -Recurse -Force $TmpDir -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "Get started:" -ForegroundColor Green
Write-Host "  certgun init"
Write-Host "  certgun setup"
Write-Host ""
