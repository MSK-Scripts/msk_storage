# Changelog

All notable changes to MSK Storage.

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
