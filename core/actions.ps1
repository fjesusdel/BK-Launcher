# ==================================================
# BK-LAUNCHER - ACTIONS
# ==================================================
# Instalacion y desinstalacion de software
# Con validacion REAL post-operacion
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

function Test-BKAppInstalled {
    param ([string]$Id)

    $app = Get-BKApplicationById $Id
    if (-not $app) { return $false }

    $status = Get-BKApplicationsStatus | Where-Object { $_.Id -eq $Id }
    if (-not $status) { return $false }

    return $status.Installed
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
# DESINSTALACION SOFTWARE (REPARADA)
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

        # -------------------------------
        # APPS WINDOWS (AppX)
        # -------------------------------
        if ($app.Type -eq "windows") {

            Get-AppxPackage |
                Where-Object { $_.Name -like "*$($app.Id)*" } |
                Remove-AppxPackage -ErrorAction SilentlyContinue

            Start-Sleep -Seconds 2
            $uninstalled = -not (Test-BKAppInstalled $id)
        }

        else {

            $keys = @(
                "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
                "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
            )

            foreach ($key in $keys) {

                Get-ItemProperty $key -ErrorAction SilentlyContinue | ForEach-Object {

                    if ($_.DisplayName -and $_.DisplayName -like "*$($app.Name)*") {

                        if (-not $_.UninstallString) { return }

                        $cmd = $_.UninstallString.Trim()

                        Write-Host "Iniciando desinstalador..."
                        Write-Host ""

                        # MSI
                        if ($cmd -match "msiexec") {

                            if ($cmd -notmatch "/x") {
                                $cmd = $cmd -replace "/I", "/x"
                            }

                            Start-Process "msiexec.exe" "$cmd /qn" -Wait
                        }
                        else {
                            # NO silencioso → interactivo
                            Write-Host "Esta aplicacion requiere desinstalacion manual."
                            Write-Host "Complete el proceso y cierre el instalador."
                            Start-Process $cmd
                            Pause
                        }
                    }
                }
            }

            Start-Sleep -Seconds 2
            $uninstalled = -not (Test-BKAppInstalled $id)
        }

        # -------------------------------
        # RESULTADO REAL
        # -------------------------------
        Write-Host ""
        if ($uninstalled) {
            Write-Host "[ OK ] Aplicacion desinstalada correctamente." -ForegroundColor Green
            Write-BKLog "$($app.Name) desinstalada correctamente"
        }
        else {
            Write-Host "[ !! ] La aplicacion NO se ha desinstalado." -ForegroundColor Yellow
            Write-Host "Puede requerir intervencion manual."
            Write-BKLog "$($app.Name) NO se desinstalo" "WARN"
        }

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

        Set-ItemProperty `
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" `
            "ControlVolumenBK" "`"$exe`" `"$ahk`""

        Write-BKLog "Control de volumen BK instalado"
        return $true
    }
    catch {
        Write-BKLog "Error instalando Control de volumen BK: $_" "ERROR"
        return $false
    }
}

function Uninstall-BKVolumeControl {
    try {
        Get-Process AutoHotkey -ErrorAction SilentlyContinue | Stop-Process -Force
        Remove-Item (Join-Path $env:LOCALAPPDATA "BlackConsole\tools\volume") -Recurse -Force -ErrorAction SilentlyContinue

        Remove-ItemProperty `
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" `
            "ControlVolumenBK" -ErrorAction SilentlyContinue

        Write-BKLog "Control de volumen BK desinstalado"
        return $true
    }
    catch {
        Write-BKLog "Error desinstalando Control de volumen BK: $_" "ERROR"
        return $false
    }
}
