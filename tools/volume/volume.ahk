#NoEnv
#SingleInstance Force
SetBatchLines -1

; =========================
; CONFIGURACION
; =========================
STEP=5
OSD_TIME=4000

; =========================
; ATAJOS
; Ctrl + Flechas / Ctrl + M
; =========================
^Up::
    SoundGet, VOL
    VOL += %STEP%
    if VOL > 100
        VOL = 100
    SoundSet, %VOL%
    Gosub, SHOW_OSD
return

^Down::
    SoundGet, VOL
    VOL -= %STEP%
    if VOL < 0
        VOL = 0
    SoundSet, %VOL%
    Gosub, SHOW_OSD
return

^m::
    SoundSet, +1, , mute
    Gosub, SHOW_OSD
return

; =========================
; HUD
; =========================
SHOW_OSD:
    Gui, Destroy
    Gui, +AlwaysOnTop -Caption +ToolWindow
    Gui, Color, 1A1A1A

    Gui, Font, s10 cFFFFFF, Consolas
    Gui, Add, Text, x10 y8, BLACK CONSOLE :: AUDIO

    SoundGet, MUTE, , mute
    SoundGet, VOL
    VOL := Round(VOL)

    if (MUTE = "On")
    {
        Gui, Font, s10 cFF3C82, Consolas
        Gui, Add, Text, x10 y28, MUTED
        BAR=0
    }
    else
    {
        Gui, Font, s10 cB45AFF, Consolas
        Gui, Add, Text, x10 y28, VOLUME : %VOL%`%
        BAR=%VOL%
    }

    Gui, Add, Progress, x10 y52 w200 h8 cB45AFF Background1A1A1A, %BAR%
    Gui, Show, NoActivate x50 y50

    SetTimer, HIDE_OSD, -%OSD_TIME%
return

HIDE_OSD:
    Gui, Destroy
return
