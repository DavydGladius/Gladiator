# Settings and Save/Load

## Settings
- Music and SFX volumes are adjustable.
- Fullscreen toggle is supported.
- Keybinds can be remapped for movement and bomb actions.

## Keybind rules
- The system prevents duplicate keybinds.
- Unbound actions are supported.
- The UI listens for the next keypress and updates InputMap.

## Audio settings
- Volume sliders write to the Music or SFX audio bus.
- Settings are stored and reapplied on startup.

## Save/Load
- Save data is stored in user://savefile.json.
- Wave progress and shop state are persisted.
- Loading from the main menu will continue from the saved wave.

## Save sections
- settings: volume and keybind data.
- wave: current wave and resume wave values.
- shop: current shop item indices and purchased indices.
