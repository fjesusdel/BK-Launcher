Write-Host ">>> BOOTSTRAP NUEVO CON RUNTIME <<<" -ForegroundColor Cyan
Pause

# ==================================================
# BK-LAUNCHER - BOOTSTRAP
# ==================================================
# Descarga limpia del runtime
# Mantiene tools y data persistentes
# ==================================================

$ErrorActionPreference = "Stop"

# -------------------------------
# RUTAS BASE
# -------------------------------

$BCBase    = Join-Path $env:LOCALAPPDATA "BlackConsole"
$BCRuntime = Join-Path $BCBase "runtime"
$BCTools   = Join-Path $BCBase "tools"
$BCData    = Join-Path $BCBase "data"

# -------------------------------
# CREAR ESTRUCTURA BASE
# -------------------------------

New-Item -ItemType Directory -Path $BCBase,$BCTools,$BCData -Force | Out-Null

# -------------------------------
# LIMPIAR SOLO RUNTIME
# -------------------------------

if (Test-Path $BCRuntime) {
    Write-Host "Limpiando runtime anterior..."
    Remove-Item $BCRuntime -Recurse -Force -ErrorAction SilentlyContinue
}

New-Item -ItemType Directory -Path $BCRuntime | Out-Null

# -------------------------------
# DESCARGAR REPOSITORIO
# -------------------------------

$repoZip = "https://github.com/fjesusdel/BK-Launcher/archive/refs/heads/main.zip"
$tmpZip  = Join-Path $env:TEMP "bk-launcher-runtime.zip"

Write-Host "Descargando BK-Launcher..."
Invoke-WebRequest $repoZip -OutFile $tmpZip -UseBasicParsing

# -------------------------------
# EXTRAER A RUNTIME
# -------------------------------

Expand-Archive $tmpZip $BCRuntime -Force
Remove-Item $tmpZip -Force

# Ajustar carpeta interna del ZIP
$inner = Get-ChildItem $BCRuntime | Where-Object { $_.PSIsContainer } | Select-Object -First 1
Get-ChildItem $inner.FullName | Move-Item -Destination $BCRuntime -Force
Remove-Item $inner.FullName -Recurse -Force

# -------------------------------
# LANZAR LAUNCHER
# -------------------------------

$launcher = Join-Path $BCRuntime "launcher.ps1"

Write-Host "Lanzando Black Console..."
& $launcher
