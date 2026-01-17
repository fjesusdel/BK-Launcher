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
# ESTADO DEL SISTEMA
# ==================================================

function Draw-Bar {
    param (
        [int]$Percent,
        [int]$Width = 20
    )

    $filled = [math]::Round(($Percent / 100) * $Width)
    $empty  = $Width - $filled

    return ("█" * $filled) + ("░" * $empty)
}

function Show-SystemStatus {

    Clear-Host
    Show-BlackConsoleBanner

    Write-Host "ESTADO DEL SISTEMA"
    Write-Host "--------------------------------"
    Write-Host ""

    # -------------------------------
    # ADMINISTRADOR
    # -------------------------------

    $isAdmin = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    Write-Host -NoNewline "Administrador : "
    if ($isAdmin) {
        Write-Host "SI" -ForegroundColor Green
    } else {
        Write-Host "NO" -ForegroundColor Red
    }

    # -------------------------------
    # SISTEMA
    # -------------------------------

    $os = (Get-CimInstance Win32_OperatingSystem).Caption
    Write-Host ""
    Write-Host "Sistema       : $os"

    # -------------------------------
    # CPU
    # -------------------------------

    Write-Host ""
    Write-Host "CPU"
    Write-Host "--------------------------------"

    $cpu = Get-CimInstance Win32_Processor
    $cpuLoad = (Get-Counter '\Processor(_Total)\% Processor Time'
    ).CounterSamples.CookedValue

    $cpuPercent = [math]::Round($cpuLoad)

    Write-Host "Modelo        : $($cpu.Name)"
    Write-Host "Nucleos       : $($cpu.NumberOfCores)"
    Write-Host "Hilos         : $($cpu.NumberOfLogicalProcessors)"
    Write-Host ("Uso           : {0}% {1}" -f `
        $cpuPercent, (Draw-Bar $cpuPercent)) -ForegroundColor Cyan

    # -------------------------------
    # RAM
    # -------------------------------

    Write-Host ""
    Write-Host "MEMORIA RAM"
    Write-Host "--------------------------------"

    $osInfo = Get-CimInstance Win32_OperatingSystem
    $totalRAM = [math]::Round($osInfo.TotalVisibleMemorySize / 1MB, 2)
    $freeRAM  = [math]::Round($osInfo.FreePhysicalMemory / 1MB, 2)
    $usedRAM  = [math]::Round($totalRAM - $freeRAM, 2)
    $ramPct   = [math]::Round(($usedRAM / $totalRAM) * 100)

    Write-Host "Total         : $totalRAM GB"
    Write-Host "En uso        : $usedRAM GB"
    Write-Host "Libre         : $freeRAM GB"
    Write-Host ("Uso           : {0}% {1}" -f `
        $ramPct, (Draw-Bar $ramPct)) -ForegroundColor Magenta

    # -------------------------------
    # DISCO (C:)
    # -------------------------------

    Write-Host ""
    Write-Host "DISCO"
    Write-Host "--------------------------------"

    $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"

    $totalDisk = [math]::Round($disk.Size / 1GB, 2)
    $freeDisk  = [math]::Round($disk.FreeSpace / 1GB, 2)
    $usedDisk  = [math]::Round($totalDisk - $freeDisk, 2)
    $diskPct   = [math]::Round(($usedDisk / $totalDisk) * 100)

    Write-Host "Unidad        : C:"
    Write-Host "Total         : $totalDisk GB"
    Write-Host "Libre         : $freeDisk GB"
    Write-Host ("Uso           : {0}% {1}" -f `
        $diskPct, (Draw-Bar $diskPct)) -ForegroundColor Yellow

    # -------------------------------
    # APPS BLACK CONSOLE
    # -------------------------------

    Write-Host ""
    Write-Host "APLICACIONES BLACK CONSOLE"
    Write-Host "--------------------------------"

    $volPath = Join-Path $env:LOCALAPPDATA "BlackConsole\tools\volume"
    $radPath = Join-Path $env:USERPROFILE "Documents\Rainmeter\Skins\RadialLauncher"

    Write-Host -NoNewline "Control de volumen BK : "
    if (Test-Path $volPath) {
        Write-Host "INSTALADA" -ForegroundColor Green
    } else {
        Write-Host "NO INSTALADA" -ForegroundColor DarkGray
    }

    Write-Host -NoNewline "Radial Apps BK       : "
    if (Test-Path $radPath) {
        Write-Host "INSTALADA" -ForegroundColor Green
    } else {
        Write-Host "NO INSTALADA" -ForegroundColor DarkGray
    }

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
