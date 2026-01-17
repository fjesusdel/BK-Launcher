# ==================================================
# BK-LAUNCHER - BOOTSTRAP
# ==================================================
# - Descarga limpia del runtime en cada ejecucion
# - Mantiene tools y data persistentes
# - Evita codigo zombie
# - No modifica ExecutionPolicy del sistema
# ==================================================

$ErrorActionPreference = "Stop"

Write-Host ">>> BOOTSTRAP NUEVO CON RUNTIME / TOOLS / DATA <<<" -ForegroundColor Cyan
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

Write-Host "Descargando BK-Launcher desde GitHub..."
Invoke-WebRequest $repoZipUrl -OutFile $tmpZip -UseBasicParsing

# -------------------------------
# EXTRAER A RUNTIME
# -------------------------------

Write-Host "Extrayendo runtime..."
Expand-Archive $tmpZip $BCRuntime -Force
Remove-Item $tmpZip -Force

# El ZIP crea una carpeta interna (BK-Launcher-main)
$inner = Get-ChildItem $BCRuntime | Where-Object { $_.PSIsContainer } | Select-Object -First 1
Get-ChildItem $inner.FullName | Move-Item -Destination $BCRuntime -Force
Remove-Item $inner.FullName -Recurse -Force

# -------------------------------
# LANZAR LAUNCHER (BYPASS POLICY)
# -------------------------------

$launcher = Join-Path $BCRuntime "launcher.ps1"

if (-not (Test-Path $launcher)) {
    Write-Host "ERROR: launcher.ps1 no encontrado en runtime." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Lanzando Black Console desde runtime..."
Write-Host "(ExecutionPolicy Bypass solo para este proceso)"
Write-Host ""

Start-Process powershell.exe `
    -ArgumentList "-ExecutionPolicy Bypass -File `"$launcher`"" `
    -Wait
