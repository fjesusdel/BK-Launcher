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

    # -------------------------------
    # RED (BITS)
    # -------------------------------

    Write-Host ""
    Write-Host "RED"
    Write-Host "--------------------------------"
    Write-Host ""

    try {
        Write-Host "Probando conectividad..."

        # Ping
        $ping = Test-Connection -ComputerName 1.1.1.1 -Count 2 -Quiet
        if (-not $ping) {
            throw "Sin conectividad IP"
        }

        $lat = (Test-Connection 1.1.1.1 -Count 2 |
            Measure-Object -Property ResponseTime -Average).Average

        Write-Host "Latencia media       : $([math]::Round($lat,1)) ms" -ForegroundColor Cyan

        # Test BITS
        Write-Host ""
        Write-Host "Probando velocidad de descarga..."

        $url  = "https://speed.hetzner.de/10MB.bin"
        $dest = Join-Path $env:TEMP "bk_speedtest.bin"

        if (Test-Path $dest) {
            Remove-Item $dest -Force
        }

        $start = Get-Date
        Start-BitsTransfer -Source $url -Destination $dest -ErrorAction Stop
        $end = Get-Date

        $sizeMB = 10
        $seconds = ($end - $start).TotalSeconds
        $mbps = [math]::Round((($sizeMB * 8) / $seconds), 2)

        Write-Host "Velocidad descarga   : $mbps Mbps" -ForegroundColor Green

        Remove-Item $dest -Force -ErrorAction SilentlyContinue

    } catch {
        Write-Host "No se pudo realizar el test de red." -ForegroundColor Red
        Write-Host "Posible firewall, proxy o red restringida." -ForegroundColor DarkGray
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
