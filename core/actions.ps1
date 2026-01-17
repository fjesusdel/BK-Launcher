# ==================================================
# BK-LAUNCHER - ACTIONS (ESTABLE)
# ==================================================
# Instalacion y desinstalacion de software
# Version segura: no rompe la carga del launcher
# ==================================================

$ErrorActionPreference = "Stop"

# -------------------------------
# UTILIDADES
# -------------------------------

function Get-BKApplicationById {
    param ([string]$Id)
    Get-BKApplications | Where-Object { $_.Id -eq $Id }
}

function Test-BKAppStillInstalled {
    param ($App)

    if ($App.Type -eq "windows") {
        return (Get-AppxPackage | Where-Object { $_.Name -like "*$($App.Id)*" })
    }

    $keys = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($key in $keys) {
        $found = Get-ItemProperty $key -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -and $_.DisplayName -like "*$($App.Name)*" }

        if ($found) { return $true }
    }

    return $false
}

# ==================================================
# INSTALACION SOFTWARE
# ==================================================

function Install-BKApplicationsWithProgress {
    param ([string[]]$Ids)

    foreach ($id in $Ids) {

        $app = Get-BKApplicationById $id
        if (-not $app) { continue }

        Clear-Host
        Show-BlackConsoleBanner

        Write-Host "INSTALANDO SOFTWARE"
        Write-Host "--------------------------------"
        Write-Host "Aplicacion : $($app.Name)"
        Write-Host ""

        $tmp = Join-Path $env:TEMP "$id-installer.exe"

        switch ($id) {

            "battle.net" {
                Invoke-WebRequest "https://www.battle.net/download/getInstallerForGame?os=win&locale=esES&gameProgram=BATTLENET_APP" -OutFile $tmp
                Start-Process $tmp -Wait
            }

            "chrome" {
                Invoke-WebRequest "https://www.google.com/chrome/?standalone=1&platform=win64" -OutFile $tmp
                Start-Process $tmp "/silent /install" -Wait
            }

            "firefox" {
                Invoke-WebRequest "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=es-ES" -OutFile $tmp
                Start-Process $tmp "-ms" -Wait
            }
        }

        Remove-Item $tmp -ErrorAction SilentlyContinue
    }
}

# ==================================================
# DESINSTALACION SOFTWARE
# ==================================================

function Uninstall-BKApplicationsWithProgress {
    param ([string[]]$Ids)

    foreach ($id in $Ids) {

        $app = Get-BKApplicationById $id
        if (-not $app) { continue }

        Clear-Host
        Show-BlackConsoleBanner

        Write-Host "DESINSTALANDO SOFTWARE"
        Write-Host "--------------------------------"
        Write-Host "Aplicacion : $($app.Name)"
        Write-Host ""

        $uninstallCmd = $null

        $keys = @(
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )

        foreach ($key in $keys) {
            $entry = Get-ItemProperty $key -ErrorAction SilentlyContinue |
                Where-Object { $_.DisplayName -and $_.DisplayName -like "*$($app.Name)*" } |
                Select-Object -First 1

            if ($entry -and $entry.UninstallString) {
                $uninstallCmd = $entry.UninstallString
                break
            }
        }

        if ($uninstallCmd) {
            Start-Process "cmd.exe" "/c $uninstallCmd" -Wait
        }

        Write-Host ""
        if (Test-BKAppStillInstalled $app) {
            Write-Host "ERROR: $($app.Name) sigue instalada." -ForegroundColor Red
        } else {
            Write-Host "$($app.Name) desinstalada correctamente." -ForegroundColor Green
        }

        Pause
    }
}

# ==================================================
# HERRAMIENTAS BLACK CONSOLE
# ==================================================

function Install-BKVolumeControl {
    Write-Host "Instalando Control de volumen BK..."
    return $true
}

function Uninstall-BKVolumeControl {
    Write-Host "Desinstalando Control de volumen BK..."
    return $true
}

function Install-BKRadialApps {
    Write-Host "Instalando Radial Apps BK..."
    return $true
}

function Uninstall-BKRadialApps {
    Write-Host "Desinstalando Radial Apps BK..."
    return $true
}
