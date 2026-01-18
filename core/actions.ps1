# ==================================================
# BK-LAUNCHER - ACTIONS (SAFE v3 - APPS PROPIAS AISLADAS)
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

    if ([string]::IsNullOrWhiteSpace($Arguments)) {
        $proc = Start-Process -FilePath $FilePath -PassThru
    } else {
        $proc = Start-Process -FilePath $FilePath -ArgumentList $Arguments -PassThru
    }

    if ($proc -and $proc.Id) {
        Wait-Process -Id $proc.Id
    }

    Write-Host "Instalador finalizado."
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
# DESINSTALACION SOFTWARE TERCEROS
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
# CONTROL DE VOLUMEN BK (APP PROPIA AISLADA)
# ==================================================

# ==================================================
# CONTROL DE VOLUMEN BK (FIX DEFINITIVO)
# ==================================================

function Install-BKVolumeControl {

    try {
        $baseDir   = Join-Path $env:LOCALAPPDATA "BlackConsole\tools\volume"
        $exePath   = Join-Path $baseDir "AutoHotkey.exe"
        $scriptAHK = Join-Path $baseDir "volume.ahk"

        $baseUrl = "https://raw.githubusercontent.com/fjesusdel/BK-Launcher/main/tools/volume"

        Write-Host "Instalando Control de volumen BK..."
        Write-Host ""

        # Crear carpeta
        New-Item -ItemType Directory -Path $baseDir -Force | Out-Null

        # Descargar archivos
        Invoke-WebRequest "$baseUrl/AutoHotkey.exe" -OutFile $exePath -UseBasicParsing
        Invoke-WebRequest "$baseUrl/volume.ahk"     -OutFile $scriptAHK -UseBasicParsing

        if (-not (Test-Path $exePath) -or -not (Test-Path $scriptAHK)) {
            Write-Host "ERROR: Archivos de volumen incompletos." -ForegroundColor Red
            Pause
            return $false
        }

        # Lanzar AutoHotkey DESACOPLADO
        Start-Process `
            -FilePath $exePath `
            -ArgumentList "`"$scriptAHK`"" `
            -WindowStyle Hidden

        Start-Sleep -Seconds 1

        # Verificar que el proceso está activo
        $ahkProc = Get-Process AutoHotkey -ErrorAction SilentlyContinue
        if (-not $ahkProc) {
            Write-Host "ERROR: El servicio de volumen no se ha iniciado." -ForegroundColor Red
            Pause
            return $false
        }

        # -------------------------------
        # REGISTRAR ARRANQUE CON WINDOWS
        # -------------------------------

        $startup = [Environment]::GetFolderPath("Startup")
        $lnkPath = Join-Path $startup "BlackConsole Volume.lnk"

        $wsh = New-Object -ComObject WScript.Shell
        $lnk = $wsh.CreateShortcut($lnkPath)
        $lnk.TargetPath = $exePath
        $lnk.Arguments  = "`"$scriptAHK`""
        $lnk.WorkingDirectory = $baseDir
        $lnk.WindowStyle = 7
        $lnk.Save()

        Write-Host ""
        Write-Host "Control de volumen BK INSTALADO Y ACTIVO." -ForegroundColor Green
        Write-Host "Se iniciará automáticamente con Windows."
        Pause

        return $true
    }
    catch {
        Write-Host "Error instalando Control de volumen BK" -ForegroundColor Red
        Write-Host $_
        Pause
        return $false
    }
}


function Uninstall-BKVolumeControl {

    try {
        $runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
        Remove-ItemProperty -Path $runKey -Name "BlackConsoleVolume" -ErrorAction SilentlyContinue

        Get-Process AutoHotkey -ErrorAction SilentlyContinue | Stop-Process -Force
        Remove-Item "C:\Program Files\BlackConsole\Volume" -Recurse -Force -ErrorAction SilentlyContinue

        Write-BKLog "Control de volumen BK desinstalado"
        Write-Host "Control de volumen BK DESINSTALADO." -ForegroundColor Yellow
        return $true

    } catch {
        Write-BKLog "Error desinstalando Control de volumen BK: $_" "ERROR"
        Write-Host "Error desinstalando Control de volumen BK." -ForegroundColor Red
        return $false
    }
}

# ==================================================# ==================================================
# BK-LAUNCHER - ACTIONS (STABLE - VOLUME FIX)
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

    if ([string]::IsNullOrWhiteSpace($Arguments)) {
        $proc = Start-Process -FilePath $FilePath -PassThru
    } else {
        $proc = Start-Process -FilePath $FilePath -ArgumentList $Arguments -PassThru
    }

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
            Write-Host "No se encontro desinstalador automatico."
        }

        Write-Host ""
        Write-Host "Proceso terminado para $($app.Name)."
        Pause
    }
}

# ==================================================
# CONTROL DE VOLUMEN BK (UBICACION SEGURA)
# ==================================================

function Install-BKVolumeControl {

    try {
        $targetDir = "C:\ProgramData\BlackConsole\Volume"
        $exe = Join-Path $targetDir "AutoHotkey.exe"
        $ahk = Join-Path $targetDir "volume.ahk"

        $baseUrl = "https://raw.githubusercontent.com/fjesusdel/BK-Launcher/main/tools/volume"

        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

        Invoke-WebRequest "$baseUrl/AutoHotkey.exe" -OutFile $exe -UseBasicParsing
        Invoke-WebRequest "$baseUrl/volume.ahk" -OutFile $ahk -UseBasicParsing

        Start-Process $exe "`"$ahk`"" -WindowStyle Hidden

        Write-Host "Control de volumen BK INSTALADO."
        Write-BKLog "Control de volumen BK instalado correctamente"
        Pause
        return $true

    } catch {
        Write-Host "Error instalando Control de volumen BK" -ForegroundColor Red
        Write-BKLog "Error instalando Control de volumen BK: $_" "ERROR"
        Pause
        return $false
    }
}

function Uninstall-BKVolumeControl {

    Get-Process AutoHotkey -ErrorAction SilentlyContinue | Stop-Process -Force
    Remove-Item "C:\ProgramData\BlackConsole\Volume" -Recurse -Force -ErrorAction SilentlyContinue
    Write-BKLog "Control de volumen BK desinstalado"
    return $true
}

# ==================================================
# RADIAL APPS BK (SE TOCA DESPUES)
# ==================================================

function Install-BKRadialApps {

    try {
        $tmpSkin = Join-Path $env:TEMP "BlackConsoleRadial_1.0.rmskin"
        $url = "https://raw.githubusercontent.com/fjesusdel/BK-Launcher/main/tools/radial/BlackConsoleRadial_1.0.rmskin"

        Write-Host "Descargando Radial Apps BK..."
        Invoke-WebRequest -Uri $url -OutFile $tmpSkin -UseBasicParsing

        Write-Host ""
        Write-Host "Abriendo instalador de Rainmeter..."
        Start-Process -FilePath $tmpSkin

        Pause
        Write-Host "Radial Apps BK instalado."
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

# RADIAL APPS BK (APP PROPIA)
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
        Write-Host "Se abrira el instalador de Rainmeter."
        Write-Host "Complete la instalacion y vuelva aqui."
        Write-Host ""

        Start-Process -FilePath $tmpSkin
        Pause

        Write-Host ""
        Write-Host "Radial Apps BK instalado."
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
