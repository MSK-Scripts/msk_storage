isNuiOpen, isDead = false, false
currentStorage, currentStorageId = nil, nil
isPedLoaded = {}

AddEventHandler('esx:onPlayerDeath', function() isDead = true end)
AddEventHandler('esx:onPlayerSpawn', function(spawn) isDead = false end)

getIsDead = function()
    local isPlayerDead = isDead

    if GetResourceState("visn_are") ~= "missing" then
        local healthBuffer = exports.visn_are:GetHealthBuffer()
        isPlayerDead = healthBuffer.unconscious
    end

    if GetResourceState("osp_ambulance") ~= "missing" then
        local data = exports.osp_ambulance:GetAmbulanceData(GetPlayerServerId(PlayerId()))
        isPlayerDead = data.isDead or data.inLastStand
    end

    return isPlayerDead
end

CreateThread(function()
    for kid, storage in pairs(Config.Locations) do
        if storage.blip.enable then
            for k, v in pairs(storage.locations) do
                local blip = AddBlipForCoord(v.x, v.y, v.z)

                SetBlipSprite(blip, storage.blip.id)
                SetBlipScale(blip, storage.blip.scale)
                SetBlipDisplay(blip, 4)
                SetBlipColour(blip, storage.blip.color)
                SetBlipAsShortRange(blip, true)

                BeginTextCommandSetBlipName('STRING')
                AddTextComponentSubstringPlayerName(storage.blip.label)
                EndTextCommandSetBlipName(blip)
            end
        end
    end
end)

CreateThread(function()
    local shown = false

    while true do
        local sleep = 200
        currentStorage = nil
        currentStorageId = nil

        for kid, storage in pairs(Config.Locations) do
            for k, location in pairs(storage.locations) do
                local vec3 = vec3(location.x, location.y, location.z)
                local distance = #(GetEntityCoords(PlayerPedId()) - vec3)

                if storage.pedmodel.enable then
                    local pedmodel = GetHashKey(storage.pedmodel.model)
                    local npcID = pedmodel .. '-' .. kid .. '-' .. k 

                    if distance <= storage.pedmodel.distance then
                        if not isPedLoaded[npcID] or not isPedLoaded[npcID].loaded then
                            isPedLoaded[npcID] = {}

                            RequestModel(pedmodel)
                            while not HasModelLoaded(pedmodel) do
                                Wait(1)
                            end
                            local npc = CreatePed(4, pedmodel, location.x, location.y, location.z - 1.0, location.w or location.h, false, true)
                            FreezeEntityPosition(npc, true)	
                            SetEntityHeading(npc, location.w or location.h)
                            SetEntityInvincible(npc, true)
                            SetBlockingOfNonTemporaryEvents(npc, true)

                            logging('debug', 'Set NPC Storage', 'NPC:' .. npc, 'NPCID:' .. npcID)

                            isPedLoaded[npcID] = {
                                loaded = true,
                                inDistance = true,
                                hash = pedmodel,
                                pedmodel = storage.pedmodel.model,
                                npc = npc,
                                npcID = npcID,
                                location = vec3
                            }
                        end
                    else
                        if isPedLoaded[npcID] and isPedLoaded[npcID].loaded then
                            isPedLoaded[npcID].inDistance = false
                        end
                    end

                    if Config.npcVoice.enable then
                        for k, v in pairs(isPedLoaded) do
                            if isPedLoaded[v.npcID] and isPedLoaded[v.npcID].loaded then
                                local dist = #(GetEntityCoords(PlayerPedId()) - isPedLoaded[v.npcID].location)

                                if dist < Config.npcVoice.inRange and not isPedLoaded[v.npcID].hasSpeak then
                                    PlayPedAmbientSpeechNative(isPedLoaded[v.npcID].npc, 'GENERIC_HI', 'SPEECH_PARAMS_FORCE_NO_REPEAT_FRONTEND')
                                    isPedLoaded[v.npcID].hasSpeak = true
                                elseif dist > Config.npcVoice.outRange and isPedLoaded[v.npcID].hasSpeak then
                                    PlayPedAmbientSpeechNative(isPedLoaded[v.npcID].npc, 'GENERIC_BYE', 'SPEECH_PARAMS_FORCE_NO_REPEAT_FRONTEND')
                                    isPedLoaded[v.npcID].hasSpeak = false
                                end
                            end
                        end
                    end
                else
                    if distance <= storage.marker.distance then 
                        if storage.marker.enable then
                            DrawMarker(storage.marker.type, location.x, location.y, location.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, storage.marker.size.a, storage.marker.size.b, storage.marker.size.c, storage.marker.color.a, storage.marker.color.b, storage.marker.color.c, 100, false, true, 0, false)
                        end
                    end
                end

                if distance <= 5.0 then
                    sleep = 0
                end

                if distance <= 2.5 then
                    currentStorage = storage
                    currentStorageId = kid

                    if not IsPedInAnyVehicle(PlayerPedId()) and not getIsDead() then
                        if not shown then
                            if Config.defaultTextUI then
                                MSK.HelpNotification(Translation[Config.Locale]['open_storage']:format(storage.label))
                            elseif not Config.defaultTextUI then 
                                shown = true
                                Config.openTextUI(Translation[Config.Locale]['open_storage']:format(storage.label), Translation[Config.Locale]['open_storage_textui']:format(storage.label))
                            end
                        end

                        if IsControlJustReleased(0, Config.Hotkey) then
                            shown = true
                            openStorage()
                        end
                    end
                end
            end
        end

        if currentStorage and shown and not isNuiOpen and Config.defaultTextUI then
            shown = false
        elseif not currentStorage and shown then
            shown = false

            if not Config.defaultTextUI then 
                Config.closeTextUI() 
            end

            closeInventoryIntegration()
        end

        for k, v in pairs(isPedLoaded) do
            if v.loaded and not v.inDistance then
                logging('debug', 'Delete NPC Storage', 'NPC:' .. v.npc, 'NPCID' .. v.npcID)
                DeleteEntity(v.npc)
                SetModelAsNoLongerNeeded(v.hash)
                isPedLoaded[v.npcID] = {}
            end
        end

        Wait(sleep)
    end
end)

RegisterNUICallback("action", function(data)
    closeStorage()

    if data.type == 'buy' then
        TriggerServerEvent('msk_storage:buyStorage', data)
    elseif data.type == 'upgrade' then
        TriggerServerEvent('msk_storage:upgradeStorage', data)
    else
        TriggerServerEvent('msk_storage:sellStorage', data)
    end
end)

RegisterNUICallback("openStorage", function()
    closeStorage()
    openStorageInventory()
end)

RegisterNUICallback("closeUI", function()
    closeStorage(true)
end)