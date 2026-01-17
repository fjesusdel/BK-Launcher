# ==================================================
# BK-LAUNCHER - ACTIONS
# ==================================================
# Instalacion y desinstalacion de software
# Con manejo correcto de UninstallString
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

    $status = Get-BKApplicationsStatus | Where-Object { $_.Id -eq $Id }
    return ($status -and $status.Installed)
}

function Split-UninstallCommand {
    param ([string]$Command)

    if ($Command -match '^"([^"]+)"\s*(.*)$') {
        return @{
            FilePath = $matches[1]
            Arguments = $matches[2]
        }
    }

    if ($Command -match '^(\S+)\s+(.*)$') {
        return @{
            FilePath = $matches[1]
            Arguments = $matches[2]
        }
    }

    return @{
        FilePath = $Command
        Arguments = ""
    }
}

# ==================================================
# DESINSTALACION SOFTWARE (REPARADA DE VERDAD)
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

                    if ($_.DisplayName -and $_.DisplayName -like "*$($app.Name)*" -and $_.UninstallString) {

                        $parsed = Split-UninstallCommand $_.UninstallString
                        $exe = $parsed.FilePath
                        $args = $parsed.Arguments

                        Write-Host "Iniciando desinstalador..."
                        Write-Host ""

                        if ($exe -match "msiexec") {

                            if ($args -notmatch "/x") {
                                $args = $args -replace "/I", "/x"
                            }

                            Start-Process "msiexec.exe" "$args /qn" -Wait
                        }
                        else {
                            Write-Host "Esta aplicacion requiere desinstalacion manual."
                            Write-Host "Complete el proceso y cierre el instalador."
                            Start-Process -FilePath $exe -ArgumentList $args
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
