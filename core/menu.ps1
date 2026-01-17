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
    # RED (INFO PASIVA, SEGURA)
    # -------------------------------

    Write-Host ""
    Write-Host "RED"
    Write-Host "--------------------------------"
    Write-Host ""

    try {
        $net = Get-NetAdapter |
            Where-Object { $_.Status -eq "Up" } |
            Select-Object -First 1

        if (-not $net) {
            throw "Sin adaptador activo"
        }

        $type =
            if ($net.NdisPhysicalMedium -eq 9) { "Wi-Fi" }
            elseif ($net.NdisPhysicalMedium -eq 14) { "Ethernet" }
            else { "Desconocido" }

        Write-Host "Interfaz activa : $($net.Name)"
        Write-Host "Tipo de red     : $type"

        # IP local
        $ip = Get-NetIPAddress -InterfaceIndex $net.ifIndex `
            -AddressFamily IPv4 -ErrorAction SilentlyContinue |
            Select-Object -First 1

        if ($ip) {
            Write-Host "IP local        : $($ip.IPAddress)"
        }

        # DNS
        $dns = (Get-DnsClientServerAddress `
            -InterfaceIndex $net.ifIndex `
            -AddressFamily IPv4).ServerAddresses

        if ($dns) {
            Write-Host "DNS activos     : $($dns -join ', ')"
        }

        # Conectividad básica
        Write-Host ""
        Write-Host -NoNewline "Conectividad    : "
        if (Test-Connection 1.1.1.1 -Count 1 -Quiet) {
            Write-Host "OK" -ForegroundColor Green
        } else {
            Write-Host "SIN RESPUESTA" -ForegroundColor Red
        }

    } catch {
        Write-Host "No se pudo obtener informacion de red." -ForegroundColor Red
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
