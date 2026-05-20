# Enemies

## Overview
Enemies are Entities with health, movement, and attack behavior. Standard enemies chase the player using pathfinding and deal contact damage.

## Core behavior
- Navigate toward the player via NavigationAgent2D.
- Stop moving at close range and attack within the attack area.
- Use a cooldown between attacks to avoid constant damage ticks.
- Drop a coin on death.

## Audio
- Footstep sounds play while moving.
- Attack and death sounds play during combat events.

## Types
- Standard enemy: base melee attacker with contact damage.
- Sword enemy: uses a sword swing attack for burst damage.
- Mini-boss: larger scale, increased health, damage, and speed. Spawned on milestone waves.

## Sword enemy details
- Inherits standard enemy behavior.
- Performs a sword swing and applies damage to overlapping bodies.

## Scaling
- Enemy stats scale with wave level, increasing challenge over time.
- Mini-bosses receive additional stat multipliers and size scaling.
