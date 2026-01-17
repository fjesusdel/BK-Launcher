# ==================================================
# BK-LAUNCHER - BOOTSTRAP FINAL DEFINITIVO
# ==================================================

# -------------------------------
# AUTO-ELEVACION
# -------------------------------

function Test-IsAdministrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdministrator)) {
    Write-Host "Reiniciando BK-Launcher como administrador..." -ForegroundColor Yellow

    Start-Process powershell.exe `
        -Verb RunAs `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://raw.githubusercontent.com/fjesusdel/BK-Launcher/main/bootstrap.ps1?nocache=$(Get-Random) | iex`""

    exit
}

# -------------------------------
# CONFIGURACION
# -------------------------------

$ErrorActionPreference = "Stop"

Write-Host ">>> BOOTSTRAP BK-LAUNCHER (ESTABLE) <<<" -ForegroundColor Cyan
Write-Host ""

# -------------------------------
# RUTAS
# -------------------------------

$Base    = Join-Path $env:LOCALAPPDATA "BlackConsole"
$Runtime = Join-Path $Base "runtime"
$Tools   = Join-Path $Base "tools"
$Data    = Join-Path $Base "data"

New-Item -ItemType Directory -Path $Base,$Runtime,$Tools,$Data -Force | Out-Null

# -------------------------------
# LIMPIAR RUNTIME
# -------------------------------

Write-Host "Limpiando runtime..."
Remove-Item $Runtime -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $Runtime -Force | Out-Null

# -------------------------------
# DESCARGA
# -------------------------------

$zipUrl = "https://github.com/fjesusdel/BK-Launcher/archive/refs/heads/main.zip"
$tmpZip = Join-Path $env:TEMP "bk-launcher.zip"

Write-Host "Descargando BK-Launcher..."
Invoke-WebRequest $zipUrl -OutFile $tmpZip -UseBasicParsing

Write-Host "Extrayendo runtime..."
Expand-Archive $tmpZip $Runtime -Force
Remove-Item $tmpZip -Force

$inner = Get-ChildItem $Runtime | Where-Object { $_.PSIsContainer } | Select-Object -First 1
Get-ChildItem $inner.FullName | Move-Item -Destination $Runtime -Force
Remove-Item $inner.FullName -Recurse -Force

# -------------------------------
# LANZAR LAUNCHER (NOEXIT)
# -------------------------------

$launcher = Join-Path $Runtime "launcher.ps1"

Write-Host ""
Write-Host "Lanzando Black Console..."
Write-Host ""

Start-Process powershell.exe `
    -ArgumentList "-NoProfile -NoExit -ExecutionPolicy Bypass -File `"$launcher`"" `
    -WorkingDirectory $Runtime
