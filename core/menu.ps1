# ==================================================
# BK-LAUNCHER - MENU
# ==================================================

function Show-MainMenu {

    do {
        Clear-Host
        Show-BlackConsoleBanner

        Write-Host "MENU PRINCIPAL" -ForegroundColor Cyan
        Show-Separator
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

        Show-Separator
        $option = Read-Host "Seleccione una opcion"

        switch ($option) {
            "1" { Show-InstallMenu }
            "2" { Show-UninstallMenu }
            "3" { Show-ToolsMenu }   # ← delega en selection.ps1
            "4" { Show-SystemStatus }
            "5" { Show-LogsMenu }
            "6" { Show-About }
            "0" { break }
            default { Pause }
        }

    } while ($true)
}

# ==================================================
# UTILIDAD: BARRA ASCII SEGURA
# ==================================================

function Draw-Bar {
    param (
        [int]$Percent,
        [int]$Width = 20
    )

    if ($Percent -lt 0)   { $Percent = 0 }
    if ($Percent -gt 100) { $Percent = 100 }

    $filled = [math]::Round(($Percent / 100) * $Width)
    $empty  = $Width - $filled

    return "[" + ("#" * $filled) + ("-" * $empty) + "]"
}

# ==================================================
# ESTADO DEL SISTEMA
# ==================================================

function Show-SystemStatus {

    Clear-Host
    Show-BlackConsoleBanner

    Write-Host "ESTADO DEL SISTEMA" -ForegroundColor Cyan
    Show-Separator
    Write-Host ""

    $isAdmin = ([Security.Principal.WindowsPrincipal] `
        [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    Write-Host -NoNewline "Administrador : "
    if ($isAdmin) {
        Write-Host "SI" -ForegroundColor Green
    } else {
        Write-Host "NO" -ForegroundColor Red
    }

    $os = (Get-CimInstance Win32_OperatingSystem).Caption
    Write-Host ""
    Write-Host "Sistema       : $os"

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

    Write-Host "ACERCA DE" -ForegroundColor Cyan
    Show-Separator
    Write-Host ""
    Write-Host "Autor   : $($Global:BKConfig.Author)"
    Write-Host "Version : $($Global:BKConfig.Version)"
    Pause
}
