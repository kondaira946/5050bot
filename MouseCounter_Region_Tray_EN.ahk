#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn

; Mouse counter with optional rectangle restriction.
; The counts are kept until Reset or script restart.
CoordMode("Mouse", "Screen")
CoordMode("ToolTip", "Screen")

leftClicks := 0
rightClicks := 0
leftDoubles := 0
rightDoubles := 0

isPaused := false
isAlwaysOnTop := false
onlyArea := false
selecting := false
wasVisibleBeforeSelection := false
area := {x1: 0, y1: 0, x2: 0, y2: 0}

lastLeftTick := 0
lastRightTick := 0
lastLeftX := 0
lastLeftY := 0
lastRightX := 0
lastRightY := 0

; Respect the Windows double-click interval and cursor tolerance.
doubleClickMs := DllCall("User32\GetDoubleClickTime", "UInt")
doubleHalfWidth := Max(2, DllCall("User32\GetSystemMetrics", "Int", 36, "Int") // 2)
doubleHalfHeight := Max(2, DllCall("User32\GetSystemMetrics", "Int", 37, "Int") // 2)

; Standard title bar lets you drag the small window anywhere.
mainGui := Gui("+ToolWindow -MaximizeBox +MinimizeBox -DPIScale", "Mouse Click Counter")
mainGui.SetFont("s10", "Segoe UI")
mainGui.MarginX := 12
mainGui.MarginY := 10

summaryText := mainGui.AddText("xm w300 h22", "Total: 0")
buttonsText := mainGui.AddText("xm y+4 w300 h22", "Left: 0     Right: 0")
doublesText := mainGui.AddText("xm y+4 w300 h22", "Double left: 0     Right: 0")
areaText := mainGui.AddText("xm y+9 w300 h38", "Area: Entire screen")

chooseBtn := mainGui.AddButton("xm y+5 w146 h29", "Select area")
allBtn := mainGui.AddButton("x+7 yp w145 h29", "Entire screen")
resetBtn := mainGui.AddButton("xm y+7 w146 h29", "Reset counts")
pauseBtn := mainGui.AddButton("x+7 yp w145 h29", "Pause")
topBtn := mainGui.AddButton("xm y+7 w146 h29", "Always on top: OFF")
quitBtn := mainGui.AddButton("x+7 yp w145 h29", "Exit")
trayBtn := mainGui.AddButton("xm y+7 w299 h29", "Hide to tray")

chooseBtn.OnEvent("Click", ChooseRegion)
allBtn.OnEvent("Click", UseWholeScreen)
resetBtn.OnEvent("Click", ResetCounts)
pauseBtn.OnEvent("Click", TogglePause)
topBtn.OnEvent("Click", ToggleAlwaysOnTop)
quitBtn.OnEvent("Click", Quit)
trayBtn.OnEvent("Click", MinimizeToTray)
mainGui.OnEvent("Close", MinimizeToTray)

MonitorGetWorkArea(1, &workLeft, &workTop, &workRight, &workBottom)
mainGui.Show("x" (workRight - 335) " y" (workTop + 20) " AutoSize Hide")

; AHK keeps its tray icon while the GUI is hidden.
A_TrayMenu.Delete()
A_TrayMenu.Add("Show counter", RestoreFromTray)
A_TrayMenu.Add("Hide to tray", MinimizeToTray)
A_TrayMenu.Add()
A_TrayMenu.Add("Exit", Quit)
A_TrayMenu.Default := "Show counter"
A_TrayMenu.ClickCount := 2
A_IconTip := "Mouse Click Counter"

buttonTips := Map(
    pauseBtn.Hwnd, "Ctrl + Alt + P - Pause / Resume",
    topBtn.Hwnd, "Ctrl + Alt + T - Always on top",
    resetBtn.Hwnd, "Ctrl + Alt + R - Reset counts",
    chooseBtn.Hwnd, "Ctrl + Alt + S - Select area",
    allBtn.Hwnd, "Ctrl + Alt + A - Entire screen",
    quitBtn.Hwnd, "Ctrl + Alt + Q - Exit",
    trayBtn.Hwnd, "Ctrl + Alt + H - Hide / Show"
)
; Polling also hides hints when the pointer leaves the window entirely.
SetTimer(ShowButtonHint, 120)
TooltipMsg("Program started")

; End of auto-execute section: hotkeys must follow initialization.
~*LButton::CountClick("L")
~*RButton::CountClick("R")

^!h::{
    global mainGui
    if DllCall("User32\IsWindowVisible", "Ptr", mainGui.Hwnd) {
        MinimizeToTray()
        TooltipMsg("Hidden to system tray")
    } else {
        RestoreFromTray()
        TooltipMsg("Counter window restored")
    }
}

^!s::{
    TooltipMsg("Select an area", 900)
    SetTimer(ChooseRegion, -250)
}
^!a::{
    UseWholeScreen()
    TooltipMsg("Area: Entire screen")
}
^!r::{
    ResetCounts()
    TooltipMsg("Counters reset")
}
^!q::{
    TooltipMsg("Closing program", 650)
    SetTimer(Quit, -700)
}
^!p::{
    TogglePause()
    TooltipMsg(isPaused ? "Counting paused" : "Counting resumed")
}
^!t::{
    ToggleAlwaysOnTop()
    TooltipMsg(isAlwaysOnTop ? "Always on top: ON" : "Always on top: OFF")
}

CountClick(which) {
    global isPaused

    if (isPaused)
        return

    global selecting, onlyArea, area, mainGui
    global leftClicks, rightClicks, leftDoubles, rightDoubles
    global lastLeftTick, lastRightTick, lastLeftX, lastLeftY, lastRightX, lastRightY
    global doubleClickMs, doubleHalfWidth, doubleHalfHeight

    if selecting
        return

    MouseGetPos(&mx, &my, &mouseWindow)

    ; Do not count clicks used to operate or move our own counter window.
    if (mouseWindow = mainGui.Hwnd) {
        ClearLastClick(which)
        return
    }

    if (onlyArea && (mx < area.x1 || mx >= area.x2 || my < area.y1 || my >= area.y2)) {
        ClearLastClick(which)
        return
    }

    now := A_TickCount
    if (which = "L") {
        leftClicks += 1
        if (lastLeftTick > 0
            && now - lastLeftTick <= doubleClickMs
            && Abs(mx - lastLeftX) <= doubleHalfWidth
            && Abs(my - lastLeftY) <= doubleHalfHeight) {
            leftDoubles += 1
            lastLeftTick := 0  ; A third press starts a new pair.
        } else {
            lastLeftTick := now
            lastLeftX := mx
            lastLeftY := my
        }
    } else {
        rightClicks += 1
        if (lastRightTick > 0
            && now - lastRightTick <= doubleClickMs
            && Abs(mx - lastRightX) <= doubleHalfWidth
            && Abs(my - lastRightY) <= doubleHalfHeight) {
            rightDoubles += 1
            lastRightTick := 0
        } else {
            lastRightTick := now
            lastRightX := mx
            lastRightY := my
        }
    }
    RefreshNumbers()
}

ClearLastClick(which) {
    global lastLeftTick, lastRightTick
    if (which = "L")
        lastLeftTick := 0
    else
        lastRightTick := 0
}

RefreshNumbers() {
    global summaryText, buttonsText, doublesText
    global leftClicks, rightClicks, leftDoubles, rightDoubles
    summaryText.Text := "Total: " (leftClicks + rightClicks)
    buttonsText.Text := "Left: " leftClicks "     Right: " rightClicks
    doublesText.Text := "Double left: " leftDoubles "     Right: " rightDoubles
}

ResetCounts(*) {
    global leftClicks, rightClicks, leftDoubles, rightDoubles
    global lastLeftTick, lastRightTick
    leftClicks := 0
    rightClicks := 0
    leftDoubles := 0
    rightDoubles := 0
    lastLeftTick := 0
    lastRightTick := 0
    RefreshNumbers()
}

UseWholeScreen(*) {
    global onlyArea, selecting, areaText, lastLeftTick, lastRightTick
    if selecting
        return
    onlyArea := false
    lastLeftTick := 0
    lastRightTick := 0
    areaText.Text := "Area: Entire screen"
}

ChooseRegion(*) {
    global selecting, onlyArea, area, areaText, mainGui, wasVisibleBeforeSelection
    global lastLeftTick, lastRightTick
    if selecting
        return

    selecting := true
    lastLeftTick := 0
    lastRightTick := 0
    wasVisibleBeforeSelection := DllCall("User32\IsWindowVisible", "Ptr", mainGui.Hwnd)
    mainGui.Hide()
    ToolTip("Hold the left mouse button and drag to select a rectangle.`nEsc - cancel selection.", 25, 25, 3)

    ; Wait for a NEW left press, checking Escape at the same time.
    while GetKeyState("LButton", "P") {
        if GetKeyState("Escape", "P") {
            EndSelection()
            return
        }
        Sleep(15)
    }
    while !GetKeyState("LButton", "P") {
        if GetKeyState("Escape", "P") {
            EndSelection()
            return
        }
        Sleep(15)
    }

    MouseGetPos(&startX, &startY)
    endX := startX
    endY := startY

    ; A translucent, click-through rectangle follows the mouse.
    shade := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20 -DPIScale")
    shade.BackColor := "328BEB"
    shade.Show("x" startX " y" startY " w1 h1 NoActivate")
    WinSetTransparent(75, "ahk_id " shade.Hwnd)

    cancelled := false
    while GetKeyState("LButton", "P") {
        if GetKeyState("Escape", "P") {
            cancelled := true
            break
        }
        MouseGetPos(&endX, &endY)
        x := Min(startX, endX)
        y := Min(startY, endY)
        w := Max(1, Abs(endX - startX))
        h := Max(1, Abs(endY - startY))
        shade.Show("x" x " y" y " w" w " h" h " NoActivate")
        Sleep(15)
    }
    if !cancelled
        MouseGetPos(&endX, &endY)
    shade.Destroy()
    EndSelection()

    w := Abs(endX - startX)
    h := Abs(endY - startY)
    if (cancelled || w < 10 || h < 10)
        return  ; Keep previous restriction if cancelled.

    area := {x1: Min(startX, endX), y1: Min(startY, endY)
           , x2: Max(startX, endX), y2: Max(startY, endY)}
    onlyArea := true
    areaText.Text := "Area: X " area.x1 "–" area.x2
        . ", Y " area.y1 "–" area.y2
}

EndSelection() {
    global selecting, mainGui
    ToolTip(,,, 3)
    global wasVisibleBeforeSelection
    if wasVisibleBeforeSelection
        mainGui.Show("NoActivate")  ; Keep its previous position.
    selecting := false
}

TogglePause(*) {
    global isPaused, pauseBtn
    global lastLeftTick, lastRightTick

    lastLeftTick := 0
    lastRightTick := 0

    isPaused := !isPaused

    if (isPaused)
        pauseBtn.Text := "Resume"
    else
        pauseBtn.Text := "Pause"
}

ToggleAlwaysOnTop(*) {
    global mainGui, topBtn, isAlwaysOnTop

    isAlwaysOnTop := !isAlwaysOnTop

    if (isAlwaysOnTop) {
        mainGui.Opt("+AlwaysOnTop")
        topBtn.Text := "Always on top: ON"
    } else {
        mainGui.Opt("-AlwaysOnTop")
        topBtn.Text := "Always on top: OFF"
    }
}

ShowButtonHint() {
    global buttonTips, mainGui
    static lastHwnd := 0

    MouseGetPos(&x, &y, &winHwnd, &controlHwnd, 2)
    hovered := (winHwnd = mainGui.Hwnd && buttonTips.Has(controlHwnd)) ? controlHwnd : 0
    if (hovered = lastHwnd)
        return
    lastHwnd := hovered
    ToolTip(,,, 2)
    if hovered
        ToolTip(buttonTips[hovered], x + 15, y + 20, 2)
}

TooltipMsg(message, duration := 2000) {
    MouseGetPos(&x, &y)

    ; Show a notification above the cursor
    ToolTip(message, x + 15, y - 45, 1)

    ; Cancel the previous hide timer
    SetTimer(HideTooltipMsg, 0)

    ; Hide after the requested duration
    SetTimer(HideTooltipMsg, -duration)
}

HideTooltipMsg() {
    ToolTip(,,, 1)
}

MinimizeToTray(*) {
    global mainGui
    mainGui.Hide()
    ToolTip(,,, 2)
}

RestoreFromTray(*) {
    global mainGui
    mainGui.Show()
    WinActivate("ahk_id " mainGui.Hwnd)
}

Quit(*) {
    ExitApp()
}
