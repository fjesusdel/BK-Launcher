# ==================================================
# BK-LAUNCHER - BOOTSTRAP
# ==================================================
# Descarga el proyecto completo y lanza launcher.ps1
# Compatible con irm | iex
# ==================================================

$ErrorActionPreference = "Stop"

Write-Host "Iniciando BK-Launcher..." -ForegroundColor Cyan

# -------------------------------
# RUTAS
# -------------------------------

$BKRoot = Join-Path $env:LOCALAPPDATA "BlackConsole"
$RepoBase = "https://raw.githubusercontent.com/fjesusdel/BK-Launcher/main"

# -------------------------------
# ADMIN
# -------------------------------

function Test-IsAdministrator {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdministrator)) {
    Write-Host "Reiniciando con privilegios de administrador..." -ForegroundColor Yellow
    Start-Process powershell `
        -ArgumentList "-ExecutionPolicy Bypass -NoExit -Command `"irm $RepoBase/bootstrap.ps1 | iex`"" `
        -Verb RunAs
    return
}

Write-Host "BK-Launcher iniciado con permisos de administrador." -ForegroundColor Green

# -------------------------------
# CREAR ESTRUCTURA
# -------------------------------

$folders = @(
    "config",
    "core",
    "apps",
    "tools"
)

foreach ($f in $folders) {
    $path = Join-Path $BKRoot $f
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
    }
}

# -------------------------------
# ARCHIVOS A DESCARGAR
# -------------------------------

$files = @{
    "launcher.ps1"              = "$BKRoot\launcher.ps1"

    "config/settings.ps1"       = "$BKRoot\config\settings.ps1"

    "core/ui.ps1"               = "$BKRoot\core\ui.ps1"
    "core/menu.ps1"             = "$BKRoot\core\menu.ps1"
    "core/actions.ps1"          = "$BKRoot\core\actions.ps1"
    "core/detect.ps1"           = "$BKRoot\core\detect.ps1"
    "core/selection.ps1"        = "$BKRoot\core\selection.ps1"
    "core/logs.ps1"             = "$BKRoot\core\logs.ps1"

    "apps/registry.ps1"         = "$BKRoot\apps\registry.ps1"
}

# -------------------------------
# DESCARGA
# -------------------------------

Write-Host "Descargando archivos del launcher..." -ForegroundColor Yellow

foreach ($rel in $files.Keys) {
    $url  = "$RepoBase/$rel"
    $dest = $files[$rel]

    try {
        Invoke-RestMethod -Uri $url -OutFile $dest
    } catch {
        Write-Host "ERROR descargando $rel" -ForegroundColor Red
        exit 1
    }
}

# -------------------------------
# EJECUTAR LAUNCHER
# -------------------------------

Write-Host "Lanzando Black Console..." -ForegroundColor Cyan
& "$BKRoot\launcher.ps1"
