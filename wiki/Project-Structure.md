# Project Structure

## Top-level
- assets: textures, music, sound effects
- characters: player and enemy scenes
- Scenes: main game scenes and UI scenes
- scripts: gameplay logic and systems
- Test: test harness and reports
- addons: GUT testing addon

## assets
- Backgrounds: menu and settings backgrounds
- music: main menu, game, and pause tracks
- sound_effects: UI and combat sounds
- sprites: tilesets, objects, weapons, and UI icons

## characters
- Player: player scene and weapon nodes
- Enemy: enemy scenes and variants
- weapons: projectile scenes (for example, Arrow.tscn)

## Scenes
- Main menu: Scenes/main_menu.tscn
- World (arena): Scenes/world.tscn
- Wave manager: Scenes/wave_manager.tscn
- Shop: Scenes/shop_scene.tscn
- Pause menu: Scenes/pause_menu.tscn
- Death screen: Scenes/DeathScreen.tscn
- UI widgets: inventory_screen.tscn, shop_item.tscn, SettingsWindow.tscn

## scripts
- audio: AudioManager and volume controls
- base: Entity, Global, SaveManager, tile map helpers
- enemy: enemy logic and coin pickup
- object: hazards and static objects
- player: Player.gd
- resources: ItemData and upgrade resources
- settings: settings data and settings window UI
- tools: static analysis rule
- ui: menu, shop, pause, inventory, and death screen
- weapons: sword, bow, arrow, bomb, enemy sword

## Key scripts
- Player: scripts/player/Player.gd
- Enemy: scripts/enemy/enemy.gd
- Wave manager: scripts/wave_manager.gd
- Shop system: scripts/ui/shop_scene.gd
- Inventory UI: scripts/ui/inventory_screen.gd
- Settings: scripts/settings/settings_window.gd

## Autoloads
- AudioManager: shared UI click sound
- SettingsData: keybinds and volume settings
- Global: cross-scene flags
- SaveManager: JSON save/load helper
