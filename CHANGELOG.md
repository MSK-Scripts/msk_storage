# Changelog

All notable changes to MSK Storage.

## 1.3.1

Uses the table forms that msk_core 4.1.0 introduced, so the deprecation warnings in the server console are gone.

**Requires msk_core 4.1.0 or newer.** The notifications are sent as a table, which an older msk_core takes as the title. Update msk_core along with this script.

- **The msk_core version is checked on start.** `MSK.Check.Dependency('msk_core', '4.1.0', true)` logs an error in the server console when msk_core is older, instead of leaving you to wonder why the notifications look wrong.
- **`Config.Notification` passes a table to `MSK.Notification`.** The form with title, message, type and duration is deprecated since msk_core 4.1.0 and logs a warning once per resource. If you keep your own config, change the two `MSK.Notification` lines the same way. Leaving them works too, the old form is still accepted for now.

**Changed files:** `fxmanifest.lua`, `config.lua`, `server/versionchecker.lua`

## 1.3.0

Runs on QBCore and Qbox. Until this release the resource was ESX only, and it
said so in its manifest.

**Requires msk_core 4.0.0 or newer.** The player object, `MSK.Offline` and
`MSK.Society` are all used in their 4.0.0 form. Update msk_core along with this
script.

- **`es_extended` is no longer a dependency.** It was listed in `dependencies`
  and imported through `@es_extended/imports.lua`, so the resource refused to
  start on a server without ESX. Every framework call goes through msk_core now.
- **Society payouts follow the banking resource, not the framework.**
  `MSK.Society` finds Renewed-Banking, qb-banking, qb-management or
  esx_addonaccount. The old code triggered `esx_addonaccount:getSharedAccount`
  directly, which exists on ESX and nowhere else, so the payout silently did
  nothing on any other setup. The share is floored to a whole number now.
- **The stash id no longer reads `ESX.PlayerData` on the client.** The identifier
  comes from `MSK.GetPlayerData()`, which has the same shape on every framework.
- Fixed: **the monthly rent could go through twice and only be charged once.**
  For an offline player the old code read `users.accounts`, did the arithmetic in
  Lua and wrote the row back. Two deductions in the same moment overwrite each
  other and one is lost. `MSK.Offline.RemoveBank` does it in a single statement
  with a `WHERE` guard.
- Fixed: **buying and upgrading checked the balance and then deducted blindly.**
  The two were separate steps and `removeAccountMoney` had no answer to act on,
  so anything that changed the balance in between was simply ignored.
  `RemoveMoney` refuses when the balance is short, and the player is told instead
  of quietly ending up with a storage they did not pay for.

**Changed files:** `fxmanifest.lua`, `integration/client_integration.lua`,
`server/server.lua`, `server/server_functions.lua`

## 1.2.3

- Fixed icons not loading in the UI, updated FontAwesome to 7.2.0 and switched it from a script to a stylesheet include.

**Changed files:** `html/index.html`, `fxmanifest.lua`

## 1.2.2

- Fixed missing FontAwesome icons in the HTML.

**Changed files:** `html/index.html`, `fxmanifest.lua`

## 1.2.1

- Fixed an error on startup with ox_inventory (`SCRIPT ERROR: @msk_storage/integration/server_integration.lua:10: attempt to call a nil value (global 'registerStash')`).

**Changed files:** `integration/server_integration.lua`, `fxmanifest.lua`

## 1.2.0

- Added: configured societies receive a percentage of the storage price (`Config.Society`).
- Fixed issues with the TextUIs.

**Changed files:** `config.lua`, `client/client.lua`, `server/server.lua`, `server/server_functions.lua`, `fxmanifest.lua`

## 1.1.0

- Added support for ox_inventory.

**Changed files:** reworked across the whole script, affecting `config.lua`, `translation.lua`, `client/*`, `server/*`, `integration/*`, `html/*` and `fxmanifest.lua`

## 1.0.1

- Various bugfixes.

## 1.0.0

- Initial release.
