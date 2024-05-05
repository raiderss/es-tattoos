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

function GetFramework()
    if Config.Framework == "ESX" then
        return exports['esx']:getSharedObject()
    elseif Config.Framework == "NewESX" then
        return exports['es_extended']:getSharedObject()
    elseif Config.Framework == "QBCore" then
        return exports["qb-core"]:GetCoreObject()
    elseif Config.Framework == "OldQBCore" then
        return exports["old-qb-core"]:GetCoreObject()
    end
end



