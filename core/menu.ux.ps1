# ==================================================
# BK-LAUNCHER - MENU UX
# ==================================================
# UX avanzada del menu principal
# - Navegacion con flechas
# - Colores
# - Fallback seguro
# - NO contiene logica de negocio
# ==================================================

function Show-MainMenuUX {

    $items = @(
        @{ Key = "1"; Text = "Instalar software";            Action = { Show-InstallMenu } },
        @{ Key = "2"; Text = "Desinstalar software";         Action = { Show-UninstallMenu } },
        @{ Key = "3"; Text = "Herramientas Black Console";   Action = { Show-ToolsMenu } },
        @{ Key = "4"; Text = "Estado del sistema";           Action = { Show-SystemStatus } },
        @{ Key = "5"; Text = "Ver logs";                     Action = { Show-LogsMenu } },
        @{ Key = "6"; Text = "Acerca de";                    Action = { Show-About } },
        @{ Key = "0"; Text = "Salir";                        Action = { return } }
    )

    $index = 0

    try {
        [Console]::CursorVisible = $false
    } catch {
        return
    }

    do {
        Clear-Host
        Show-BlackConsoleBanner

        Render-MainMenuBox $items $index

        $input = Get-MainMenuUXInput

        switch ($input) {

            "UP"   { if ($index -gt 0) { $index-- } }
            "DOWN" { if ($index -lt ($items.Count - 1)) { $index++ } }
            "ENTER" { & $items[$index].Action }
            "EXIT"  { break }

            default {
                $match = $items | Where-Object { $_.Key -eq $input }
                if ($match) {
                    & $match.Action
                }
            }
        }

    } while ($true)
}

# --------------------------------------------------

function Render-MainMenuBox {
    param (
        [array]$Items,
        [int]$Index
    )

    Write-Host "MENU PRINCIPAL"
    Write-Host "--------------------------------"
    Write-Host ""

    for ($i = 0; $i -lt $Items.Count; $i++) {

        $prefix = if ($i -eq $Index) { "▶" } else { " " }
        $line   = "{0} [{1}] {2}" -f $prefix, $Items[$i].Key, $Items[$i].Text

        if ($i -eq $Index) {
            Write-Host $line -ForegroundColor Cyan
        } else {
            Write-Host $line
        }
    }

    Write-Host ""
    Write-Host "--------------------------------"
    Write-Host "↑ ↓ Mover | Enter Seleccionar | 1-6 Acceso directo | Esc Salir" -ForegroundColor DarkGray
}

# --------------------------------------------------

function Get-MainMenuUXInput {

    $key = [Console]::ReadKey($true)

    switch ($key.Key) {
        "UpArrow"    { return "UP" }
        "DownArrow"  { return "DOWN" }
        "Enter"      { return "ENTER" }
        "Escape"     { return "EXIT" }
        default {
            if ($key.KeyChar) {
                return $key.KeyChar.ToString()
            }
        }
    }

    return $null
}
