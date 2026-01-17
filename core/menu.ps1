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
# HERRAMIENTAS BLACK CONSOLE
# ==================================================

function Show-ToolsMenu {

    do {
        Clear-Host
        Show-BlackConsoleBanner

        Write-Host "HERRAMIENTAS BLACK CONSOLE"
        Write-Host "--------------------------------"
        Write-Host ""
        Write-Host "1) Instalar Control de volumen BK"
        Write-Host "2) Desinstalar Control de volumen BK"
        Write-Host "3) Instalar Radial Apps BK"
        Write-Host "4) Desinstalar Radial Apps BK"
        Write-Host ""
        Write-Host "0) Volver"
        Write-Host ""

        $option = Read-Host "Seleccione una opcion"

        switch ($option) {

            "1" {
                Clear-Host
                Show-BlackConsoleBanner
                Write-Host "Instalando Control de volumen BK..."
                $ok = Install-BKVolumeControl
                if ($ok) {
                    Write-Host ""
                    Write-Host "Control de volumen BK instalado correctamente."
                } else {
                    Write-Host ""
                    Write-Host "Error al instalar Control de volumen BK."
                }
                Pause
            }

            "2" {
                Clear-Host
                Show-BlackConsoleBanner
                Write-Host "Desinstalando Control de volumen BK..."
                $ok = Uninstall-BKVolumeControl
                if ($ok) {
                    Write-Host ""
                    Write-Host "Control de volumen BK desinstalado correctamente."
                } else {
                    Write-Host ""
                    Write-Host "Error al desinstalar Control de volumen BK."
                }
                Pause
            }

            "3" {
                Clear-Host
                Show-BlackConsoleBanner
                Write-Host "RADIAL APPS BK"
                Write-Host "--------------------------------"
                Write-Host ""
                Write-Host "Menu radial flotante para acceso rapido."
                Write-Host "Requiere Rainmeter."
                Write-Host ""
                $confirm = Read-Host "Desea instalarlo? [S/N]"
                if ($confirm.Trim().ToUpper() -eq "S") {
                    Write-Host ""
                    Write-Host "Instalando Radial Apps BK..."
                    $ok = Install-BKRadialApps
                    if ($ok) {
                        Write-Host ""
                        Write-Host "Radial Apps BK instalado correctamente."
                    } else {
                        Write-Host ""
                        Write-Host "Error al instalar Radial Apps BK."
                    }
                }
                Pause
            }

            "4" {
                Clear-Host
                Show-BlackConsoleBanner
                Write-Host "Desinstalando Radial Apps BK..."
                $ok = Uninstall-BKRadialApps
                if ($ok) {
                    Write-Host ""
                    Write-Host "Radial Apps BK desinstalado correctamente."
                } else {
                    Write-Host ""
                    Write-Host "Error al desinstalar Radial Apps BK."
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
    Write-Host "Estado del sistema."
    Pause
}

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
