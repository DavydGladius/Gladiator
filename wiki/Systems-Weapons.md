# Weapons and Combat

## Basic Sword
- Melee weapon with a swing arc.
- Base damage: 25.
- Damage scales with player damage multiplier.
- Visuals adjust based on player facing direction and animation state.
- Swing uses a tweened rotation to create a readable arc.

## Basic Bow
- Ranged weapon that fires arrows.
- Base damage per arrow: 25.
- Arrow speed: 800.
- Shoot cooldown: 0.5 seconds.
- Arrows deal damage and despawn on hit or when off-screen.
- Damage scales with player damage multiplier.

## Bombs
- Thrown explosive weapon with a short fuse.
- Base damage: 50.
- Explosion area is handled by an Area2D overlap check.
- Bombs are consumed per throw and must be replenished via shop items.

## Enemy sword
- Enemy sword swings are driven by the enemy_sword script.
- Uses a similar arc to the player sword to keep attacks readable.

## Combat input
- Attack uses mouse direction and left click by default.
- Bomb throw uses the configured bomb keybind.
