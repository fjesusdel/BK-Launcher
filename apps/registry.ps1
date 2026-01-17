# ==================================================
# BK-LAUNCHER - APPLICATION REGISTRY
# ==================================================
# Responsabilidad:
# - Declarar TODAS las aplicaciones del sistema
# - No contiene logica de instalacion ni deteccion
# - Solo datos estructurados
# ==================================================

$Global:BKApplications = @(
    @{
        Id          = "chrome"
        Name        = "Google Chrome"
        Type        = "thirdparty"
        Description = "Navegador web de Google"
    },
    @{
        Id          = "winrar"
        Name        = "WinRAR"
        Type        = "thirdparty"
        Description = "Compresor de archivos"
    },
    @{
        Id          = "discord"
        Name        = "Discord"
        Type        = "thirdparty"
        Description = "Plataforma de comunicacion por voz y texto"
    },
    @{
        Id          = "virtualbox"
        Name        = "VirtualBox"
        Type        = "thirdparty"
        Description = "Virtualizacion de sistemas operativos"
    },
    @{
        Id          = "steam"
        Name        = "Steam"
        Type        = "thirdparty"
        Description = "Plataforma de videojuegos"
    },
    @{
        Id          = "battlenet"
        Name        = "Battle.net"
        Type        = "thirdparty"
        Description = "Plataforma de Blizzard"
    },
    @{
        Id          = "firefox"
        Name        = "Mozilla Firefox"
        Type        = "thirdparty"
        Description = "Navegador web alternativo"
    },
    @{
        Id          = "7zip"
        Name        = "7-Zip"
        Type        = "thirdparty"
        Description = "Compresor de archivos gratuito"
    },
    @{
        Id          = "nvidiaapp"
        Name        = "NVIDIA App"
        Type        = "thirdparty"
        Description = "Herramienta de gestion de drivers NVIDIA"
    },
    @{
        Id          = "cura"
        Name        = "Ultimaker Cura"
        Type        = "thirdparty"
        Description = "Software de impresion 3D"
    },

    # --------------------------------------------
    # APPS PREINSTALADAS DE WINDOWS (NO CRITICAS)
    # --------------------------------------------

    @{
        Id          = "xboxapp"
        Name        = "Xbox App"
        Type        = "windows"
        Description = "Aplicacion de Xbox para Windows"
    },
    @{
        Id          = "xboxgamebar"
        Name        = "Xbox Game Bar"
        Type        = "windows"
        Description = "Superposicion de juegos de Xbox"
    },
    @{
        Id          = "cortana"
        Name        = "Cortana"
        Type        = "windows"
        Description = "Asistente de Windows"
    },
    @{
        Id          = "clipchamp"
        Name        = "Clipchamp"
        Type        = "windows"
        Description = "Editor de video basico"
    },
    @{
        Id          = "news"
        Name        = "Noticias"
        Type        = "windows"
        Description = "Noticias de Microsoft"
    },
    @{
        Id          = "weather"
        Name        = "Tiempo"
        Type        = "windows"
        Description = "Aplicacion del tiempo"
    },
    @{
        Id          = "contacts"
        Name        = "Contactos"
        Type        = "windows"
        Description = "Gestion de contactos"
    },
    @{
        Id          = "maps"
        Name        = "Mapas"
        Type        = "windows"
        Description = "Aplicacion de mapas"
    },
    @{
        Id          = "games"
        Name        = "Juegos preinstalados"
        Type        = "windows"
        Description = "Juegos incluidos con Windows"
    }
)

# -------------------------------
# FUNCIONES DE ACCESO AL REGISTRY
# -------------------------------

function Get-BKApplications {
    return $Global:BKApplications
}

function Get-BKApplicationsByType {
    param (
        [Parameter(Mandatory)]
        [ValidateSet("thirdparty","windows")]
        [string]$Type
    )

    return $Global:BKApplications | Where-Object { $_.Type -eq $Type }
}
