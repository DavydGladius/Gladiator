# Developer Notes

## Engine
- Godot 4.x project
- GDScript gameplay logic

## Main scene
- Main menu scene loads the arena scene for new or loaded runs.

## Autoloads
- AudioManager: UI click sound helper.
- SettingsData: keybind and volume state, persisted in save data.
- Global: cross-scene state such as load_save.
- SaveManager: JSON persistence to user://savefile.json.

## Input actions
- Movement: up, down, left, right
- Combat: attack, bomb
- UI: Escape for pause

## Save data flow
- SettingsData reads and writes keybinds inside the settings save section.
- WaveManager saves current and resume wave data.
- ShopScene saves current item indices and purchased indices.

## Testing
- The project uses the GUT addon for automated tests.
- Test assets live in the Test folder.
- TestRunner.tscn is used as an entry point for test runs.

## Static checks
- A custom static rule exists to flag debug print usage in scripts.

## Contributing
- Use descriptive commit messages.
- Keep changes scoped to one feature or fix when possible.
- Run the game from the editor to validate changes.
