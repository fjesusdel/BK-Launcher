# ==================================================
# BK-LAUNCHER - BOOTSTRAP ESTABLE (NO TOCA TOOLS)
# ==================================================

function Test-IsAdministrator {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# -------------------------------
# AUTO-ELEVACION
# -------------------------------

if (-not (Test-IsAdministrator)) {
    Start-Process powershell.exe `
        -Verb RunAs `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://raw.githubusercontent.com/fjesusdel/BK-Launcher/main/bootstrap.ps1 | iex`""
    return
}

$ErrorActionPreference = "Stop"

try {
    Write-Host ">>> BOOTSTRAP BK-LAUNCHER <<<" -ForegroundColor Cyan
    Write-Host ""

    $Base = Join-Path $env:LOCALAPPDATA "BlackConsole"

    # Carpetas que SI gestionamos
    $CoreDirs = @("core","apps","config","logs")

    if (-not (Test-Path $Base)) {
        New-Item -ItemType Directory -Path $Base | Out-Null
    }

    # -------------------------------
    # DESCARGAR REPO A TEMPORAL
    # -------------------------------

    $zipUrl = "https://github.com/fjesusdel/BK-Launcher/archive/refs/heads/main.zip"
    $tmpZip = Join-Path $env:TEMP "bk-launcher.zip"
    $tmpDir = Join-Path $env:TEMP "bk-launcher-tmp"

    Remove-Item $tmpDir -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host "Descargando BK-Launcher..."
    Invoke-WebRequest $zipUrl -OutFile $tmpZip -UseBasicParsing

    Write-Host "Extrayendo en temporal..."
    Expand-Archive $tmpZip $tmpDir -Force
    Remove-Item $tmpZip -Force

    $inner = Get-ChildItem $tmpDir | Where-Object { $_.PSIsContainer } | Select-Object -First 1

    # -------------------------------
    # ACTUALIZAR SOLO LO NECESARIO
    # -------------------------------

    foreach ($dir in $CoreDirs) {
        $src = Join-Path $inner.FullName $dir
        $dst = Join-Path $Base $dir

        if (Test-Path $dst) {
            Remove-Item $dst -Recurse -Force
        }

        if (Test-Path $src) {
            Copy-Item $src $dst -Recurse -Force
        }
    }

    # launcher.ps1
    Copy-Item (Join-Path $inner.FullName "launcher.ps1") `
        (Join-Path $Base "launcher.ps1") -Force

    Remove-Item $tmpDir -Recurse -Force

    # -------------------------------
    # LANZAR LAUNCHER
    # -------------------------------

    Write-Host ""
    Write-Host "Lanzando Black Console..."
    Write-Host ""

    powershell.exe `
        -NoProfile `
        -NoExit `
        -ExecutionPolicy Bypass `
        -File (Join-Path $Base "launcher.ps1") `
        -WorkingDirectory $Base
}
catch {
    Write-Host ""
    Write-Host "ERROR CRITICO EN BOOTSTRAP" -ForegroundColor Red
    Write-Host $_
    Pause
}
