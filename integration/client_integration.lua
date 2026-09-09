-- The stash id is built from the player identifier. msk_core 4.0.0 hands
-- that over in one shape on every framework, so reading ESX.PlayerData
-- directly (which only ever worked on ESX) is gone.
local function playerIdentifier()
    local data = MSK.GetPlayerData()
    return data and data.identifier or ''
end

openInventoryIntegration = function(storage)
    if Config.Inventory == 'chezza_v3' then
        TriggerEvent('inventory:open', {
            type = "msk_storage",
            id = storage.uniqueId .. playerIdentifier(),
            title = storage.storageData.label[1] .. ' ' .. storage.storageData.label[2], 
            weight = storage.storageData.weight,
            delay = 100,
            save = true
        })
    elseif Config.Inventory == 'chezza_v4' then
        TriggerEvent('inventory:openInventory', {
            type = "msk_storage",
            id = storage.uniqueId .. playerIdentifier(),
            title = storage.storageData.label[1] .. ' ' .. storage.storageData.label[2], 
            weight = storage.storageData.weight,
            delay = 100,
            save = true
        })
    elseif Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:openInventory('stash', storage.uniqueId .. playerIdentifier())
    elseif Config.Inventory == 'custom' then
        -- Add your own inventory here
    end
end

closeInventoryIntegration = function()
    if Config.Inventory == 'chezza_v3' then
        -- The is no export for that
    elseif Config.Inventory == 'chezza_v4' then
        exports.inventory:CloseInventory()
    elseif Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:closeInventory()
    elseif Config.Inventory == 'custom' then
        -- Add your own inventory here
    end
end