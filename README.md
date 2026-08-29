# MSK Storage

A rentable warehouse system for FiveM (ESX). Players rent a warehouse from an NPC, get their own personal stash for it and pay rent on a fixed interval. If the rent cannot be collected, the storage stays locked until the open payment is settled.

This script used to be a paid resource in the shop and is now free and open source.

[Documentation](https://docu.msk-scripts.de/) · [MSK Scripts](https://www.msk-scripts.de)

## Features

### 📦 Rent, upgrade and cancel

- As many storage tiers as you want in `Config.Storages`, each with its own price, weight, slot count and preview image.
- Payment either in cash or from the bank account.
- **Upgrading** to a higher tier only costs the difference to the current contract and keeps the stored items.
- **Cancelling** removes the contract and clears the stash including its inventory data.
- One player holds exactly one contract, tied to their identifier.

### 💸 Recurring rent

- Every `Config.PayCron` days (default 7) the rent is charged from the bank account, even while the player is offline (handled directly through the `users` table in that case).
- `Config.MinBudget` defines how much money has to stay on the account. If the balance is not enough, the contract is flagged as `unpaid` and the storage is locked until the player pays up.
- Societies can optionally receive a percentage of every rent payment (`Config.Society`, requires `esx_addonaccount`).

### 📍 Locations and NPCs

- Multiple locations in `Config.Locations`, each with its own selection of available storage tiers.
- Configurable per location: blip, NPC (ped model with spawn distance) or a marker instead.
- Optional NPC voice line when a player walks up (`Config.npcVoice`).

### 🖥️ NUI

- Custom interface for renting, opening, upgrading and cancelling, with a preview image and the price per tier.
- Opens with a key (`Config.Hotkey`, default `E`).
- TextUI either through msk_core or through your own TextUI resource (`Config.openTextUI` / `Config.closeTextUI`).

### 🎒 Inventory integration

Supported out of the box:

- `chezza_v3`
- `chezza_v4`
- `ox_inventory`
- `custom` for your own integration in the `integration/` folder

With ox_inventory every stash is registered automatically on resource start, and an upgrade adjusts weight and slots on the existing stash.

### 🌐 Other

- Multi-language through `translation.lua` (German, English and Hungarian included, easy to extend).
- Built-in version checker, can be turned off with `Config.VersionChecker`.
- Debug logging through `Config.Debug`.
- Lua 5.4.

## Installation

1. Download the repository and rename the folder to `msk_storage`.
2. Drop the folder into your server's `resources` directory.
3. Add it to your `server.cfg`:

```cfg
ensure msk_storage
```

4. Adjust `config.lua` to your server, mainly `Config.Inventory`, `Config.Locale` and the locations.

No SQL file is required. The rental contracts are stored in `storages.json` inside the resource folder, the item data is handled by your inventory script.

## Configuration

| File | Contains |
| --- | --- |
| `config.lua` | Prices, storage tiers, locations, rent interval, society shares, inventory selection |
| `translation.lua` | All texts and languages |
| `integration/client_integration.lua` | Opening and closing the inventory |
| `integration/server_integration.lua` | Registering and upgrading the stashes |

## Requirements

- [es_extended](https://github.com/esx-framework/esx_core)
- [oxmysql](https://github.com/overextended/oxmysql)
- [msk_core](https://docu.msk-scripts.de/)

## Optional

- [esx_addonaccount](https://github.com/esx-framework/esx_addonaccount) for the society share of the rent income

## Exports

```lua
-- Server
exports.msk_storage:getDatabase() -- returns all rental contracts
```

## License

Released under the [GNU Lesser General Public License v3.0](LICENSE).

You are free to use, modify and redistribute the script. Modifications of the script itself have to be published under the same license, other resources may link against it without any obligation. Reselling the script is not permitted.
