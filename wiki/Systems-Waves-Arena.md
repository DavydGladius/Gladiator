# Waves and Arena

## Wave manager
- Spawns enemies in timed waves.
- Uses a grace period between waves.
- Updates wave UI labels and progress bar.
- Emits a wave_started signal so other systems can react.

## Wave rules
- Base enemy count increases every wave.
- Every 5th wave spawns one or more mini-bosses.
- Enemy stats scale with wave level using an internal boost factor.

## Grace period
- Triggered after all enemies for a wave are defeated.
- Progress bar switches to a time-remaining mode.
- Safe area use typically happens during this window.

## Arena transitions
- Arena visuals and music can change at milestone waves.
- Transitions use a fade to black overlay.
- Arena thresholds are defined by wave number ranges in the world scene logic.

## Spawn gates
- Gates and hatch play open/close animations at wave transitions.
- Spawn points are selected from predefined markers.

## Hazards
- Spike traps deal periodic damage when active.
- Pressure plates and spawn gates are used for environmental interaction.
