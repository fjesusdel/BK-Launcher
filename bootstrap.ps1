# ==================================================
# BK-LAUNCHER - BOOTSTRAP
# ==================================================
# Descarga y lanza BK-Launcher correctamente
# Compatible con irm | iex
# ==================================================

$ErrorActionPreference = "Stop"

Write-Host "Iniciando BK-Launcher..." -ForegroundColor Cyan

# -------------------------------
# RUTAS
# -------------------------------

$BKRoot = Join-Path $env:LOCALAPPDATA "BlackConsole"
$LauncherFile = Join-Path $BKRoot "launcher.ps1"

# -------------------------------
# CREAR DIRECTORIO
# -------------------------------

if (-not (Test-Path $BKRoot)) {
    New-Item -ItemType Directory -Path $BKRoot | Out-Null
}

# -------------------------------
# URL DEL LAUNCHER
# -------------------------------

$LauncherUrl = "https://raw.githubusercontent.com/fjesusdel/BK-Launcher/main/launcher.ps1"

# -------------------------------
# DESCARGAR LAUNCHER
# -------------------------------

Write-Host "Descargando launcher..." -ForegroundColor Yellow

try {
    Invoke-RestMethod -Uri $LauncherUrl -OutFile $LauncherFile
}
catch {
    Write-Host "ERROR: No se pudo descargar launcher.ps1" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $LauncherFile)) {
    Write-Host "ERROR: launcher.ps1 no existe tras la descarga" -ForegroundColor Red
    exit 1
}

# -------------------------------
# COMPROBAR ADMIN
# -------------------------------

function Test-IsAdministrator {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdministrator)) {
    Write-Host "Reiniciando con privilegios de administrador..." -ForegroundColor Yellow

    Start-Process powershell `
        -ArgumentList "-ExecutionPolicy Bypass -File `"$LauncherFile`"" `
        -Verb RunAs

    return
}

# -------------------------------
# EJECUTAR LAUNCHER
# -------------------------------

Write-Host "BK-Launcher iniciado con permisos de administrador." -ForegroundColor Green
& $LauncherFile
