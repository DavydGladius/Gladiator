# Getting Started

## Requirements
- Godot 4.x (project is configured for Godot 4.x features).
- Windows for the release build.

## Play the released build
1. Open the GitHub Releases page for the project.
2. Download the latest Windows .exe build.
3. Run the executable. No installer required.

## Run from the editor (developers)
1. Install Godot 4.x.
2. Open the project folder containing project.godot.
3. Press Play to run the main scene (the main menu).

## Export a build (developers)
1. In Godot, open Project -> Export.
2. Select the Windows preset from export_presets.cfg.
3. Export the .exe to a desired output folder.

## Controls
- Move: WASD (configurable)
- Attack: mouse movement and left click
- Bomb: configurable keybind
- Pause: Escape

Keybinds can be changed in the in-game Settings menu.

## Save data
- The game stores data in user://savefile.json.
- Delete this file to reset progress.

## Troubleshooting
- If the game opens to a blank scene, confirm the main scene is set to the main menu in project.godot.
- If keybinds feel incorrect, reset them in Settings.
