#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 2

; Show startup notification
ToolTip "Program running. Press F7 to start"
SetTimer HideStartupTip, -4000

HideStartupTip() {
    ToolTip()
}

; 5050bot v3.1: no window title or process checks.
; Activate the game yourself before F6/F7.
; F6 = one bet, F7 = start/pause, F8 = exit.
CoordMode "Mouse", "Client"
SendMode "Event"
SetMouseDelay 35

betPercent := 40
intervalMs := 1400
running := false
busy := false
baseW := 1280
baseH := 706

F6::MakeBet()
F7::{
    global running, intervalMs
    running := !running
    if running {
        SetTimer AutoBet, intervalMs
        ToolTip "5050bot v3.1: RUNNING (F7 pause, F8 exit)"
        SetTimer ClearTip, -1000
        AutoBet()
    } else {
        SetTimer AutoBet, 0
        ToolTip "5050bot v3.1: PAUSED"
        SetTimer ClearTip, -1000
    }
}
F8::ExitApp()

AutoBet() {
    global running
    if running
        MakeBet()
}

MakeBet() {
    global busy, betPercent, baseW, baseH
    if busy
        return
    busy := true
    try {
        ; Use whichever window is active, without checking its name/process.
        hwnd := WinActive("A")
        if !hwnd
            return
        WinGetClientPos , , &w, &h, "ahk_id " hwnd
        if w < 500 || h < 350
            return
        sx := w / baseW
        sy := h / baseH
        leftX := Round(192 * sx)
        rightX := Round(1089 * sx)
        sliderY := Round(206 * sy)
        buttonX := Round(641 * sx)
        buttonY := Round(505 * sy)
        targetX := Round(rightX - (rightX - leftX) * betPercent / 100)

        MouseMove rightX, sliderY, 0
        Sleep 100
        MouseClickDrag "Left", rightX, sliderY, targetX, sliderY, 18
        Sleep 220
        Click buttonX, buttonY
    } finally {
        busy := false
    }
}

ClearTip() {
    ToolTip()
}
