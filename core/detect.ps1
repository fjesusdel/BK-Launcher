# ==================================================
# BK-LAUNCHER - DETECT
# ==================================================
# Deteccion fiable de aplicaciones instaladas
# - Soporta ejecucion con y sin administrador
# - Incluye caso especial Discord
# - MODO USUARIO para apps de Windows (UWP)
# - Soporte apps propias BK (volume / radial)
# - NUNCA muestra errores en pantalla
# ==================================================

# -------------------------------
# UTIL: ES ADMIN?
# -------------------------------

function Test-BKIsAdministrator {
    try {
        $id = [Security.Principal.WindowsIdentity]::GetCurrent()
        $p  = New-Object Security.Principal.WindowsPrincipal($id)
        return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        return $false
    }
}

# -------------------------------
# DISPATCH PRINCIPAL
# -------------------------------

function Test-BKApplicationInstalled {
    param ([hashtable]$App)

    # Apps propias Black Console
    if ($App.Type -eq "bktool") {
        return Test-BKBuiltInInstalled $App
    }

    # Caso especial Discord
    if ($App.Id -eq "discord") {
        return Test-BKDiscordInstalled
    }

    switch ($App.Type) {
        "thirdparty" { return Test-BKThirdPartyInstalled $App }
        "windows"    { return Test-BKWindowsAppInstalled $App }
        default      { return $false }
    }
}

# -------------------------------
# APPS PROPIAS BK
# -------------------------------

function Test-BKBuiltInInstalled {
    param ([hashtable]$App)

    switch ($App.Id) {

        "bk-volume" {
            $base = Join-Path $env:LOCALAPPDATA "BlackConsole\tools\volume"
            $ahk  = Join-Path $base "volume.ahk"

            return (Test-Path $base -and Test-Path $ahk)
        }

        "bk-radial" {
            $radialPath = Join-Path `
                $env:USERPROFILE `
                "Documents\Rainmeter\Skins\RadialLauncher"

            return (Test-Path $radialPath)
        }

        default {
            return $false
        }
    }
}

# -------------------------------
# DISCORD (CASO ESPECIAL)
# -------------------------------

function Test-BKDiscordInstalled {

    $discordPath = Join-Path $env:LOCALAPPDATA "Discord"

    if (Test-Path $discordPath) {
        if (Test-Path (Join-Path $discordPath "Update.exe")) {
            return $true
        }

        $apps = Get-ChildItem $discordPath -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like "app-*" }

        if ($apps) {
            return $true
        }
    }

    return $false
}

# -------------------------------
# TERCEROS (GENERICA)
# -------------------------------

function Test-BKThirdPartyInstalled {
    param ([hashtable]$App)

    $name = $App.Name.ToLower()

    $keys = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($key in $keys) {
        try {
            Get-ItemProperty $key -ErrorAction SilentlyContinue | ForEach-Object {
                if ($_.DisplayName -and $_.DisplayName.ToLower().Contains($name)) {
                    return $true
                }
            }
        } catch {}
    }

    $paths = @($env:ProgramFiles, ${env:ProgramFiles(x86)})

    foreach ($base in $paths) {
        if (-not $base) { continue }
        try {
            Get-ChildItem $base -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                if ($_.Name.ToLower().Contains($name)) {
                    return $true
                }
            }
        } catch {}
    }

    return $false
}

# -------------------------------
# APPS DE WINDOWS (UWP) — MODO USUARIO
# -------------------------------

function Test-BKWindowsAppInstalled {
    param ([hashtable]$App)

    try {
        $packages = Get-AppxPackage -ErrorAction Stop

        foreach ($pkg in $packages) {
            if ($pkg.Name -like "*$($App.Id)*") {
                return $true
            }
        }
    } catch {
        return $false
    }

    return $false
}

# -------------------------------
# ESTADO GLOBAL
# -------------------------------

function Get-BKApplicationsStatus {

    $result = @()

    foreach ($app in Get-BKApplications) {

        $installed = Test-BKApplicationInstalled $app

        $result += [PSCustomObject]@{
            Id        = $app.Id
            Name      = $app.Name
            Type      = $app.Type
            Installed = [bool]$installed
        }
    }

    return $result
}
