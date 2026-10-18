MOUSE CLICK COUNTER — README
============================

DESCRIPTION
A lightweight AutoHotkey v2 utility that counts left and right mouse clicks,
including double-click pairs. You can count clicks across the screen or only
inside a selected rectangle. The counter starts hidden in the Windows system
tray and displays "Program started" near the cursor for two seconds.

REQUIREMENTS
Windows and AutoHotkey v2.0 or newer.

START / TRAY
Run MouseCounter_Region_Tray_EN.ahk. The window is hidden at startup;
look for the AutoHotkey icon in the notification area (possibly under ^).
Double-click the tray icon to open the counter, or right-click it for a menu.
Closing the counter window (X) hides it to the tray; it does NOT quit.
Use the Exit button, tray menu Exit, or Ctrl+Alt+Q to terminate the script.

HOTKEYS
Ctrl+Alt+H  Hide/show counter window
Ctrl+Alt+S  Select a rectangular counting area
Ctrl+Alt+A  Count on the entire screen
Ctrl+Alt+R  Reset all counters
Ctrl+Alt+P  Pause/resume counting
Ctrl+Alt+T  Toggle Always on Top
Ctrl+Alt+Q  Exit the program

Hover over a GUI button to see its shortcut. Hotkey actions display brief
notifications near the mouse pointer.

IMPORTANT DETAILS
- Counts are kept in memory only; exiting or restarting resets them.
- Pausing stops counting, not mouse input or the program itself.
- The window can be hidden while counting continues.
- Double-click totals are additional statistics: each double-click pair
  still adds TWO ordinary clicks to the total.
- Double-click detection uses the Windows time and cursor-distance settings.
- Area selection: hold the LEFT mouse button and drag; press Esc to cancel.
  Very small selections (under 10 pixels in either dimension) are ignored.
- Selecting an area from the tray leaves the main window hidden afterward.
- The mouse buttons used to operate the counter window are not counted.
- The tray icon can be in the Windows hidden-icons overflow menu.

KNOWN LIMITATIONS / POSSIBLE ISSUES
- Some games, exclusive fullscreen applications, elevated processes, or
  security-sensitive windows may not deliver mouse events to an ordinary
  AutoHotkey script. Running as administrator may help in some cases.
- Clicks are detected from mouse-button hotkeys, not from application-level
  click events; synthetic or injected clicks may behave differently.
- GUI button hover hints are polled and can take about 120 ms to appear.
- A region is stored as screen coordinates; changing monitor layout,
  resolution, or scaling may make the old region unsuitable.
- The notification tooltip can appear partly off-screen near display edges.
- The script has not been tested in a live Windows session.
