# ==================================================
# BK-LAUNCHER - MENU
# ==================================================

function Show-MainMenu {

    do {
        Clear-Host
        Show-BlackConsoleBanner

        Write-Host "MENU PRINCIPAL" -ForegroundColor Cyan
        Write-Host "--------------------------------" -ForegroundColor DarkGray
        Write-Host ""

        Write-Host " [1] " -ForegroundColor Green -NoNewline
        Write-Host "Instalar software" -ForegroundColor Gray

        Write-Host " [2] " -ForegroundColor Green -NoNewline
        Write-Host "Desinstalar software" -ForegroundColor Gray

        Write-Host " [3] " -ForegroundColor Green -NoNewline
        Write-Host "Herramientas Black Console" -ForegroundColor Gray

        Write-Host " [4] " -ForegroundColor Green -NoNewline
        Write-Host "Estado del sistema" -ForegroundColor Gray

        Write-Host " [5] " -ForegroundColor Green -NoNewline
        Write-Host "Ver logs" -ForegroundColor Gray

        Write-Host " [6] " -ForegroundColor Green -NoNewline
        Write-Host "Acerca de" -ForegroundColor Gray

        Write-Host ""
        Write-Host " [0] Salir" -ForegroundColor Yellow
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
# HERRAMIENTAS BLACK CONSOLE
# ==================================================

function Show-ToolsMenu {

    do {
        Clear-Host
        Show-BlackConsoleBanner

        Write-Host "HERRAMIENTAS BLACK CONSOLE" -ForegroundColor Cyan
        Write-Host "--------------------------------" -ForegroundColor DarkGray
        Write-Host ""

        Write-Host " [1] " -ForegroundColor Green -NoNewline
        Write-Host "Instalar Control de volumen BK" -ForegroundColor Gray

        Write-Host " [2] " -ForegroundColor Green -NoNewline
        Write-Host "Desinstalar Control de volumen BK" -ForegroundColor Gray

        Write-Host " [3] " -ForegroundColor Green -NoNewline
        Write-Host "Instalar Radial Apps BK" -ForegroundColor Gray

        Write-Host " [4] " -ForegroundColor Green -NoNewline
        Write-Host "Desinstalar Radial Apps BK" -ForegroundColor Gray

        Write-Host ""
        Write-Host " [0] Volver" -ForegroundColor Yellow
        Write-Host ""

        $option = Read-Host "Seleccione una opcion"

        switch ($option) {

            "1" {
                Clear-Host
                Show-BlackConsoleBanner
                Write-Host "Instalando Control de volumen BK..." -ForegroundColor Cyan
                $ok = Install-BKVolumeControl
                Write-Host ""
                if ($ok) {
                    Write-Host "[ OK ] Control de volumen BK instalado correctamente." -ForegroundColor Green
                } else {
                    Write-Host "[ XX ] Error al instalar Control de volumen BK." -ForegroundColor Red
                }
                Pause
            }

            "2" {
                Clear-Host
                Show-BlackConsoleBanner
                Write-Host "Desinstalando Control de volumen BK..." -ForegroundColor Cyan
                $ok = Uninstall-BKVolumeControl
                Write-Host ""
                if ($ok) {
                    Write-Host "[ OK ] Control de volumen BK desinstalado correctamente." -ForegroundColor Green
                } else {
                    Write-Host "[ XX ] Error al desinstalar Control de volumen BK." -ForegroundColor Red
                }
                Pause
            }

            "3" {
                Clear-Host
                Show-BlackConsoleBanner
                Write-Host "RADIAL APPS BK" -ForegroundColor Cyan
                Write-Host "--------------------------------" -ForegroundColor DarkGray
                Write-Host ""
                Write-Host "Menu radial flotante para acceso rapido." -ForegroundColor Gray
                Write-Host "Requiere Rainmeter." -ForegroundColor Yellow
                Write-Host ""
                $confirm = Read-Host "Desea instalarlo? [S/N]"
                if ($confirm.Trim().ToUpper() -eq "S") {
                    Write-Host ""
                    Write-Host "Instalando Radial Apps BK..." -ForegroundColor Cyan
                    $ok = Install-BKRadialApps
                    Write-Host ""
                    if ($ok) {
                        Write-Host "[ OK ] Radial Apps BK instalado correctamente." -ForegroundColor Green
                    } else {
                        Write-Host "[ XX ] Error al instalar Radial Apps BK." -ForegroundColor Red
                    }
                }
                Pause
            }

            "4" {
                Clear-Host
                Show-BlackConsoleBanner
                Write-Host "Desinstalando Radial Apps BK..." -ForegroundColor Cyan
                $ok = Uninstall-BKRadialApps
                Write-Host ""
                if ($ok) {
                    Write-Host "[ OK ] Radial Apps BK desinstalado correctamente." -ForegroundColor Green
                } else {
                    Write-Host "[ XX ] Error al desinstalar Radial Apps BK." -ForegroundColor Red
                }
                Pause
            }

            "0" { return }
        }

    } while ($true)
}

# ==================================================
# RESTO
# ==================================================

function Show-SystemStatus {
    Write-Host "Estado del sistema." -ForegroundColor Gray
    Pause
}

function Show-LogsMenu {
    Open-LastBKLog
}

function Show-About {
    Clear-Host
    Show-BlackConsoleBanner
    Write-Host "Autor   : $($Global:BKConfig.Author)" -ForegroundColor Gray
    Write-Host "Version : $($Global:BKConfig.Version)" -ForegroundColor Gray
    Pause
}
