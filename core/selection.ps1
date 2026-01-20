# ==================================================
# BK-LAUNCHER - SELECTION
# ==================================================
# - Seleccion por numeros separados por comas
# - Install  : solo apps de terceros
# - Uninstall: terceros + apps de Windows
# ==================================================

# --------------------------------------------------
# MENU: INSTALAR SOFTWARE
# --------------------------------------------------

function Show-InstallMenu {

    $apps = Select-BKApplications -Mode install
    if (-not $apps -or $apps.Count -eq 0) {
        return
    }

    $ids = $apps | Select-Object -ExpandProperty Id
    Install-BKApplicationsWithProgress $ids
}

# --------------------------------------------------
# MENU: DESINSTALAR SOFTWARE
# --------------------------------------------------

function Show-UninstallMenu {

    $apps = Select-BKApplications -Mode uninstall
    if (-not $apps -or $apps.Count -eq 0) {
        return
    }

    $ids = $apps | Select-Object -ExpandProperty Id
    Uninstall-BKApplicationsWithProgress $ids
}

# --------------------------------------------------
# MENU: HERRAMIENTAS BLACK CONSOLE (ESTABLE)
# --------------------------------------------------

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

        $opt = Read-Host "Seleccione una opcion"

        switch ($opt) {
            "1" { Install-BKVolumeControl; Pause }
            "2" { Uninstall-BKVolumeControl; Pause }
            "3" { Install-BKRadialApps; Pause }
            "4" { Uninstall-BKRadialApps; Pause }
            "0" { break }
            default { Pause }
        }

    } while ($true)
}

# --------------------------------------------------
# SELECCION GENERICA DE APPS
# --------------------------------------------------

function Select-BKApplications {
    param (
        [Parameter(Mandatory)]
        [ValidateSet("install","uninstall")]
        [string]$Mode
    )

    $allApps = Get-BKApplicationsStatus | Sort-Object Name

    if ($Mode -eq "install") {
        $thirdPartyApps = $allApps | Where-Object { $_.Type -eq "thirdparty" }
        $windowsApps   = @()
    }
    else {
        $thirdPartyApps = $allApps | Where-Object { $_.Type -eq "thirdparty" }
        $windowsApps   = $allApps | Where-Object { $_.Type -eq "windows" }
    }

    do {
        Clear-Host
        Show-BlackConsoleBanner

        Write-Host "SELECCIONAR APLICACIONES A $($Mode.ToUpper())"
        Write-Host "--------------------------------"
        Write-Host ""
        Write-Host "Numeros separados por comas (ej: 1,3,5)"
        Write-Host "ENTER = continuar | 0 = cancelar"
        Write-Host ""

        $indexMap = @{}
        $index = 1

        Write-Host "SOFTWARES Y APLICACIONES"
        Write-Host "--------------------------------"

        foreach ($app in $thirdPartyApps) {
            $state = if ($app.Installed) { "(INSTALADA)" } else { "(NO INSTALADA)" }
            Write-Host ("{0,2}) {1} {2}" -f $index, $app.Name, $state)
            $indexMap[$index] = $app
            $index++
        }

        if ($Mode -eq "uninstall" -and $windowsApps.Count -gt 0) {
            Write-Host ""
            Write-Host "APPS DE WINDOWS"
            Write-Host "--------------------------------"

            foreach ($app in $windowsApps) {
                $state = if ($app.Installed) { "(INSTALADA)" } else { "(NO INSTALADA)" }
                Write-Host ("{0,2}) {1} {2}" -f $index, $app.Name, $state)
                $indexMap[$index] = $app
                $index++
            }
        }

        Write-Host ""
        $input = Read-Host "Seleccion"

        if ($input -eq "0") { return $null }
        if ([string]::IsNullOrWhiteSpace($input)) { return @() }

        $selection = @()
        foreach ($part in $input -split ",") {
            if ($part.Trim() -match '^\d+$') {
                $num = [int]$part.Trim()
                if ($indexMap.ContainsKey($num)) {
                    $selection += $indexMap[$num]
                }
            }
        }

        return $selection

    } while ($true)
}
