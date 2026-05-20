# Player System

## Overview
The player is an Entity with health, movement speed, and combat actions. The player maintains an inventory, coin count, and upgrade state.

## Health and damage
- Health is tracked with current and maximum values.
- Damage taken triggers animations and can cause death.
- Health upgrades add to a bonus health pool.
- On death, the player loses 10 percent of current coins and the wave is reset.

## Movement
- Movement uses a normalized input vector from the configured keybinds.
- Speed upgrades scale the base movement speed with a multiplier.
- Maximum speed multiplier is capped at 1.8.

## Inventory
- Inventory stores weapons and special items with name, icon, and quantity.
- Inventory items are stored as dictionaries, for example: name, weapon_type, icon, quantity.
- Inventory UI listens to the inventory_changed signal to refresh the display.

## Weapons
- Default weapon is the Basic Sword.
- Bow and bombs can be acquired through the shop.
- Switching weapons enables the selected weapon node and disables the other.

## Damage and upgrade caps
- Sword damage multiplier caps at 2.5.
- Bow damage multiplier caps at 2.0.
- Health bonus caps at 100.
- Sword and bow tier upgrades are tracked and affect weapon visuals.

## Bombs
- Bombs are thrown with a short cooldown.
- Bomb ammo is tracked in the inventory and updated when used.
- Bombs use a physics impulse based on mouse direction.

## Coins
- Coins are dropped by enemies and used to purchase upgrades.
- Player coin count persists to the UI and is reduced on death.
