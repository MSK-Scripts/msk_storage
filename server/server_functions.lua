local uniqueIds = {}
local Jobs = {}

saveDatabase = function(data)
    SaveResourceFile(GetCurrentResourceName(), "storages.json", json.encode(data, { indent = true }), -1)
end

getDatabase = function()
    return database
end
exports('getDatabase', getDatabase)

registerUniqueIds = function()
    for ident, v in pairs(database) do
        uniqueIds[v.uniqueId] = v.uniqueId
    end
end
registerUniqueIds()

createUniqueId = function()
    local uId = math.random(1, 999999999999)

    if uniqueIds[uId] then
        return createUniqueId()
    end

    uniqueIds[uId] = uId

    return uId
end

doesStorageExist = function(identifier)
    if not identifier then return false end
    if not database[identifier] then return false end
    return true
end

buyStorage = function(xPlayer, data)
    data.storageId = tonumber(data.storageId) 
    
    if xPlayer.GetMoney(data.method) < data.storageData.price then
        if data.method == 'money' then
            Config.Notification(xPlayer.source, Translation[Config.Locale]['not_enough_money'], 'error')
        else
            Config.Notification(xPlayer.source, Translation[Config.Locale]['not_enough_bank'], 'error')
        end
        return
    end

    -- RemoveMoney refuses when the balance is short and says so, instead of
    -- silently going negative like removeAccountMoney did.
    if not xPlayer.RemoveMoney(data.method, data.storageData.price) then
        Config.Notification(xPlayer.source, Translation[Config.Locale]['not_enough_bank'], 'error')
        return
    end

    if doesStorageExist(xPlayer.identifier) then
        database[xPlayer.identifier].unpaid = false
        database[xPlayer.identifier].storageId = data.storageId
        database[xPlayer.identifier].storageData = data.storageData
        database[xPlayer.identifier].date = os.time() + (60 * 60 * 24 * Config.PayCron)
    else
        database[xPlayer.identifier] = {
            playerName = xPlayer.name,
            storageId = data.storageId,
            storageData = data.storageData,
            uniqueId = createUniqueId(),
            date = os.time() + (60 * 60 * 24 * Config.PayCron)
        }
    end

    registerStash(xPlayer.identifier, database[xPlayer.identifier])

    saveDatabase(database)
    createCron(xPlayer.identifier, database[xPlayer.identifier].date, executeCron)
    Config.Notification(xPlayer.source, Translation[Config.Locale]['storage_bought']:format(data.storageData.label[1], data.storageData.label[2], MSK.Comma(data.storageData.price)), 'success')
end

upgradeStorage = function(xPlayer, data)
    if not database[xPlayer.identifier] then return end

    if xPlayer.GetMoney(data.method) < (data.storageData.price - database[xPlayer.identifier].storageData.price) then
        if data.method == 'money' then
            Config.Notification(xPlayer.source, Translation[Config.Locale]['not_enough_money'], 'error')
        else
            Config.Notification(xPlayer.source, Translation[Config.Locale]['not_enough_bank'], 'error')
        end
        return
    end

    -- Difference between the old and the new storage price.
    if not xPlayer.RemoveMoney(data.method, data.storageData.price - database[xPlayer.identifier].storageData.price) then
        Config.Notification(xPlayer.source, Translation[Config.Locale]['not_enough_bank'], 'error')
        return
    end

    database[xPlayer.identifier] = {
        playerName = xPlayer.name,
        storageId = data.storageId,
        storageData = data.storageData,
        uniqueId = database[xPlayer.identifier].uniqueId
    }

    upgradeStash(xPlayer.identifier, database[xPlayer.identifier])

    saveDatabase(database)
    Config.Notification(xPlayer.source, Translation[Config.Locale]['storage_upgraded']:format(data.storageData.label[1], data.storageData.label[2], MSK.Comma(data.storageData.price)), 'success')
end

sellStorage = function(xPlayer)
    if not database[xPlayer.identifier] then return end
    removeUniqueId(database[xPlayer.identifier].uniqueId)
    removeCronjob(xPlayer.identifier)
    removeInventoryData(xPlayer.identifier, database[xPlayer.identifier].uniqueId)
    Config.Notification(xPlayer.source, Translation[Config.Locale]['storage_sold'], 'success')
end

removeUniqueId = function(id)
    if not id then return end
    if not uniqueIds[id] then return end
    uniqueIds[id] = nil
end

removeCronjob = function(identifier)
    for i=1, #Jobs, 1 do
        if Jobs[i].identifier == identifier then
            Jobs[i] = nil
            break
        end
    end
end

removeInventoryData = function(identifier, id)
    database[identifier] = nil
    saveDatabase(database)
    local storageId = id .. identifier

    if Config.Inventory == 'chezza_v3' or Config.Inventory == 'chezza_v4' then
        MySQL.query('DELETE FROM inventories WHERE type = ? AND identifier = ?', {
            'msk_storage', storageId
        })
    elseif Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:ClearInventory(storageId)
    end
end

createCron = function(identifier, timestamp, cb)
    Jobs[#Jobs + 1] = {
		identifier = identifier,
		timestamp = timestamp,
		cb = cb
	}
end

tickCron = function()
    local currTime = os.time()
    local currD = tonumber(os.date('%d', currTime))
    local currH = tonumber(os.date('%H', currTime))
    local currM = tonumber(os.date('%M', currTime))

    for i=1, #Jobs, 1 do
        local timestamp = Jobs[i].timestamp
        local d = tonumber(os.date('%d', timestamp))
	    local h = tonumber(os.date('%H', timestamp))
	    local m = tonumber(os.date('%M', timestamp))

        if currD == d and currH == h and currM == m then
            database[Jobs[i].identifier].date = os.time() + (60 * 60 * 24 * Config.PayCron)
            Jobs[i].cb(Jobs[i].identifier)
        end
    end

    SetTimeout(60000, tickCron)
end
tickCron()

executeCron = function(identifier)
    if not database[identifier] then return end

    local price = database[identifier].storageData.price
    local xPlayer = MSK.GetPlayerFromIdentifier(identifier)

    if xPlayer then
        local money = xPlayer.GetMoney('bank')

        if money >= price and Config.MinBudget >= (money - price) then
            xPlayer.RemoveMoney('bank', price)
            executeSociety(price)
        else
            removeCronjob(identifier)
            database[identifier].unpaid = true
        end

        return
    end

    -- Offline. MSK.Offline knows where each framework keeps the bank balance
    -- (users.accounts on ESX, players.money on QBCore and Qbox) and deducts in
    -- a single statement with a WHERE guard. The version before read the row,
    -- did the arithmetic in Lua and wrote it back, which loses one of two
    -- deductions that happen at the same moment, and it only knew ESX.
    local money = MSK.Offline.GetBank(identifier)

    if money and money >= price and Config.MinBudget >= (money - price) then
        if MSK.Offline.RemoveBank(identifier, price) then
            executeSociety(price)
            return
        end
    end

    removeCronjob(identifier)
    database[identifier].unpaid = true
end

executeSociety = function(storagePrice)
    if not Config.Society.enable then return end

    -- MSK.Society finds whichever banking resource is installed (Renewed-Banking,
    -- qb-banking, qb-management or esx_addonaccount) instead of assuming
    -- esx_addonaccount, which only exists on ESX.
    for societyName, percent in pairs(Config.Society.societies) do
        MSK.Society.AddMoney(societyName, math.floor(storagePrice * percent))
    end
end

registerCronJobs = function()
    for identifier, v in pairs(database) do
        createCron(identifier, v.date, executeCron)
    end
end
registerCronJobs()

logging = function(code, ...)
    if not Config.Debug then return end
    MSK.Logging(code, ...)
end