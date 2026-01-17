# ==================================================
# BK-LAUNCHER - ACTIONS (FIXED - SAFE v2)
# ==================================================

# -------------------------------
# UTILIDADES
# -------------------------------

function Get-BKApplicationById {
    param ([string]$Id)
    Get-BKApplications | Where-Object { $_.Id -eq $Id }
}

function Invoke-BKDownload {
    param (
        [string]$Url,
        [string]$OutFile
    )

    try {
        Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing
        return $true
    } catch {
        Write-BKLog "Error descargando $Url" "ERROR"
        return $false
    }
}

function Start-BKInstaller {
    param (
        [string]$FilePath,
        [string]$Arguments = ""
    )

    if (-not (Test-Path $FilePath)) {
        Write-Host "Instalador no encontrado."
        return
    }

    Write-Host "Ejecutando instalador..."

    # 🔧 FIX REAL:
    # Start-Process NO admite ArgumentList vacío
    if ([string]::IsNullOrWhiteSpace($Arguments)) {
        $proc = Start-Process -FilePath $FilePath -PassThru
    } else {
        $proc = Start-Process -FilePath $FilePath -ArgumentList $Arguments -PassThru
    }

    # Esperar de forma segura a que termine
    if ($proc -and $proc.Id) {
        Wait-Process -Id $proc.Id
    }

    Write-Host "Instalador finalizado."
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

            "battlenet" {
                if (Invoke-BKDownload `
                    "https://www.battle.net/download/getInstallerForGame?os=win&gameProgram=BATTLENET_APP&version=Live" `
                    $tmp) {

                    Start-BKInstaller $tmp
                }
            }

            "chrome" {
                if (Invoke-BKDownload `
                    "https://www.google.com/chrome/?standalone=1&platform=win64" `
                    $tmp) {

                    Start-BKInstaller $tmp "/silent /install"
                }
            }

            "discord" {
                if (Invoke-BKDownload `
                    "https://discord.com/api/download?platform=win" `
                    $tmp) {

                    Start-BKInstaller $tmp "/S"
                }
            }

            "steam" {
                if (Invoke-BKDownload `
                    "https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe" `
                    $tmp) {

                    Start-BKInstaller $tmp "/S"
                }
            }

            "firefox" {
                if (Invoke-BKDownload `
                    "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=es-ES" `
                    $tmp) {

                    Start-BKInstaller $tmp "-ms"
                }
            }

            "7zip" {
                if (Invoke-BKDownload `
                    "https://www.7-zip.org/a/7z2301-x64.exe" `
                    $tmp) {

                    Start-BKInstaller $tmp "/S"
                }
            }

            default {
                Write-Host "No hay instalador definido para $id"
            }
        }

        if (Test-Path $tmp) {
            Remove-Item $tmp -Force -ErrorAction SilentlyContinue
        }

        Write-Host ""
        Write-Host "Instalacion terminada para $($app.Name)."
        Pause
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

        $uninstalled = $false

        $keys = @(
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )

        foreach ($key in $keys) {
            Get-ItemProperty $key -ErrorAction SilentlyContinue | ForEach-Object {
                if ($_.DisplayName -and $_.DisplayName -like "*$($app.Name)*") {
                    if ($_.UninstallString) {
                        Write-Host "Lanzando desinstalador..."
                        Start-Process "cmd.exe" "/c `"$($_.UninstallString)`"" -Wait
                        $uninstalled = $true
                    }
                }
            }
        }

        if (-not $uninstalled) {
            Write-Host "No se encontro desinstalador automatico. Puede requerir desinstalacion manual."
        }

        Write-Host ""
        Write-Host "Proceso de desinstalacion terminado para $($app.Name)."
        Pause
    }
}

# ==================================================
# CONTROL DE VOLUMEN BK
# ==================================================

function Install-BKVolumeControl {

    try {
        $targetDir = Join-Path $env:LOCALAPPDATA "BlackConsole\tools\volume"
        $exe = Join-Path $targetDir "AutoHotkey.exe"
        $ahk = Join-Path $targetDir "volume.ahk"

        $baseUrl = "https://raw.githubusercontent.com/fjesusdel/BK-Launcher/main/tools/volume"

        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

        Invoke-WebRequest "$baseUrl/AutoHotkey.exe" -OutFile $exe -UseBasicParsing
        Invoke-WebRequest "$baseUrl/volume.ahk" -OutFile $ahk -UseBasicParsing

        Start-Process $exe "`"$ahk`"" -WindowStyle Hidden

        Write-BKLog "Control de volumen BK instalado correctamente"
        return $true

    } catch {
        Write-BKLog "Error instalando Control de volumen BK: $_" "ERROR"
        return $false
    }
}

function Uninstall-BKVolumeControl {

    Get-Process AutoHotkey -ErrorAction SilentlyContinue | Stop-Process -Force
    Remove-Item "$env:LOCALAPPDATA\BlackConsole\tools\volume" -Recurse -Force -ErrorAction SilentlyContinue
    Write-BKLog "Control de volumen BK desinstalado"
    return $true
}

# ==================================================
# RADIAL APPS BK
# ==================================================

function Install-BKRadialApps {

    try {
        $tmpSkin = Join-Path $env:TEMP "BlackConsoleRadial_1.0.rmskin"
        $url = "https://raw.githubusercontent.com/fjesusdel/BK-Launcher/main/tools/radial/BlackConsoleRadial_1.0.rmskin"

        Write-Host "Descargando Radial Apps BK..."
        Invoke-WebRequest -Uri $url -OutFile $tmpSkin -UseBasicParsing

        if (-not (Test-Path $tmpSkin)) {
            Write-Host "ERROR: No se pudo descargar la skin." -ForegroundColor Red
            Pause
            return
        }

        Write-Host ""
        Write-Host "Abriendo instalador de Rainmeter..."
        Write-Host "Complete la instalación y cierre el instalador."
        Write-Host ""

        # 🔑 CLAVE: ejecutar el archivo LOCAL
        Start-Process -FilePath $tmpSkin -Wait

        Write-Host ""
        Write-Host "Instalación de Radial Apps BK finalizada."
        Pause

    } catch {
        Write-Host "Error instalando Radial Apps BK" -ForegroundColor Red
        Pause
    }
}

function Uninstall-BKRadialApps {
    Remove-Item "$env:USERPROFILE\Documents\Rainmeter\Skins\RadialLauncher" -Recurse -Force -ErrorAction SilentlyContinue
    Write-BKLog "Radial Apps BK desinstalado"
    return $true
}
