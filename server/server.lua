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

GithubUpdater = function()
    local GetCurrentVersion = function()
	    return GetResourceMetadata(GetCurrentResourceName(), "version")
    end

	local isVersionIncluded = function(Versions, cVersion)
		for k, v in pairs(Versions) do
			if v.version == cVersion then
				return true
			end
		end

		return false
	end
    
    local CurrentVersion = GetCurrentVersion()
    local resourceName = "^0[^2"..GetCurrentResourceName().."^0]"

    if Config.VersionChecker then
        PerformHttpRequest('https://raw.githubusercontent.com/Musiker15/VERSIONS/main/Storage.json', function(errorCode, jsonString, headers)
			if not jsonString then 
                print(resourceName .. '^1Update Check failed ^3Please Update to the latest Version: ^9https://keymaster.fivem.net/^0')
                print(resourceName .. '^2 ✓ Resource loaded^0 - ^5Current Version: ^0' .. CurrentVersion)
                return
            end

			local decoded = json.decode(jsonString)
            local version = decoded[1].version

            if CurrentVersion == version then
                print(resourceName .. '^2 ✓ Resource is Up to Date^0 - ^5Current Version: ^2' .. CurrentVersion .. '^0')
            elseif CurrentVersion ~= version then
                print(resourceName .. '^1 ✗ Resource Outdated. Please Update!^0 - ^5Current Version: ^1' .. CurrentVersion .. '^0')
                print('^5Latest Version: ^2' .. version .. '^0 - ^6Download here: ^9https://keymaster.fivem.net/^0')
				if not string.find(CurrentVersion, 'beta') then
					for i=1, #decoded do 
						if decoded[i]['version'] == CurrentVersion then
							break
						elseif not isVersionIncluded(decoded, CurrentVersion) then
							print('^1You are using an^3 UNSUPPORTED VERSION^1 of ^0' .. resourceName)
							break
						end

						if decoded[i]['changelogs'] then
							print('^3Changelogs v' .. decoded[i]['version'] .. '^0')

							for _, c in ipairs(decoded[i]['changelogs']) do
								print(c)
							end
						end
					end
				else
					print('^1You are using the^3 BETA VERSION^1 of ^0' .. resourceName)
				end
            end
        end)
    else
        print(resourceName .. '^2 ✓ Resource loaded^0 - ^5Current Version: ^2' .. CurrentVersion .. '^0')
    end
end
GithubUpdater()