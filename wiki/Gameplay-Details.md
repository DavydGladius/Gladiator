# Gameplay Details

## Arena flow
- The arena runs in continuous waves driven by the wave manager.
- A grace period separates combat waves and signals shop availability.
- Entering the safe area pauses active waves and clears enemies.

## Wave UI
- The wave label shows the current wave number or grace state.
- The progress bar reflects enemies remaining or grace time remaining.

## Safe area flow
- Entering the safe area opens the shop and inventory UI.
- Leaving the safe area hides the shop UI and restarts or resumes the wave.

## Death flow
- On death, the death screen appears with continue or exit options.
- Continuing restores player health, re-enables collisions, and restarts the wave.

## Pause flow
- Escape toggles the pause menu.
- Pause hides gameplay HUD and shop UI while the menu is open.
- Settings can be opened from the pause menu without leaving the arena.

## Arena transitions
- Arena textures and music can change at milestone waves.
- Transitions are staged through a fade-to-black overlay to avoid abrupt changes.

## Audio
- Music changes based on arena phase.
- SFX are routed through the SFX audio bus.
