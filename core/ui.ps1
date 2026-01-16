# ==================================================
# BK-LAUNCHER - UI
# ==================================================
# Contiene todo lo relacionado con salida visual
# SOLO ASCII
# ==================================================

function Show-BlackConsoleBanner {

    Clear-Host

    Write-Host "=================================================="
    Write-Host "||                                              ||"
    Write-Host "||   BBBB   KK  KK                               ||"
    Write-Host "||   BB  B  KK KK                                ||"
    Write-Host "||   BBBB   KKK                                  ||"
    Write-Host "||   BB  B  KK KK                                ||"
    Write-Host "||   BBBB   KK  KK                               ||"
    Write-Host "||                                              ||"
    Write-Host "||              BLACK CONSOLE                    ||"
    Write-Host "||                                              ||"
    Write-Host "=================================================="
    Write-Host ""

    if ($Global:BKConfig) {
        Write-Host "Autor  : $($Global:BKConfig.Author)"
        Write-Host "Version: $($Global:BKConfig.Version)"
        Write-Host ""
    }

    if ($Global:StartupPhrases -and $Global:StartupPhrases.Count -gt 0) {
        $phrase = Get-Random -InputObject $Global:StartupPhrases
        Write-Host $phrase
        Write-Host ""
    }
}
