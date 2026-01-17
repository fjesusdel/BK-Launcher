# ==================================================
# BK-LAUNCHER - BOOTSTRAP (GITHUB → APPDATA)
# ==================================================
# Compatible 100% con: irm | iex
# ==================================================

function Test-IsAdministrator {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdministrator)) {
    Start-Process powershell.exe `
        -Verb RunAs `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://raw.githubusercontent.com/fjesusdel/BK-Launcher/main/bootstrap.ps1?nocache=$(Get-Random) | iex`""
    exit
}

$ErrorActionPreference = "Stop"

Write-Host ">>> BOOTSTRAP BK-LAUNCHER (GITHUB → APPDATA) <<<" -ForegroundColor Cyan
Write-Host ""

# --------------------------------------------------
# RUTAS
# --------------------------------------------------

$Base = Join-Path $env:LOCALAPPDATA "BlackConsole"

# Limpieza TOTAL (código)
if (Test-Path $Base) {
    Write-Host "Limpiando version anterior..."
    Remove-Item $Base -Recurse -Force
}

New-Item -ItemType Directory -Path $Base | Out-Null

# --------------------------------------------------
# DESCARGA REPO
# --------------------------------------------------

$zipUrl = "https://github.com/fjesusdel/BK-Launcher/archive/refs/heads/main.zip"
$tmpZip = Join-Path $env:TEMP "bk-launcher.zip"

Write-Host "Descargando BK-Launcher desde GitHub..."
Invoke-WebRequest $zipUrl -OutFile $tmpZip -UseBasicParsing

Write-Host "Extrayendo..."
Expand-Archive $tmpZip $Base -Force
Remove-Item $tmpZip -Force

# Mover contenido interno
$inner = Get-ChildItem $Base | Where-Object { $_.PSIsContainer } | Select-Object -First 1
Get-ChildItem $inner.FullName | Move-Item -Destination $Base -Force
Remove-Item $inner.FullName -Recurse -Force

# --------------------------------------------------
# CREAR DATOS PERSISTENTES
# --------------------------------------------------

New-Item -ItemType Directory -Path `
    (Join-Path $Base "logs"),
    (Join-Path $Base "tools"),
    (Join-Path $Base "data") `
    -Force | Out-Null

# --------------------------------------------------
# LANZAR LAUNCHER
# --------------------------------------------------

$launcher = Join-Path $Base "launcher.ps1"

if (-not (Test-Path $launcher)) {
    Write-Host "ERROR: launcher.ps1 no encontrado" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Lanzando Black Console..."
Write-Host ""

Start-Process powershell.exe `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$launcher`"" `
    -WorkingDirectory $Base
