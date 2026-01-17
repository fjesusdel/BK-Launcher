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
# ESTADO DEL SISTEMA (WOW MODE)
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

    $adminText  = if ($isAdmin) { "SI" } else { "NO" }
    $adminColor = if ($isAdmin) { "Green" } else { "Red" }

    Write-Host "Administrador : " -NoNewline
    Write-Host $adminText -ForegroundColor $adminColor
    Write-Host ""

    # -------------------------------
    # SISTEMA
    # -------------------------------
    $os = (Get-CimInstance Win32_OperatingSystem).Caption
    Write-Host "Sistema       : $os"
    Write-Host ""

    # -------------------------------
    # APLICACIONES BK
    # -------------------------------
    Write-Host "APLICACIONES BLACK CONSOLE"
    Write-Host "--------------------------------"

    $bkApps = @(
        @{ Name = "Control de volumen BK"; Path = "$env:LOCALAPPDATA\BlackConsole\tools\volume\volume.ahk" }
        @{ Name = "Radial Apps BK"; Path = "$env:USERPROFILE\Documents\Rainmeter\Skins\RadialLauncher" }
    )

    foreach ($app in $bkApps) {
        if (Test-Path $app.Path) {
            Write-Host ("{0,-25} : INSTALADA" -f $app.Name) -ForegroundColor Green
        } else {
            Write-Host ("{0,-25} : NO INSTALADA" -f $app.Name) -ForegroundColor DarkGray
        }
    }

    Write-Host ""

    # -------------------------------
    # RED - TEST DE VELOCIDAD
    # -------------------------------
    Write-Host "RED"
    Write-Host "--------------------------------"
    Write-Host "Probando velocidad de conexion..."
    Write-Host ""

    try {
        # DESCARGA
        $downloadUrl = "https://speed.hetzner.de/100MB.bin"
        $tmpFile = Join-Path $env:TEMP "bk_speedtest.bin"

        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        Invoke-WebRequest $downloadUrl -OutFile $tmpFile -UseBasicParsing
        $sw.Stop()

        Remove-Item $tmpFile -Force

        $downloadMbps = [Math]::Round((100 * 8) / $sw.Elapsed.TotalSeconds, 2)

        # SUBIDA (SIMULADA)
        $uploadData = "X" * 5MB
        $sw.Restart()
        Invoke-WebRequest "https://httpbin.org/post" -Method Post -Body $uploadData -UseBasicParsing | Out-Null
        $sw.Stop()

        $uploadMbps = [Math]::Round((5 * 8) / $sw.Elapsed.TotalSeconds, 2)

        # COLORES
        function SpeedColor($speed) {
            if ($speed -gt 500) { "Green" }
            elseif ($speed -gt 100) { "Yellow" }
            else { "Red" }
        }

        Write-Host "Descarga : $downloadMbps Mbps" -ForegroundColor (SpeedColor $downloadMbps)
        Write-Host "Subida   : $uploadMbps Mbps"   -ForegroundColor (SpeedColor $uploadMbps)

        if ($downloadMbps -gt 500) {
            Write-Host ""
            Write-Host "Estado   : CONEXION EXCELENTE" -ForegroundColor Green
        }
        elseif ($downloadMbps -gt 100) {
            Write-Host ""
            Write-Host "Estado   : CONEXION BUENA" -ForegroundColor Yellow
        }
        else {
            Write-Host ""
            Write-Host "Estado   : CONEXION LENTA" -ForegroundColor Red
        }

    } catch {
        Write-Host "No se pudo realizar el test de red." -ForegroundColor Red
    }

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
