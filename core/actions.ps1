# ==================================================
# BK-LAUNCHER - ACTIONS (STABLE v5)
# ==================================================

# -------------------------------
# UTILIDADES GENERALES
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

    if ([string]::IsNullOrWhiteSpace($Arguments)) {
        $proc = Start-Process -FilePath $FilePath -PassThru
    } else {
        $proc = Start-Process -FilePath $FilePath -ArgumentList $Arguments -PassThru
    }

    if ($proc) {
        Wait-Process -Id $proc.Id
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
        Write-Host "INSTALANDO: $($app.Name)"
        Write-Host ""

        $tmp = Join-Path $env:TEMP "$id-installer.exe"

        switch ($id) {
            "battlenet" {
                Invoke-BKDownload "https://www.battle.net/download/getInstallerForGame?os=win&gameProgram=BATTLENET_APP&version=Live" $tmp | Out-Null
                Start-BKInstaller $tmp
            }
            "chrome" {
                Invoke-BKDownload "https://www.google.com/chrome/?standalone=1&platform=win64" $tmp | Out-Null
                Start-BKInstaller $tmp "/silent /install"
            }
            "discord" {
                Invoke-BKDownload "https://discord.com/api/download?platform=win" $tmp | Out-Null
                Start-BKInstaller $tmp "/S"
            }
            "steam" {
                Invoke-BKDownload "https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe" $tmp | Out-Null
                Start-BKInstaller $tmp "/S"
            }
            "firefox" {
                Invoke-BKDownload "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=es-ES" $tmp | Out-Null
                Start-BKInstaller $tmp "-ms"
            }
            "7zip" {
                Invoke-BKDownload "https://www.7-zip.org/a/7z2301-x64.exe" $tmp | Out-Null
                Start-BKInstaller $tmp "/S"
            }
        }

        Remove-Item $tmp -Force -ErrorAction SilentlyContinue
        Pause
    }
}

# ==================================================
# CONTROL DE VOLUMEN BK (AISLADO Y SEGURO)
# ==================================================

function Test-BKVolumeControlInstalled {

    $baseDir = "C:\ProgramData\BlackConsole\Volume"
    $exe     = Join-Path $baseDir "AutoHotkey.exe"
    $ahk     = Join-Path $baseDir "volume.ahk"

    if (-not (Test-Path $exe)) { return $false }
    if (-not (Test-Path $ahk)) { return $false }

    $proc = Get-Process AutoHotkey -ErrorAction SilentlyContinue |
        Where-Object { $_.Path -eq $exe }

    return [bool]$proc
}

function Install-BKVolumeControl {

    if (Test-BKVolumeControlInstalled) {
        Write-Host ""
        Write-Host "Control de volumen BK ya esta INSTALADO." -ForegroundColor Yellow
        Write-Host "No es necesario reinstalarlo."
        Pause
        return
    }

    try {
        $baseDir = "C:\ProgramData\BlackConsole\Volume"
        $exe     = Join-Path $baseDir "AutoHotkey.exe"
        $ahk     = Join-Path $baseDir "volume.ahk"
        $url     = "https://raw.githubusercontent.com/fjesusdel/BK-Launcher/main/tools/volume"

        Write-Host "Instalando Control de volumen BK..."
        Write-Host ""

        New-Item -ItemType Directory -Path $baseDir -Force | Out-Null

        Invoke-WebRequest "$url/AutoHotkey.exe" -OutFile $exe -UseBasicParsing
        Invoke-WebRequest "$url/volume.ahk"     -OutFile $ahk -UseBasicParsing

        Start-Process -FilePath $exe -ArgumentList "`"$ahk`"" -WindowStyle Hidden

        Write-Host ""
        Write-Host "Control de volumen BK INSTALADO Y ACTIVO." -ForegroundColor Green
        Pause
    }
    catch {
        Write-Host ""
        Write-Host "No se pudo instalar el Control de volumen BK." -ForegroundColor Red
        Pause
    }
}

function Uninstall-BKVolumeControl {
    Get-Process AutoHotkey -ErrorAction SilentlyContinue | Stop-Process -Force
    Remove-Item "C:\ProgramData\BlackConsole\Volume" -Recurse -Force -ErrorAction SilentlyContinue
}

# ==================================================
# RADIAL APPS BK (NO TOCADO)
# ==================================================

function Get-BKRainmeterExe {
    $paths = @(
        "C:\Program Files\Rainmeter\Rainmeter.exe",
        "C:\Program Files (x86)\Rainmeter\Rainmeter.exe"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

function Install-BKRadialApps {

    $rainmeterExe = Get-BKRainmeterExe

    if (-not $rainmeterExe) {
        Write-Host "Rainmeter no detectado. Instalelo primero."
        Pause
        return
    }

    $skin = Join-Path $env:TEMP "BlackConsoleRadial_1.0.rmskin"
    Invoke-WebRequest "https://raw.githubusercontent.com/fjesusdel/BK-Launcher/main/tools/radial/BlackConsoleRadial_1.0.rmskin" `
        -OutFile $skin -UseBasicParsing

    Start-Process $skin
    Pause
}

function Uninstall-BKRadialApps {
    Remove-Item "$env:USERPROFILE\Documents\Rainmeter\Skins\RadialLauncher" -Recurse -Force -ErrorAction SilentlyContinue
}
