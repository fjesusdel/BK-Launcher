# ==================================================
# BK-LAUNCHER - LOGS
# ==================================================
# Gestion de logs del sistema
# ==================================================

$Global:BKLogDir  = Join-Path $env:LOCALAPPDATA "BlackConsole\logs"
$Global:BKLogFile = $null

function Initialize-BKLogs {

    if (-not (Test-Path $Global:BKLogDir)) {
        New-Item -ItemType Directory -Path $Global:BKLogDir | Out-Null
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $Global:BKLogFile = Join-Path $Global:BKLogDir "bklauncher_$timestamp.log"

    "==== BK Launcher Log ====" | Out-File $Global:BKLogFile -Encoding UTF8
    "Inicio: $(Get-Date)"     | Out-File $Global:BKLogFile -Append
    ""                         | Out-File $Global:BKLogFile -Append
}

function Write-BKLog {
    param (
        [string]$Message,
        [ValidateSet("INFO","WARN","ERROR")]
        [string]$Level = "INFO"
    )

    if (-not $Global:BKLogFile) { return }

    $line = "[{0}] [{1}] {2}" -f (Get-Date -Format "HH:mm:ss"), $Level, $Message
    $line | Out-File $Global:BKLogFile -Append -Encoding UTF8
}

function Get-LastBKLog {

    if (-not (Test-Path $Global:BKLogDir)) { return $null }

    Get-ChildItem $Global:BKLogDir -Filter "*.log" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
}

function Open-LastBKLog {

    $log = Get-LastBKLog
    if ($log) {
        Start-Process notepad.exe $log.FullName
    } else {
        Write-Host "No hay logs disponibles."
        Pause
    }
}

function Open-BKLogsFolder {

    if (Test-Path $Global:BKLogDir) {
        Start-Process explorer.exe $Global:BKLogDir
    } else {
        Write-Host "No existe la carpeta de logs."
        Pause
    }
}
