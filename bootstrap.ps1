# ==================================================
# BK-LAUNCHER - BOOTSTRAP ESTABLE MINIMO
# ==================================================
# - Solo eleva permisos
# - Ejecuta launcher LOCAL
# - NO toca runtime
# - NO descarga codigo
# ==================================================

function Test-IsAdministrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal   = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdministrator)) {
    Write-Host "Reiniciando BK-Launcher como administrador..." -ForegroundColor Yellow

    Start-Process powershell.exe `
        -Verb RunAs `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""

    exit
}

Write-Host ">>> BOOTSTRAP BK-LAUNCHER (ESTABLE) <<<" -ForegroundColor Cyan
Write-Host ""

# --------------------------------------------------
# RUTA DEL LAUNCHER LOCAL (AJUSTA SOLO ESTA LINEA)
# --------------------------------------------------

$LauncherPath = "$env:USERPROFILE\Documents\GitHub\BK-Launcher\launcher.ps1"

if (-not (Test-Path $LauncherPath)) {
    Write-Host "ERROR: launcher.ps1 no encontrado en:" -ForegroundColor Red
    Write-Host $LauncherPath
    exit 1
}

Write-Host "Lanzando Black Console..."
Write-Host ""

Start-Process powershell.exe `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$LauncherPath`"" `
    -WorkingDirectory (Split-Path $LauncherPath)
