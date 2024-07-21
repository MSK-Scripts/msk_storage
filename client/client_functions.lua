openStorage = function()
    isNuiOpen = true

    local hasStorage = hasPlayerStorage()

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openUI',
        payCron = Config.PayCron,
        locales = Translation[Config.Locale],
        hasStorage = hasStorage,
        storageId = currentStorageId,
        currentStorage = currentStorage,
        availableStorages = getAvailableStorages(currentStorageId, hasStorage)
    })
end
exports('openStorage', openStorage)

closeStorage = function(notSend)
    isNuiOpen = false
    SetNuiFocus(false, false)

    if notSend then return end
    SendNUIMessage({
        action = "closeUI",
    })
end
exports('closeStorage', closeStorage)

openStorageInventory = function()
    local storage = hasPlayerStorage()
    if not storage then return end

    openInventoryIntegration(storage)
end

hasPlayerStorage = function()
    return MSK.Trigger('msk_storage:getPlayerStorage') or false
end

getAvailableStorages = function(storageId, hasStorage)
    local storages = {}

    for k, v in pairs(Config.Locations[storageId].storages) do
        storages[v] = Config.Storages[v]
    end

    if hasStorage then
        for k, v in pairs(storages) do            
            if k <= tonumber(hasStorage.storageId) then
                storages[k] = nil
            end
        end
    end

    return storages
end

logging = function(code, ...)
    if not Config.Debug then return end
    MSK.Logging(code, ...)
end