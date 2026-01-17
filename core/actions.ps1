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
# CONTROL DE VOLUMEN BK
# ==================================================

function Install-BKVolumeControl {

    try {
        $sourceDir = Join-Path $PSScriptRoot "..\tools\volume"
        $targetDir = Join-Path $env:LOCALAPPDATA "BlackConsole\tools\volume"

        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        Copy-Item "$sourceDir\*" $targetDir -Recurse -Force

        $exe = Join-Path $targetDir "AutoHotkey.exe"
        $ahk = Join-Path $targetDir "volumen.ahk"

        Start-Process $exe "`"$ahk`"" -WindowStyle Hidden

        Set-ItemProperty `
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" `
            "ControlVolumenBK" "`"$exe`" `"$ahk`""

        return $true
    } catch {
        return $false
    }
}

function Uninstall-BKVolumeControl {

    Remove-Item `
        (Join-Path $env:LOCALAPPDATA "BlackConsole\tools\volume") `
        -Recurse -Force -ErrorAction SilentlyContinue

    Remove-ItemProperty `
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" `
        "ControlVolumenBK" -ErrorAction SilentlyContinue

    return $true
}

# ==================================================
# RADIAL APPS BK (RAINMETER)
# ==================================================

function Get-BKRainmeterExe {

    if (Test-Path "$env:ProgramFiles\Rainmeter\Rainmeter.exe") {
        return "$env:ProgramFiles\Rainmeter\Rainmeter.exe"
    }

    if (Test-Path "$env:ProgramFiles(x86)\Rainmeter\Rainmeter.exe") {
        return "$env:ProgramFiles(x86)\Rainmeter\Rainmeter.exe"
    }

    return $null
}

function Install-BKRadialApps {

    try {
        # 1. Detectar Rainmeter
        $rainmeterExe = Get-BKRainmeterExe

        if (-not $rainmeterExe) {
            Write-Host "Instalando Rainmeter..."

            $tmp = Join-Path $env:TEMP "RainmeterInstaller.exe"
            $url = "https://www.rainmeter.net/releases/Rainmeter-4.5.18.exe"

            if (-not (Invoke-BKDownload $url $tmp)) {
                Write-BKLog "No se pudo descargar Rainmeter" "ERROR"
                return $false
            }

            Start-Process $tmp "/S" -Wait
            Start-Sleep -Seconds 2
            Remove-Item $tmp -Force -ErrorAction SilentlyContinue

            $rainmeterExe = Get-BKRainmeterExe
            if (-not $rainmeterExe) {
                Write-BKLog "Rainmeter no se instalo correctamente" "ERROR"
                return $false
            }
        }

        # 2. Lanzar Rainmeter si no esta corriendo
        if (-not (Get-Process Rainmeter -ErrorAction SilentlyContinue)) {
            Start-Process $rainmeterExe
            Start-Sleep -Seconds 2
        }

        # 3. Instalar la skin
        $rmskin = Join-Path $PSScriptRoot "..\tools\radial\BlackConsoleRadial_1.0.rmskin"

        if (-not (Test-Path $rmskin)) {
            Write-BKLog "RMSKIN no encontrado" "ERROR"
            return $false
        }

        Start-Process $rmskin
        Start-Sleep -Seconds 3

        # 4. Activar skin correctamente (ESTA ERA LA CLAVE)
        & $rainmeterExe `
            !ActivateConfig "RadialLauncher" "Radial.ini"

        Write-BKLog "Radial Apps BK instalado y activo correctamente"
        return $true

    } catch {
        Write-BKLog "Error instalando Radial Apps BK" "ERROR"
        return $false
    }
}

function Uninstall-BKRadialApps {

    $skinPath = Join-Path $env:USERPROFILE "Documents\Rainmeter\Skins\RadialLauncher"
    if (Test-Path $skinPath) {
        Remove-Item $skinPath -Recurse -Force
    }

    return $true
}
