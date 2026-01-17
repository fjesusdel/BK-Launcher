# ==================================================
# BK-LAUNCHER - BOOTSTRAP FINAL ANTI-CIERRE
# ==================================================

function Test-IsAdministrator {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# -------------------------------
# AUTO-ELEVACION
# -------------------------------

if (-not (Test-IsAdministrator)) {
    Write-Host "Reiniciando BK-Launcher como administrador..." -ForegroundColor Yellow

    Start-Process powershell.exe `
        -Verb RunAs `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://raw.githubusercontent.com/fjesusdel/BK-Launcher/main/bootstrap.ps1 | iex`""

    return
}

# -------------------------------
# EJECUCION SEGURA
# -------------------------------

try {

    Write-Host ">>> BOOTSTRAP BK-LAUNCHER <<<" -ForegroundColor Cyan
    Write-Host ""

    $Base = Join-Path $env:LOCALAPPDATA "BlackConsole"

    if (-not (Test-Path $Base)) {
        New-Item -ItemType Directory -Path $Base | Out-Null
    }

    $Launcher = Join-Path $Base "launcher.ps1"

    if (-not (Test-Path $Launcher)) {
        Write-Host "ERROR: launcher.ps1 no encontrado en:" -ForegroundColor Red
        Write-Host $Base
        Write-Host ""
        Write-Host "¿Se ha descargado correctamente el repositorio?"
        Write-Host ""
        Pause
        return
    }

    Write-Host "Lanzando Black Console..."
    Write-Host ""

    # 🔑 CLAVE ABSOLUTA: MISMA CONSOLA + NOEXIT
    powershell.exe `
        -NoProfile `
        -NoExit `
        -ExecutionPolicy Bypass `
        -File "$Launcher"

}
catch {
    Write-Host ""
    Write-Host "ERROR CRITICO EN BOOTSTRAP" -ForegroundColor Red
    Write-Host $_
    Write-Host ""
}
finally {
    Write-Host ""
    Write-Host "Bootstrap finalizado. Pulse ENTER para cerrar."
    Read-Host
}
