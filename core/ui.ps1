# ==================================================
# BK-LAUNCHER - UI
# ==================================================
# Contiene todo lo relacionado con salida visual
# SOLO ASCII
# ==================================================

# -------------------------------
# Separador visual estándar
# -------------------------------
function Show-Separator {
    Write-Host "========================================" -ForegroundColor DarkGray
}

# -------------------------------
# Escritura de estados con iconos ASCII
# -------------------------------
function Write-Status {
    param (
        [string]$Icon,
        [string]$Message,
        [ConsoleColor]$Color = "White"
    )

    Write-Host "[$Icon] $Message" -ForegroundColor $Color
}

# -------------------------------
# Banner principal Black Console
# -------------------------------
function Show-BlackConsoleBanner {

    Clear-Host

    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "||                                              ||" -ForegroundColor Cyan
    Write-Host "||   BBBB   KK  KK                               ||" -ForegroundColor Cyan
    Write-Host "||   BB  B  KK KK                                ||" -ForegroundColor Cyan
    Write-Host "||   BBBB   KKK                                  ||" -ForegroundColor Cyan
    Write-Host "||   BB  B  KK KK                                ||" -ForegroundColor Cyan
    Write-Host "||   BBBB   KK  KK                               ||" -ForegroundColor Cyan
    Write-Host "||                                              ||" -ForegroundColor Cyan
    Write-Host "||              BLACK CONSOLE                    ||" -ForegroundColor Cyan
    Write-Host "||                                              ||" -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host ""

    if ($Global:BKConfig) {
        Write-Host "Autor  : $($Global:BKConfig.Author)" -ForegroundColor Gray
        Write-Host "Version: $($Global:BKConfig.Version)" -ForegroundColor Gray
        Write-Host ""
    }

    if ($Global:StartupPhrases -and $Global:StartupPhrases.Count -gt 0) {
        $phrase = Get-Random -InputObject $Global:StartupPhrases
        Write-Host $phrase -ForegroundColor DarkGray
        Write-Host ""
    }

    Show-Separator
}
