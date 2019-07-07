// CSXGuard v4 by ratwayer
// http://madotsuki.ru | ratwayer@madotsuki.ru

This is a client-side modification for Counter-Strike, which is designed to protect your game client from "unwanted" commands, such as "motd_write" and "snapshot". Moreover, it provides a whole lot of additional features (some of then include blocking QCC messages and MOTD windows, removing FPS limits built in the engine, plus fixing some bugs and annoyances; and that's not even all of them).

Source code is also avaliable (Delphi 6 or newer is required to compile; 2009/XE/XE2 are not supported).

Requirements:
Works on any Counter-Strike 1.6 version (2637 to 4554), the video mode and the renderer does not matter.
Steam versions of Counter-Strike are also supported.

Installation:
1) Extract the archive contents to your Counter-Strike folder (in the same directory that contains "hl.exe").
2) Launch the game; the welcome message should appear in your console.
You can also use the DLL injector instead of ASI-loader, this doesn't affect the initialization process.
The "Source" directory contains the source code, which isn't required for gameplay.

Configuration:
The file "CSXGuard.ini" contains all the configurable parameters which can be changed.

Full feature list:
- selective command blocking (currently there are 227 commands in the list)
- QCC/QCC2 message blocking (only if your client supports them)
- MOTD window blocking
- removing the built-in limits for ex_interp and cl_updaterate
- removing the built-in FPS limits
- selective command forwarding (helps bypassing the alias-detectors)
- a fix for case-sensitive file name filters; manual configuration is also supported
- removing the protection set for cvars with FLAG_SPONLY flag
- removing the cvar validation (chase_active, r_drawentities, gl_wireframe, ..)
- removing the limitation which doesn't allow to use "*" in the setinfo command
- an ability to record movies ("startmovie") even while not playing a demo
- voice subsystem tweaks:
 - allowing to use voice chat even when not fully connected
 - an ability to change the outgoing voice packet size
 - built-in ban manager (block the players you don't want to hear)
 - looping the file input (voice_loopinput)
 - seeking a position in the file input (voice_seekinput)
 - a fix for voice record problem when the game is restored from minimized state
- show the console on game initialization
- advanced scripting interface ("if" and "loop" commands)
- a fix for "spawn 1 1" exploit that can be run against a client
- resource filters (blocking the downloading of sounds, music and banners)

Send any suggestions or questions to ratwayer@madotsuki.ru.