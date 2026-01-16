# ==================================================
# BK-LAUNCHER - BOOTSTRAP
# ==================================================
# Responsabilidad:
# - Comprobar permisos de administrador
# - Relanzar el launcher con elevacion si es necesario
# - Establecer una ruta de ejecucion estable
# - NO contiene logica de menus ni aplicaciones
# ==================================================

# -------------------------------
# COMPROBAR PERMISOS DE ADMINISTRADOR
# -------------------------------

function Test-IsAdministrator {
    try {
        $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    }
    catch {
        return $false
    }
}

# -------------------------------
# RUTA BASE DE EJECUCION
# -------------------------------

$Global:BKRoot = Join-Path $env:LOCALAPPDATA "BlackConsole"

# -------------------------------
# RELANZAR COMO ADMINISTRADOR SI ES NECESARIO
# -------------------------------

if (-not (Test-IsAdministrator)) {

    Write-Host "BK-Launcher necesita ejecutarse con permisos de administrador."
    Write-Host "Reiniciando con privilegios elevados..."
    Write-Host ""

    $launcherPath = Join-Path $PSScriptRoot "launcher.ps1"

    if (-not (Test-Path $launcherPath)) {
        Write-Host "ERROR: No se encontro launcher.ps1." -ForegroundColor Red
        Pause
        exit 1
    }

    Start-Process powershell `
        -ArgumentList "-ExecutionPolicy Bypass -NoProfile -File `"$launcherPath`"" `
        -Verb RunAs

    exit
}

# -------------------------------
# EJECUCION NORMAL (YA EN ADMIN)
# -------------------------------

Clear-Host
Write-Host "BK-Launcher iniciado con permisos de administrador."
Write-Host ""

$launcherPath = Join-Path $PSScriptRoot "launcher.ps1"

if (-not (Test-Path $launcherPath)) {
    Write-Host "ERROR: No se encontro launcher.ps1." -ForegroundColor Red
    Pause
    exit 1
}

& $launcherPath
