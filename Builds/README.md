# Hollow Buddy
Hollow Buddy is a game with optional support for reading your Hollow Knight game sessions for extra rewards based on how you perform. If set up correctly, your Buddy's eyes will glow green while adventuring if it is receiving data from Hollow Knight.

## Compatibility with Hollow Knight

Hollow Buddy relies on the [Hollow Knight Mod API](https://github.com/hk-modding/api) to read your game files. The easiest way to install Hollow Buddy is through Scarab.

### Steps for Installing
1. Launch Hollow Buddy.
2. Open the "Settings" menu.
3. Click "Install Scarab", or [download Scarab directly](https://github.com/fifty-six/Scarab/releases).
4. Run Scarab. It should detect your game folder automatically.
5. Click "Install API".
6. Click "Open Mods".
7. Copy the Mods folder path from your file manager.
8. Go back to Hollow Buddy. Inside the Settings menu, paste in the mods folder path, and hit enter.
9. Click "Install Server".

#### Optional Steps
Scarab is not required. You may use another mod manager based on the Hollow Knight Mod API (which you can also install yourself directly).

Hollow Buddy stores the mods folder inside of a `settings.json` file, located in the Godot `user://` path (on Windows this is `%APPDATA%\Godot\app_userdata\Hollow Buddy`). You can adjust this manually, if you'd like. Note that the Mods folder MUST be set for Hollow Buddy to determine if it can connect to Hollow Knight.

`BuddyServer.dll` is the mod Hollow Buddy communicates with. You can copy this manually to your mods folder (be sure to create the `BuddyServer` folder for Hollow Buddy to detect the mod).

## An Additional Note
Hollow Buddy ONLY reads your game state. It should not interfere with any other mods you may have installed.