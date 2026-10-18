#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 2

; 5050bot v4 - experimental background input via window messages.
; F6: one bet / bind active window if needed
; F7: start or pause / bind active window on start
; F8: exit
; F9: pause and forget target window (rebind with F7)
; IMPORTANT: Background drag depends on the game's input implementation.

Persistent()
SetTitleMatchMode 2

betPercent := 40
intervalMs := 1400
baseW := 1280
baseH := 706
running := false
busy := false
targetHwnd := 0

ToolTip "Program running. Press F7 to start"
SetTimer ClearTip, -4000

F6::{
    global targetHwnd
    if !TargetValid() {
        targetHwnd := WinExist("A")
    }
    MakeBet()
}

F7::{
    global running, targetHwnd, intervalMs
    if running {
        PauseBot("PAUSED")
        return
    }
    if !TargetValid() {
        targetHwnd := WinExist("A")
    }
    if !TargetValid() {
        Notify("No target window. Activate game and press F7.")
        return
    }
    running := true
    Notify("BACKGROUND RUNNING - F7 pause, F9 rebind, F8 exit")
    SetTimer AutoBet, intervalMs
    AutoBet()
}

F8::ExitApp()
F9::{
    global targetHwnd
    PauseBot("Target released. Activate another window and press F7.")
    targetHwnd := 0
}

TargetValid() {
    global targetHwnd
    return targetHwnd && WinExist("ahk_id " targetHwnd)
}

PauseBot(message := "PAUSED") {
    global running
    running := false
    SetTimer AutoBet, 0
    Notify(message)
}

AutoBet() {
    global running
    if running
        MakeBet()
}

MakeBet() {
    global busy, targetHwnd, baseW, baseH, betPercent, running
    if busy
        return
    busy := true
    try {
        if !TargetValid() {
            PauseBot("Target window closed. Paused; F7 to bind a new window.")
            targetHwnd := 0
            return
        }
        WinGetClientPos(, , &w, &h, "ahk_id " targetHwnd)
        if w < 500 || h < 350 {
            PauseBot("Target client area too small. Paused.")
            return
        }
        sx := w / baseW
        sy := h / baseH
        rightX := Round(1089 * sx)
        leftX := Round(192 * sx)
        sliderY := Round(206 * sy)
        buttonX := Round(641 * sx)
        buttonY := Round(505 * sy)
        endX := Round(rightX - (rightX - leftX) * betPercent / 100)

        ; All coordinates are CLIENT-relative. No cursor movement or focus changes.
        ; WM_MOUSEMOVE=0x200, WM_LBUTTONDOWN=0x201, WM_LBUTTONUP=0x202
        ; MK_LBUTTON=0x0001; lParam = y << 16 | x.
        PostMouse(0x200, 0, rightX, sliderY)
        Sleep 50
        PostMouse(0x201, 1, rightX, sliderY)
        steps := 18
        Loop steps {
            x := Round(rightX + (endX - rightX) * A_Index / steps)
            PostMouse(0x200, 1, x, sliderY)
            Sleep 18
        }
        PostMouse(0x202, 0, endX, sliderY)
        Sleep 220
        PostMouse(0x200, 0, buttonX, buttonY)
        PostMouse(0x201, 1, buttonX, buttonY)
        Sleep 55
        PostMouse(0x202, 0, buttonX, buttonY)
    } catch Error as e {
        PauseBot("Background input error: " e.Message)
    } finally {
        busy := false
    }
}

PostMouse(msg, flags, x, y) {
    global targetHwnd
    if !TargetValid()
        throw Error("Target window no longer exists")
    lp := ((y & 0xFFFF) << 16) | (x & 0xFFFF)
    PostMessage(msg, flags, lp, , "ahk_id " targetHwnd)
}

Notify(message) {
    ToolTip message
    SetTimer ClearTip, -1800
}

ClearTip() {
    ToolTip()
}
