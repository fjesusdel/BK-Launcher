# ==================================================
# BK-LAUNCHER - MENU
# ==================================================

function Show-MainMenu {

    do {
        Clear-Host
        Show-BlackConsoleBanner

        Write-Host "MENU PRINCIPAL"
        Write-Host "--------------------------------"
        Write-Host ""
        Write-Host "1) Instalar software"
        Write-Host "2) Desinstalar software"
        Write-Host "3) Herramientas Black Console"
        Write-Host "4) Estado del sistema"
        Write-Host "5) Ver logs"
        Write-Host "6) Acerca de"
        Write-Host ""
        Write-Host "0) Salir"
        Write-Host ""

        $option = Read-Host "Seleccione una opcion"

        switch ($option) {
            "1" { Show-InstallMenu }
            "2" { Show-UninstallMenu }
            "3" { Show-ToolsMenu }
            "4" { Show-SystemStatus }
            "5" { Show-LogsMenu }
            "6" { Show-About }
            "0" { break }
            default { Pause }
        }

    } while ($true)
}

# ==================================================
# ESTADO DEL SISTEMA (IMPLEMENTADO)
# ==================================================

function Show-SystemStatus {

    Clear-Host
    Show-BlackConsoleBanner

    Write-Host "ESTADO DEL SISTEMA"
    Write-Host "--------------------------------"
    Write-Host ""

    # Usuario / permisos
    $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    $isAdmin   = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    Write-Host "Usuario actual : $($identity.Name)"
    Write-Host "Administrador  : $($isAdmin)"
    Write-Host ""

    # Sistema operativo
    $os = Get-CimInstance Win32_OperatingSystem
    Write-Host "Sistema operativo : $($os.Caption)"
    Write-Host "Arquitectura      : $($os.OSArchitecture)"
    Write-Host ""

    # Memoria RAM
    $ramGB = [Math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
    Write-Host "RAM total : $ramGB GB"
    Write-Host ""

    # Disco sistema
    $systemDrive = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
    $freeGB = [Math]::Round($systemDrive.FreeSpace / 1GB, 2)
    $totalGB = [Math]::Round($systemDrive.Size / 1GB, 2)

    Write-Host "Disco sistema (C:)"
    Write-Host " - Libre : $freeGB GB"
    Write-Host " - Total : $totalGB GB"
    Write-Host ""

    # Rutas Black Console
    Write-Host "Black Console"
    Write-Host " - Runtime : $($Global:BKRoot)\runtime"
    Write-Host " - Tools   : $($Global:BKRoot)\tools"
    Write-Host " - Data    : $($Global:BKRoot)\data"
    Write-Host ""

    # Estado herramientas BK
    $volumeInstalled = Test-Path "$env:LOCALAPPDATA\BlackConsole\tools\volume"
    $radialInstalled = Test-Path "$env:USERPROFILE\Documents\Rainmeter\Skins\RadialLauncher"

    Write-Host "Herramientas BK"
    Write-Host " - Control de volumen : $($volumeInstalled)"
    Write-Host " - Radial Apps BK    : $($radialInstalled)"
    Write-Host ""

    Pause
}

# ==================================================
# RESTO
# ==================================================

function Show-LogsMenu {
    Open-LastBKLog
}

function Show-About {
    Clear-Host
    Show-BlackConsoleBanner
    Write-Host "Autor   : $($Global:BKConfig.Author)"
    Write-Host "Version : $($Global:BKConfig.Version)"
    Pause
}
