5050bot v4  by kondaira946
=======================

Overview
--------
5050bot v4 is an experimental background betting bot for the Windows
Steam game 5050. It sets each stake to 40% of the available points
using the game's slider, then presses the bet button.

Unlike v3, v4 sends Windows mouse messages to a selected window.
It does not intentionally move the real mouse cursor or activate the
game window. Background operation depends on how the game handles input.
Long story short, mouse input is emulated in game

Requirements
------------
- Windows
- AutoHotkey v2 to run the .ahk script, or a compiled .exe
- The 5050 game open with a compatible interface layout
- A sufficiently large game client area (at least 500 x 350 pixels)

Getting started
---------------
1. Launch 5050 and make its window active.
2. Run 5050bot_v4.ahk or its compiled executable.
3. A brief startup message appears: "Program running. Press F7 to start".
4. While 5050 is the active window, press F7. The bot remembers the
   window and begins placing bets.
5. Switch to another application if desired. Check whether the game
   continues accepting bets in the background.
6. Press F7 to pause before changing settings or troubleshooting.

Hotkeys
-------
F6  Place one bet. If no valid target is saved, bind the active window.
F7  Start/pause automatic betting. When starting without a valid target,
    bind the currently active window.
F8  Exit the bot.
F9  Pause and release the saved window. Activate another window and
    press F7 to bind it.

Settings and behavior
---------------------
- Bet size: 40% of the available points (fixed in the script).
- Automatic betting interval: 1,400 milliseconds.
- Target selection: Windows window handle (HWND), not process name.
- Mouse actions: posted Windows messages for drag and click.
- Coordinates: scaled from a 1280 x 706 reference client area.
- If the target window closes, the bot pauses and clears the binding.
- If the target client area is too small, the bot pauses.

Important limitations
---------------------
- Background dragging/clicking is experimental. Some games ignore
  synthetic window messages, especially when minimized.
- The bot does not read your balance and does not stop at 1,000,000.
- Winning is not guaranteed; bets can lose points.
- F6/F7 bind whichever window is active if no valid target is saved.
  Make sure 5050 is active before binding.
- The global hotkeys may also fire while other applications are active.
- If the game UI changes, the slider and button coordinates may need
  recalibration.

Compiling to EXE
----------------
Install AutoHotkey v2 and Ahk2Exe. Right-click 5050bot_v4.ahk and
select "Compile Script" to create a Windows executable.

Troubleshooting
---------------
Nothing happens: activate 5050, press F9, then F7 to rebind.
Slider does not move: the game may not accept posted drag messages.
Button does not click: the game may not accept background mouse input.
Wrong window receives input: press F9, activate 5050, then press F7.
Game window closes: restart it and bind again with F7.

Version: 4 (experimental background mode)
