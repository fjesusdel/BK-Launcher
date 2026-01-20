# ==================================================
# BK-LAUNCHER - MAIN LAUNCHER
# ==================================================
# Punto de entrada del sistema
# Carga configuracion, core y lanza el menu
# ==================================================

# -------------------------------
# COMPROBAR PERMISOS DE ADMINISTRADOR
# -------------------------------

function Test-IsAdministrator {
    try {
        $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        return $false
    }
}

if (-not (Test-IsAdministrator)) {
    Write-Host "ERROR: BK-Launcher debe ejecutarse como administrador." -ForegroundColor Red
    Write-Host "Ejecute bootstrap.ps1 para iniciar correctamente."
    exit 1
}

# -------------------------------
# DEFINIR RUTAS
# -------------------------------

$Global:BKRoot       = Join-Path $env:LOCALAPPDATA "BlackConsole"
$Global:BKConfigPath = Join-Path $PSScriptRoot "config"
$Global:BKCorePath   = Join-Path $PSScriptRoot "core"
$Global:BKAppsPath   = Join-Path $PSScriptRoot "apps"

# -------------------------------
# CARGAR CONFIGURACION
# -------------------------------

$configFile = Join-Path $Global:BKConfigPath "settings.ps1"
if (-not (Test-Path $configFile)) {
    Write-Host "ERROR: Falta config/settings.ps1" -ForegroundColor Red
    exit 1
}
. $configFile

# -------------------------------
# CARGAR CORE (ORDEN IMPORTA)
# -------------------------------

$coreModules = @(
    "ui.ps1",
    "logs.ps1",
    "detect.ps1",
    "actions.ps1",
    "selection.ps1",
    "menu.ps1"
)

foreach ($module in $coreModules) {
    $path = Join-Path $Global:BKCorePath $module
    if (-not (Test-Path $path)) {
        Write-Host "ERROR: Falta modulo core $module" -ForegroundColor Red
        exit 1
    }
    . $path
}

# -------------------------------
# CARGAR REGISTRY DE APPS
# -------------------------------

$registryFile = Join-Path $Global:BKAppsPath "registry.ps1"
if (-not (Test-Path $registryFile)) {
    Write-Host "ERROR: Falta apps/registry.ps1" -ForegroundColor Red
    exit 1
}
. $registryFile

# -------------------------------
# INICIALIZAR LOGS
# -------------------------------

Initialize-BKLogs

# -------------------------------
# LANZAR MENU PRINCIPAL
# -------------------------------

Show-MainMenu
# ==================================================
# BK-LAUNCHER - MAIN LAUNCHER
# ==================================================
# Punto de entrada del sistema
# Carga configuracion, core y lanza el menu
# ==================================================

# -------------------------------
# COMPROBAR PERMISOS DE ADMINISTRADOR
# -------------------------------

function Test-IsAdministrator {
    try {
        $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        return $false
    }
}

if (-not (Test-IsAdministrator)) {
    Write-Host "ERROR: BK-Launcher debe ejecutarse como administrador." -ForegroundColor Red
    Write-Host "Ejecute bootstrap.ps1 para iniciar correctamente."
    exit 1
}

# -------------------------------
# DEFINIR RUTAS
# -------------------------------

$Global:BKRoot       = Join-Path $env:LOCALAPPDATA "BlackConsole"
$Global:BKConfigPath = Join-Path $PSScriptRoot "config"
$Global:BKCorePath   = Join-Path $PSScriptRoot "core"
$Global:BKAppsPath   = Join-Path $PSScriptRoot "apps"

# -------------------------------
# CARGAR CONFIGURACION
# -------------------------------

$configFile = Join-Path $Global:BKConfigPath "settings.ps1"
if (-not (Test-Path $configFile)) {
    Write-Host "ERROR: Falta config/settings.ps1" -ForegroundColor Red
    exit 1
}
. $configFile

# Limpieza defensiva de funciones (evita sombras antiguas)

Remove-Item function:Show-ToolsMenu -ErrorAction SilentlyContinue


# -------------------------------
# CARGAR CORE (ORDEN IMPORTA)
# -------------------------------

$coreModules = @(
    "ui.ps1",
    "logs.ps1",
    "detect.ps1",
    "actions.ps1",
    "selection.ps1",
    "menu.ps1"
)

foreach ($module in $coreModules) {
    $path = Join-Path $Global:BKCorePath $module
    if (-not (Test-Path $path)) {
        Write-Host "ERROR: Falta modulo core $module" -ForegroundColor Red
        exit 1
    }
    . $path
}

# -------------------------------
# CARGAR REGISTRY DE APPS
# -------------------------------

$registryFile = Join-Path $Global:BKAppsPath "registry.ps1"
if (-not (Test-Path $registryFile)) {
    Write-Host "ERROR: Falta apps/registry.ps1" -ForegroundColor Red
    exit 1
}
. $registryFile

# -------------------------------
# INICIALIZAR LOGS
# -------------------------------

Initialize-BKLogs

# -------------------------------
# LANZAR MENU PRINCIPAL
# -------------------------------

Show-MainMenu
