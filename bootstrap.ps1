# ==================================================
# BK-LAUNCHER - BOOTSTRAP FINAL CORRECTO
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
    Start-Process powershell.exe `
        -Verb RunAs `
        -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm https://raw.githubusercontent.com/fjesusdel/BK-Launcher/main/bootstrap.ps1 | iex`""
    return
}

try {

    Write-Host ">>> BOOTSTRAP BK-LAUNCHER <<<" -ForegroundColor Cyan
    Write-Host ""

    $Base = Join-Path $env:LOCALAPPDATA "BlackConsole"
    $Src  = Join-Path $Base "src"

    New-Item -ItemType Directory -Path $Base -Force | Out-Null

    # -------------------------------
    # LIMPIAR SRC
    # -------------------------------

    if (Test-Path $Src) {
        Remove-Item $Src -Recurse -Force
    }
    New-Item -ItemType Directory -Path $Src | Out-Null

    # -------------------------------
    # DESCARGA REPO
    # -------------------------------

    $zipUrl = "https://github.com/fjesusdel/BK-Launcher/archive/refs/heads/main.zip"
    $tmpZip = Join-Path $env:TEMP "bk-launcher.zip"

    Write-Host "Descargando BK-Launcher..."
    Invoke-WebRequest $zipUrl -OutFile $tmpZip -UseBasicParsing

    Write-Host "Extrayendo..."
    Expand-Archive $tmpZip $Src -Force
    Remove-Item $tmpZip -Force

    # Aplanar carpeta
    $inner = Get-ChildItem $Src | Where-Object { $_.PSIsContainer } | Select-Object -First 1
    Get-ChildItem $inner.FullName | Move-Item -Destination $Src -Force
    Remove-Item $inner.FullName -Recurse -Force

    # -------------------------------
    # LANZAR LAUNCHER
    # -------------------------------

    $launcher = Join-Path $Src "launcher.ps1"

    if (-not (Test-Path $launcher)) {
        Write-Host "ERROR: launcher.ps1 no encontrado" -ForegroundColor Red
        Pause
        return
    }

    Write-Host ""
    Write-Host "Lanzando Black Console..."
    Write-Host ""

    powershell.exe `
        -NoProfile `
        -NoExit `
        -ExecutionPolicy Bypass `
        -File "$launcher" `
        -WorkingDirectory $Src
}
catch {
    Write-Host ""
    Write-Host "ERROR CRITICO EN BOOTSTRAP" -ForegroundColor Red
    Write-Host $_
}
finally {
    Write-Host ""
    Write-Host "Bootstrap finalizado."
}
