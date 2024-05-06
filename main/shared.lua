Config = {
    Framework = 'QBCore',  -- QBCore or ESX or OLDQBCore or NewESX
    InteractionKey = 'E',  -- Default interaction key
    InteractionKeyCode = 38,  -- Default key code for E
    Marker = {
        drawDistance = 10.0, -- Visibility distance of the marker
        markerType = 2,  -- Example marker type
        markerScale = {x = 0.3, y = 0.2, z = 0.15}, -- Scale of the marker
        markerColor = {r = 255, g = 255, b = 255, a = 255} -- Color of the marker
    },
    Shops = {
        vector3(1322.6, -1651.9, 51.2),
        vector3(-1153.6, -1425.6, 4.9),
        vector3(322.1, 180.4, 103.5),
        vector3(-3170.0, 1075.0, 20.8),
        vector3(1864.6, 3747.7, 33.0),
        vector3(-293.7, 6200.0, 31.4)
    }
}

function GetFramework() -- eyw knk cözdüm
    local Get = nil
    if Config.Framework == "ESX" then
        while Get == nil do
            TriggerEvent('esx:getSharedObject', function(Set) Get = Set end)
            Citizen.Wait(0)
        end
    end
    if Config.Framework == "NewESX" then
        Get = exports['es_extended']:getSharedObject()
    end
    if Config.Framework == "QBCore" then
        Get = exports["qb-core"]:GetCoreObject()
    end
    if Config.Framework == "OLDQBCore" then
        while Get == nil do
            TriggerEvent('QBCore:GetObject', function(Set) Get = Set end)
            Citizen.Wait(200)
        end
    end
    return Get
end

