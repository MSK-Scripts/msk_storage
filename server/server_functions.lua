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
    
    if xPlayer.getAccount(data.method).money < data.storageData.price then
        if data.method == 'money' then
            Config.Notification(xPlayer.source, Translation[Config.Locale]['not_enough_money'], 'error')
        else
            Config.Notification(xPlayer.source, Translation[Config.Locale]['not_enough_bank'], 'error')
        end
        return
    end

    xPlayer.removeAccountMoney(data.method, data.storageData.price)

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

    if xPlayer.getAccount(data.method).money < (data.storageData.price - database[xPlayer.identifier].storageData.price) then
        if data.method == 'money' then
            Config.Notification(xPlayer.source, Translation[Config.Locale]['not_enough_money'], 'error')
        else
            Config.Notification(xPlayer.source, Translation[Config.Locale]['not_enough_bank'], 'error')
        end
        return
    end

    xPlayer.removeAccountMoney(data.method, data.storageData.price - database[xPlayer.identifier].storageData.price) -- Differenz Berechnnung

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
    local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
    
    if xPlayer then
        local money = xPlayer.getAccount('bank').money
        
        if money >= database[identifier].storageData.price and Config.MinBudget >= (money - database[identifier].storageData.price) then
            xPlayer.removeAccountMoney('bank', database[identifier].storageData.price)
            executeSociety(database[identifier].storageData.price)
        else
            removeCronjob(identifier)
            database[identifier].unpaid = true
        end
    else
        MySQL.query("SELECT * FROM users WHERE identifier = ?", {identifier}, function(data)
            if data and data[1] then
                local account = json.decode(data[1].accounts)
                
                if account.bank >= database[identifier].storageData.price and Config.MinBudget >= (account.bank - database[identifier].storageData.price) then
                    account.bank = account.bank - database[identifier].storageData.price
                    MySQL.update("UPDATE users SET accounts = ? WHERE identifier = ?", {json.encode(account), identifier})
                    executeSociety(database[identifier].storageData.price)
                else
                    removeCronjob(identifier)
                    database[identifier].unpaid = true
                end
            end
        end)
    end
end

executeSociety = function(storagePrice)
    if not Config.Society.enable then return end

    for societyName, percent in pairs(Config.Society.societies) do
        local price = storagePrice * percent

        TriggerEvent('esx_addonaccount:getSharedAccount', societyName, function(account)
            if not account then return end
            account.addMoney(price)
        end)
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