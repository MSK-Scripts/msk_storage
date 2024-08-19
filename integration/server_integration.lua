registerStash = function(identifier, storage)
    if Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:RegisterStash(
            storage.uniqueId .. identifier, 
            storage.storageData.label[1] .. ' ' .. storage.storageData.label[2], 
            storage.storageData.slots, 
            storage.storageData.weight, 
            identifier
        )
    elseif Config.Inventory == 'custom' then
        -- Add your own inventory here
    end
end

upgradeStash = function(identifier, storage)
    if Config.Inventory == 'ox_inventory' then
        local id = storage.uniqueId .. identifier

        exports.ox_inventory:SetMaxWeight(id, storage.storageData.weight)
        exports.ox_inventory:SetSlotCount(id, storage.storageData.slots)
    elseif Config.Inventory == 'custom' then
        -- Add your own inventory here
    end
end

registerStashes = function()
    if Config.Inventory == 'chezza_v3' or Config.Inventory == 'chezza_v4' then return end
    while not database do Wait(100) end

    if Config.Inventory == 'ox_inventory' then
        for identifier, storage in pairs(database) do
            local inventory = exports.ox_inventory:GetInventory(storage.uniqueId .. identifier, false)

            if not inventory then
                registerStash(identifier, storage)
            end
        end
    elseif Config.Inventory == 'custom' then
        -- Add your own inventory here
    end
end
registerStashes()