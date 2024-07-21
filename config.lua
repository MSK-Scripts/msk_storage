Config = {}
----------------------------------------------------------------
Config.Locale = 'de'
Config.Debug = false
----------------------------------------------------------------
-- !!! This function is clientside AND serverside !!!
Config.Notification = function(source, message, typ)
    if IsDuplicityVersion() then -- serverside
        MSK.Notification(source, 'MSK Storage', message, typ, 5000)
    else -- clientside
        MSK.Notification('MSK Storage', message, typ, 5000)
    end
end
----------------------------------------------------------------
Config.Hotkey = 38 -- default: 38 = E // Change the Key in translation.lua too

Config.npcVoice = {
    enable = true, -- The NPC will say something to you
    inRange = 5.0,
    outRange = 5.0
}

Config.PayCron = 7 -- in days // After X days the amount will be removed from player
Config.MinBudget = 10000 -- Money that remains on the Bankaccount if Player can't pay
----------------------------------------------------------------
-- Set to 'chezza_v3', 'chezza_v4', 'ox_inventory' or 'custom'
-- If set to 'custom' then go to integration folder and add your inventory
Config.Inventory = 'chezza_v3'
----------------------------------------------------------------
Config.defaultTextUI = true -- Set false if you want to use a custom textui

Config.openTextUI = function(coloredText, uncoloredText)
    exports['okokTextUI']:Open(uncoloredText, 'darkblue', 'left')
end

Config.closeTextUI = function()
    exports['okokTextUI']:Close()
end
----------------------------------------------------------------
Config.Storages = {
    -- [id] must be a number, otherwise you'll break the script!

    [1] = {
        label = {'Warehouse', 'Tier 1'},
        price = 5000,
        weight = 1000,
        slots = 10, 
        image = 'storage_1.png'
    },
    [2] = {
        label = {'Warehouse', 'Tier 2'},
        price = 15000,
        weight = 5000,
        slots = 15, 
        image = 'storage_2.png'
    },
    [3] = {
        label = {'Warehouse', 'Tier 3'},
        price = 45000,
        weight = 10000,
        slots = 20, 
        image = 'storage_3.png'
    },
}

Config.Locations = {
    -- Marker is only available if pedmodel.enable = false

    ['l1'] = {
        title = 'Warehouse',
        subtitle = 'Hafen',
        storages = {1, 2, 3},
        blip = {enable = true, label = 'Warehouse', id = 473, color = 2, scale = 0.8},
        pedmodel = {enable = true, model = 'csb_trafficwarden', distance = 20.0},
        marker = {enable = true, distance = 5.0, type = 27, size = {a = 1.0, b = 1.0, c = 1.0}, color = {a = 255, b = 255, c = 255}},
        locations = {
            vector4(141.82, -3097.87, 5.9, 4.26),
        }
    },
    ['l2'] = {
        title = 'Warehouse',
        subtitle = 'Harmony',
        storages = {1, 2},
        blip = {enable = true, label = 'Warehouse', id = 473, color = 2, scale = 0.8},
        pedmodel = {enable = true, model = 'csb_trafficwarden', distance = 20.0},
        marker = {enable = true, distance = 5.0, type = 27, size = {a = 1.0, b = 1.0, c = 1.0}, color = {a = 255, b = 255, c = 255}},
        locations = {
            vector4(585.81, 2782.25, 43.47, 0.0),
        }
    },
}