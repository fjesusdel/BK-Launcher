# ==================================================
# BK-LAUNCHER - BOOTSTRAP (FINAL)
# ==================================================
# - Runtime limpio en cada ejecucion
# - Tools y data persistentes
# - NO usa iex para lanzar launcher
# - Bypass seguro de ExecutionPolicy
# ==================================================

$ErrorActionPreference = "Stop"

Write-Host ">>> BOOTSTRAP NUEVO (runtime / tools / data) <<<" -ForegroundColor Cyan
Write-Host ""

# -------------------------------
# RUTAS BASE
# -------------------------------

$BCBase    = Join-Path $env:LOCALAPPDATA "BlackConsole"
$BCRuntime = Join-Path $BCBase "runtime"
$BCTools   = Join-Path $BCBase "tools"
$BCData    = Join-Path $BCBase "data"

Write-Host "Base    : $BCBase"
Write-Host "Runtime : $BCRuntime"
Write-Host "Tools   : $BCTools"
Write-Host "Data    : $BCData"
Write-Host ""

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

New-Item -ItemType Directory -Path $BCRuntime -Force | Out-Null

# -------------------------------
# DESCARGAR REPOSITORIO
# -------------------------------

$repoZipUrl = "https://github.com/fjesusdel/BK-Launcher/archive/refs/heads/main.zip"
$tmpZip     = Join-Path $env:TEMP "bk-launcher-runtime.zip"

Write-Host "Descargando BK-Launcher..."
Invoke-WebRequest $repoZipUrl -OutFile $tmpZip -UseBasicParsing

# -------------------------------
# EXTRAER A RUNTIME
# -------------------------------

Write-Host "Extrayendo runtime..."
Expand-Archive $tmpZip $BCRuntime -Force
Remove-Item $tmpZip -Force

$inner = Get-ChildItem $BCRuntime | Where-Object { $_.PSIsContainer } | Select-Object -First 1
Get-ChildItem $inner.FullName | Move-Item -Destination $BCRuntime -Force
Remove-Item $inner.FullName -Recurse -Force

# -------------------------------
# LANZAR LAUNCHER (AQUÍ ESTÁ LA CLAVE)
# -------------------------------

$launcher = Join-Path $BCRuntime "launcher.ps1"

if (-not (Test-Path $launcher)) {
    Write-Host "ERROR: launcher.ps1 no encontrado en runtime." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Lanzando Black Console en nuevo proceso (ExecutionPolicy Bypass)..."
Write-Host ""

Start-Process -FilePath "powershell.exe" `
    -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$launcher`"" `
    -WorkingDirectory $BCRuntime `
    -Wait
