# Shop and Inventory

## Safe area shop
- The shop appears when the player enters the safe area.
- Waves pause while the shop is active.
- Leaving the safe area resumes or restarts the wave logic.

## Item types
The shop offers a mix of:
- Weapon unlocks (sword, bow)
- Damage upgrades (weapon-specific)
- Health upgrades
- Speed upgrades
- Special items (bomb ammo)

## Selection rules
- The shop chooses three unique items per refresh.
- Weapons the player already owns are filtered out from the selection pool.
- Shop selection is saved so a load does not reshuffle unexpectedly.

## Purchase rules
- Items cost coins.
- Certain upgrades are capped and show MAX when capped.
- Weapon upgrades require the corresponding weapon to be equipped.
- Successful purchases increase the item price by 3.

## Special items
- Bomb ammo is treated as a special item type.
- Each purchase grants a fixed ammo amount and updates inventory.

## Inventory UI
- Shows owned items and quantities.
- Allows switching between sword and bow.
- Displays bomb ammo as a quantity item.
- Shows a placeholder state if the inventory is empty.
