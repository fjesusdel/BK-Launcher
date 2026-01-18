# ==================================================
# BK-LAUNCHER - BOOTSTRAP ESTABLE (ARQUITECTURA REAL)
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

    # -------------------------------
    # CREAR BASE SI NO EXISTE
    # (NO BORRAR NUNCA)
    # -------------------------------

    if (-not (Test-Path $Base)) {
        New-Item -ItemType Directory -Path $Base | Out-Null
    }

    # -------------------------------
    # DESCARGAR REPO
    # -------------------------------

    $zipUrl = "https://github.com/fjesusdel/BK-Launcher/archive/refs/heads/main.zip"
    $tmpZip = Join-Path $env:TEMP "bk-launcher.zip"

    Write-Host "Descargando BK-Launcher..."
    Invoke-WebRequest $zipUrl -OutFile $tmpZip -UseBasicParsing

    Write-Host "Extrayendo..."
    Expand-Archive $tmpZip $Base -Force
    Remove-Item $tmpZip -Force

    # -------------------------------
    # APLANAR CARPETA
    # -------------------------------

    $inner = Get-ChildItem $Base | Where-Object { $_.PSIsContainer -and $_.Name -like "BK-Launcher*" } | Select-Object -First 1

    if ($inner) {
        Get-ChildItem $inner.FullName | Move-Item -Destination $Base -Force
        Remove-Item $inner.FullName -Recurse -Force
    }

    # -------------------------------
    # LANZAR LAUNCHER
    # -------------------------------

    $launcher = Join-Path $Base "launcher.ps1"

    if (-not (Test-Path $launcher)) {
        Write-Host "ERROR: launcher.ps1 no encontrado" -ForegroundColor Red
        Pause
        return
    }

    Write-Host ""
    Write-Host "Lanzando Black Console..."
    Write-Host ""

    powershell.exe `
        -NoProfile `
        -NoExit `
        -ExecutionPolicy Bypass `
        -File "$launcher" `
        -WorkingDirectory $Base
}
catch {
    Write-Host ""
    Write-Host "ERROR CRITICO EN BOOTSTRAP" -ForegroundColor Red
    Write-Host $_
    Pause
}
