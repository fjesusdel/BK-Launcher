# ==================================================
# BK-LAUNCHER - ACTIONS (FUNCIONAL REAL)
# ==================================================

$ErrorActionPreference = "Stop"

# --------------------------------------------------
# UTILIDADES
# --------------------------------------------------

function Get-BKApplicationById {
    param ([string]$Id)
    Get-BKApplications | Where-Object { $_.Id -eq $Id }
}

function Download-And-Run {
    param (
        [string]$Url,
        [string]$Args = ""
    )

    $file = Join-Path $env:TEMP ([System.IO.Path]::GetFileName($Url))

    Write-Host "Descargando instalador..."
    Invoke-WebRequest $Url -OutFile $file -UseBasicParsing

    Write-Host "Ejecutando instalador..."
    Start-Process $file $Args -Wait
}

# --------------------------------------------------
# INSTALACIÓN DE SOFTWARE
# --------------------------------------------------

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

        switch ($id) {

            "battle.net" {
                Download-And-Run `
                    "https://www.battle.net/download/getInstallerForGame?os=win&locale=esES&gameProgram=BATTLENET_APP"
            }

            "chrome" {
                Download-And-Run `
                    "https://www.google.com/chrome/?standalone=1&platform=win64" `
                    "/silent /install"
            }

            "firefox" {
                Download-And-Run `
                    "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=es-ES" `
                    "-ms"
            }

            default {
                Write-Host "No hay instalador definido para $id" -ForegroundColor Yellow
            }
        }

        Write-Host ""
        Write-Host "Proceso de instalacion terminado para $($app.Name)."
        Pause
    }
}

# --------------------------------------------------
# DESINSTALACIÓN DE SOFTWARE
# --------------------------------------------------

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

            if ($entry.UninstallString) {
                $uninstallCmd = $entry.UninstallString
                break
            }
        }

        if ($uninstallCmd) {
            Write-Host "Lanzando desinstalador..."
            Start-Process "cmd.exe" "/c $uninstallCmd" -Wait
        } else {
            Write-Host "No se encontro desinstalador." -ForegroundColor Yellow
        }

        Pause
    }
}

# --------------------------------------------------
# CONTROL DE VOLUMEN BK (RESTAURADO)
# --------------------------------------------------

function Install-BKVolumeControl {

    $target = Join-Path $env:LOCALAPPDATA "BlackConsole\tools\volume"
    New-Item -ItemType Directory -Path $target -Force | Out-Null

    Write-Host "Descargando AutoHotkey..."
    Invoke-WebRequest `
        "https://raw.githubusercontent.com/fjesusdel/BK-Launcher/main/tools/volume/AutoHotkey.exe" `
        -OutFile "$target\AutoHotkey.exe" -UseBasicParsing

    Write-Host "Descargando script de volumen..."
    Invoke-WebRequest `
        "https://raw.githubusercontent.com/fjesusdel/BK-Launcher/main/tools/volume/volume.ahk" `
        -OutFile "$target\volume.ahk" -UseBasicParsing

    Write-Host "Lanzando Control de volumen BK..."
    Start-Process "$target\AutoHotkey.exe" "`"$target\volume.ahk`"" -WindowStyle Hidden

    Pause
}

function Uninstall-BKVolumeControl {
    Get-Process AutoHotkey -ErrorAction SilentlyContinue | Stop-Process -Force
    Remove-Item "$env:LOCALAPPDATA\BlackConsole\tools\volume" -Recurse -Force -ErrorAction SilentlyContinue
    Pause
}

# --------------------------------------------------
# RADIAL APPS BK (RESTAURADO)
# --------------------------------------------------

function Install-BKRadialApps {

    Write-Host "Descargando Radial Apps BK..."

    $tmp = Join-Path $env:TEMP "BlackConsoleRadial.rmskin"

    Invoke-WebRequest `
        "https://raw.githubusercontent.com/fjesusdel/BK-Launcher/main/tools/radial/BlackConsoleRadial_1.0.rmskin" `
        -OutFile $tmp -UseBasicParsing

    Write-Host "Abriendo instalador de Rainmeter..."
    Start-Process $tmp

    Pause
}

function Uninstall-BKRadialApps {

    $path = Join-Path $env:USERPROFILE "Documents\Rainmeter\Skins\RadialLauncher"
    Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue

    Pause
}
