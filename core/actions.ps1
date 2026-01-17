# ==================================================
# BK-LAUNCHER - ACTIONS
# ==================================================
# Instalacion y desinstalacion silenciosa
# Incluye herramientas Black Console
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

# ==================================================
# INSTALACION SOFTWARE TERCEROS
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

            "chrome" {
                if (Invoke-BKDownload "https://www.google.com/chrome/?standalone=1&platform=win64" $tmp) {
                    Start-Process $tmp "/silent /install" -Wait
                }
            }

            "discord" {
                if (Invoke-BKDownload "https://discord.com/api/download?platform=win" $tmp) {
                    Start-Process $tmp "/S" -Wait
                }
            }

            "steam" {
                if (Invoke-BKDownload "https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe" $tmp) {
                    Start-Process $tmp "/S" -Wait
                }
            }

            "firefox" {
                if (Invoke-BKDownload "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=es-ES" $tmp) {
                    Start-Process $tmp "-ms" -Wait
                }
            }

            "7zip" {
                if (Invoke-BKDownload "https://www.7-zip.org/a/7z2301-x64.exe" $tmp) {
                    Start-Process $tmp "/S" -Wait
                }
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

        if ($app.Type -eq "windows") {
            Get-AppxPackage |
                Where-Object { $_.Name -like "*$($app.Id)*" } |
                Remove-AppxPackage -ErrorAction SilentlyContinue
            continue
        }

        $keys = @(
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
            "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        )

        foreach ($key in $keys) {
            Get-ItemProperty $key -ErrorAction SilentlyContinue | ForEach-Object {
                if ($_.DisplayName -and $_.DisplayName -like "*$($app.Name)*") {
                    if ($_.UninstallString) {
                        Start-Process "cmd.exe" "/c $($_.UninstallString) /quiet" -Wait
                    }
                }
            }
        }
    }
}

# ==================================================
# CONTROL DE VOLUMEN BK
# ==================================================

function Install-BKVolumeControl {

    try {
        $sourceDir = Join-Path $PSScriptRoot "..\tools\volume"
        $targetDir = Join-Path $env:LOCALAPPDATA "BlackConsole\tools\volume"

        $exe = Join-Path $targetDir "AutoHotkey.exe"
        $ahk = Join-Path $targetDir "volumen.ahk"

        # 1. Validar origen
        if (-not (Test-Path $sourceDir)) {
            Write-BKLog "Origen Control Volumen no encontrado" "ERROR"
            return $false
        }

        # 2. Crear carpeta destino
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

        # 3. Copiar binarios SIEMPRE
        Copy-Item "$sourceDir\*" $targetDir -Recurse -Force

        # 4. Validar archivos críticos
        if (-not (Test-Path $exe) -or -not (Test-Path $ahk)) {
            Write-BKLog "AutoHotkey o volumen.ahk no encontrados tras copiar" "ERROR"
            return $false
        }

        # 5. Lanzar proceso
        Start-Process $exe "`"$ahk`"" -WindowStyle Hidden

        # 6. Registrar inicio
        Set-ItemProperty `
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" `
            "ControlVolumenBK" "`"$exe`" `"$ahk`""

        Write-BKLog "Control de volumen BK instalado correctamente"
        return $true

    } catch {
        Write-BKLog "Error instalando Control de volumen BK: $_" "ERROR"
        return $false
    }
}

function Uninstall-BKVolumeControl {

    try {
        # 1. Matar procesos AutoHotkey asociados
        Get-Process AutoHotkey -ErrorAction SilentlyContinue | Stop-Process -Force

        # 2. Eliminar carpeta
        $targetDir = Join-Path $env:LOCALAPPDATA "BlackConsole\tools\volume"
        Remove-Item $targetDir -Recurse -Force -ErrorAction SilentlyContinue

        # 3. Quitar inicio automático
        Remove-ItemProperty `
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" `
            "ControlVolumenBK" -ErrorAction SilentlyContinue

        Write-BKLog "Control de volumen BK desinstalado completamente"
        return $true

    } catch {
        Write-BKLog "Error desinstalando Control de volumen BK: $_" "ERROR"
        return $false
    }
}


# ==================================================
# RADIAL APPS BK (RAINMETER)
# ==================================================

function Get-BKRainmeterExe {

    if (Test-Path "C:\Program Files\Rainmeter\Rainmeter.exe") {
        return "C:\Program Files\Rainmeter\Rainmeter.exe"
    }

    if (Test-Path "C:\Program Files (x86)\Rainmeter\Rainmeter.exe") {
        return "C:\Program Files (x86)\Rainmeter\Rainmeter.exe"
    }

    return $null
}

function Install-BKRadialApps {

    try {
        Write-Host "Instalando Radial Apps BK..."

        # ---- 1. Rainmeter ----
        $rainmeterExe = Get-BKRainmeterExe

        if (-not $rainmeterExe) {

            Write-Host "Instalando Rainmeter..."
            $tmp = Join-Path $env:TEMP "RainmeterInstaller.exe"

            if (-not (Invoke-BKDownload "https://www.rainmeter.net/releases/Rainmeter-4.5.18.exe" $tmp)) {
                Write-BKLog "No se pudo descargar Rainmeter" "ERROR"
                return $false
            }

            Start-Process $tmp "/S" -Wait
            Start-Sleep -Seconds 2
            Remove-Item $tmp -ErrorAction SilentlyContinue

            $rainmeterExe = Get-BKRainmeterExe
            if (-not $rainmeterExe) {
                Write-BKLog "Rainmeter no se instaló correctamente" "ERROR"
                return $false
            }
        }

        # ---- 2. Descargar RMSKIN ----
        $radialDir = Join-Path $env:TEMP "BK-Radial"
        $rmskin    = Join-Path $radialDir "BlackConsoleRadial_1.0.rmskin"

        if (-not (Test-Path $radialDir)) {
            New-Item -ItemType Directory -Path $radialDir | Out-Null
        }

        if (-not (Test-Path $rmskin)) {
            Write-Host "Descargando Radial Apps BK..."
            if (-not (Invoke-BKDownload `
                "https://raw.githubusercontent.com/fjesusdel/BK-Launcher/main/tools/radial/BlackConsoleRadial_1.0.rmskin" `
                $rmskin)) {
                Write-BKLog "No se pudo descargar la skin radial" "ERROR"
                return $false
            }
        }

        # ---- 3. Lanzar instalador ----
        Write-Host "Abriendo instalador de la skin..."
        Start-Process $rmskin

        Write-BKLog "Radial Apps BK instalado correctamente"
        return $true

    } catch {
        Write-BKLog "Error instalando Radial Apps BK: $_" "ERROR"
        return $false
    }
}

function Uninstall-BKRadialApps {

    try {
        $skinPath = Join-Path $env:USERPROFILE "Documents\Rainmeter\Skins\RadialLauncher"

        if (Test-Path $skinPath) {
            Remove-Item $skinPath -Recurse -Force
        }

        $rainmeterExe = Get-BKRainmeterExe
        if ($rainmeterExe) {
            & $rainmeterExe "!RefreshApp"
        }

        Write-BKLog "Radial Apps BK desinstalado completamente"
        return $true

    } catch {
        Write-BKLog "Error desinstalando Radial Apps BK: $_" "ERROR"
        return $false
    }
}
