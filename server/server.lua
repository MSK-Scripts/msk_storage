local datastring = LoadResourceFile(GetCurrentResourceName(), "storages.json")
database = json.decode(datastring)

RegisterNetEvent('msk_storage:registerStash', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    registerStash(xPlayer, database[xPlayer.identifier])
end)

RegisterNetEvent('msk_storage:buyStorage', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    data.storageId = tonumber(data.storageId)    
    buyStorage(xPlayer, data)
end)

RegisterNetEvent('msk_storage:upgradeStorage', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    upgradeStorage(xPlayer, data)
end)

RegisterNetEvent('msk_storage:sellStorage', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    sellStorage(xPlayer)
end)

MSK.Register('msk_storage:getPlayerStorage', function(source)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if database[xPlayer.identifier] and not database[xPlayer.identifier].unpaid then 
        return database[xPlayer.identifier]
    end

    return false
end)

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() ~= resource then return end
    saveDatabase(database)
end)

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
    if eventData.secondsRemaining == 60 then
        Wait(50000)
        saveDatabase(database) -- save 10 seconds bevor server restart
    end
end)

CreateThread(function()
    while true do
        Wait(1000 * 60 * 5) -- 5 minutes

        saveDatabase(database)
    end
end)