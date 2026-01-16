# ==================================================
# BK-LAUNCHER - MAIN LAUNCHER
# ==================================================
# Responsabilidad:
# - Inicializar el entorno
# - Cargar configuracion y modulos
# - Mostrar banner
# - Entrar al menu principal
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

if (-not (Test-IsAdministrator)) {
    Write-Host "ERROR: BK-Launcher debe ejecutarse como administrador." -ForegroundColor Red
    Write-Host "Ejecute bootstrap.ps1 para iniciar correctamente."
    exit 1
}

# -------------------------------
# DEFINIR RUTAS GLOBALES
# -------------------------------

$Global:BKRoot       = Join-Path $env:LOCALAPPDATA "BlackConsole"
$Global:BKConfigPath = Join-Path $PSScriptRoot "config"
$Global:BKCorePath   = Join-Path $PSScriptRoot "core"
$Global:BKAppsPath   = Join-Path $PSScriptRoot "apps"
$Global:BKToolsPath  = Join-Path $PSScriptRoot "tools"

# -------------------------------
# CARGAR CONFIGURACION
# -------------------------------

$configFile = Join-Path $Global:BKConfigPath "settings.ps1"

if (-not (Test-Path $configFile)) {
    Write-Host "ERROR: No se encontro config/settings.ps1" -ForegroundColor Red
    exit 1
}

. $configFile

# -------------------------------
# CARGAR MODULOS CORE
# -------------------------------

$coreModules = @(
    "ui.ps1",
    "menu.ps1",
    "logs.ps1"
)

foreach ($module in $coreModules) {
    $modulePath = Join-Path $Global:BKCorePath $module
    if (-not (Test-Path $modulePath)) {
        Write-Host "ERROR: Falta el modulo core $module" -ForegroundColor Red
        exit 1
    }
    . $modulePath
}

# -------------------------------
# INICIALIZAR LOGS (PLACEHOLDER)
# -------------------------------

if (Get-Command Initialize-BKLogs -ErrorAction SilentlyContinue) {
    Initialize-BKLogs
}

# -------------------------------
# MOSTRAR BANNER
# -------------------------------

if (Get-Command Show-BlackConsoleBanner -ErrorAction SilentlyContinue) {
    Show-BlackConsoleBanner
}

# -------------------------------
# MENU PRINCIPAL (PLACEHOLDER)
# -------------------------------

function Show-MainMenu {

    do {
        Write-Host "MENU PRINCIPAL"
        Write-Host "--------------------------------"
        Write-Host ""
        Write-Host "1) Instalar software"
        Write-Host "2) Desinstalar software"
        Write-Host "3) Herramientas Black Console"
        Write-Host "4) Estado del sistema"
        Write-Host "5) Acerca de"
        Write-Host ""
        Write-Host "0) Salir"
        Write-Host ""

        $option = Read-Host "Seleccione una opcion"

        switch ($option) {
            "0" {
                Write-Host "Saliendo de BK-Launcher..."
                break
            }
            default {
                Write-Host ""
                Write-Host "Opcion no implementada aun."
                Write-Host ""
                Pause
                Clear-Host
                if (Get-Command Show-BlackConsoleBanner -ErrorAction SilentlyContinue) {
                    Show-BlackConsoleBanner
                }
            }
        }

    } while ($true)
}

Show-MainMenu
