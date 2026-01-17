# ==================================================
# BK-LAUNCHER - BOOTSTRAP ESTABLE DEFINITIVO
# ==================================================
# - NO usa runtime
# - NO ejecuta código desde AppData
# - Ejecuta SIEMPRE el launcher del repo descargado
# - AppData solo para datos (logs / tools / data)
# ==================================================

# -------------------------------
# AUTO-ELEVACION
# -------------------------------

function Test-IsAdministrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal   = New-Object Security.Principal.WindowsPrincipal($currentUser)
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

Write-Host ">>> BOOTSTRAP BK-LAUNCHER (REPO DIRECTO) <<<" -ForegroundColor Cyan
Write-Host ""

# -------------------------------
# RUTAS
# -------------------------------

# Repo temporal descargado
$RepoBase = Join-Path $env:TEMP "BK-Launcher-Repo"

# Datos persistentes
$BCBase  = Join-Path $env:LOCALAPPDATA "BlackConsole"
$Logs    = Join-Path $BCBase "logs"
$Tools   = Join-Path $BCBase "tools"
$Data    = Join-Path $BCBase "data"

# Crear carpetas de datos (NO código)
New-Item -ItemType Directory -Path $BCBase,$Logs,$Tools,$Data -Force | Out-Null

# -------------------------------
# LIMPIAR REPO TEMPORAL
# -------------------------------

if (Test-Path $RepoBase) {
    Write-Host "Limpiando repo temporal anterior..."
    Remove-Item $RepoBase -Recurse -Force
}

New-Item -ItemType Directory -Path $RepoBase | Out-Null

# -------------------------------
# DESCARGAR REPO
# -------------------------------

$zipUrl = "https://github.com/fjesusdel/BK-Launcher/archive/refs/heads/main.zip"
$tmpZip = Join-Path $env:TEMP "bk-launcher.zip"

Write-Host "Descargando BK-Launcher desde GitHub..."
Invoke-WebRequest $zipUrl -OutFile $tmpZip -UseBasicParsing

Write-Host "Extrayendo repositorio..."
Expand-Archive $tmpZip $RepoBase -Force
Remove-Item $tmpZip -Force

# Ajustar estructura (quitar carpeta interna)
$inner = Get-ChildItem $RepoBase | Where-Object { $_.PSIsContainer } | Select-Object -First 1
$RepoRoot = $inner.FullName

# -------------------------------
# VALIDAR LAUNCHER
# -------------------------------

$launcher = Join-Path $RepoRoot "launcher.ps1"

if (-not (Test-Path $launcher)) {
    Write-Host "ERROR: launcher.ps1 no encontrado en el repositorio." -ForegroundColor Red
    exit 1
}

# -------------------------------
# LANZAR BLACK CONSOLE
# -------------------------------

Write-Host ""
Write-Host "Lanzando Black Console desde el REPO (modo estable)..."
Write-Host ""

Start-Process powershell.exe `
    -NoNewWindow `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$launcher`"" `
    -WorkingDirectory $RepoRoot
