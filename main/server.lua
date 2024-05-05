Framework = nil
Framework = GetFramework()
Citizen.Await(Framework)
Callback = Config.Framework == "ESX" or Config.Framework == "NewESX" and Framework.RegisterServerCallback or Framework.Functions.CreateCallback
local tattooList = {}
local Players = json.decode(LoadResourceFile(GetCurrentResourceName(), "/Players.json"))

Citizen.CreateThread(function()
    while Framework == nil do
        Citizen.Wait(750)
    end
    Citizen.Wait(2500)
    for _,v in pairs(GetPlayers()) do
        local AGA = (Config.Framework == "ESX" or Config.Framework == "NewESX") and Framework.GetPlayerFromId(tonumber(v)) and Framework.GetPlayerFromId(tonumber(v)).identifier or (Framework.Functions.GetPlayer(tonumber(v)) and Framework.Functions.GetPlayer(tonumber(v)).PlayerData and Framework.Functions.GetPlayer(tonumber(v)).PlayerData.citizenid)
        if AGA then
            local Players = json.decode(LoadResourceFile(GetCurrentResourceName(), "/Players.json")) or {}
            local playerTattoos = Players[AGA]
            if playerTattoos then
                TriggerClientEvent('Apply:Tattoo', v, playerTattoos)
            else
                print("No tattoo data available for player ID:", AGA)
            end
        else
            print("Could not retrieve player ID for source:", v)
        end
        Wait(74)
    end
end)

Callback('SmallTattoos:RemoveTattoo', function(source, cb, tattooData)
    local src = source
    local Player = Framework.Functions.GetPlayer(src)
    local ID = Player and Player.PlayerData.citizenid
    if ID then
        local Players = json.decode(LoadResourceFile(GetCurrentResourceName(), "/Players.json")) or {}
        Players[ID] = Players[ID] or {}

        local updatedTattoos = {}
        for _, tattoo in ipairs(Players[ID]) do
            if tattoo.Name ~= tattooData.Name then
                table.insert(updatedTattoos, tattoo)
            end
        end
        Players[ID] = updatedTattoos
        SaveResourceFile(GetCurrentResourceName(), "/Players.json", json.encode(Players), -1)
        cb(updatedTattoos)
        TriggerClientEvent('UpdateCurrentTattoos', src, updatedTattoos)
    else
        cb(false)
    end
end)

Callback('SmallTattoos:GetPlayerTattoos', function(source, cb)
    local src = source
    local Player = Framework.Functions.GetPlayer(src)
    local ID = Player and (Player.identifier or Player.PlayerData.citizenid)
    
    if ID then
        local Players = json.decode(LoadResourceFile(GetCurrentResourceName(), "/Players.json")) or {}
        local playerTattoos = Players[ID] or {}
        cb(playerTattoos)
        print("Retrieved tattoos for player ID:", ID)
    else
        cb(nil)
        print("Player ID could not be retrieved for source:", src)
    end
end)

RegisterNetEvent("SmallTattoos:PurchaseTattoo")
AddEventHandler("SmallTattoos:PurchaseTattoo", function(data, price)
    local src = source
    local Player = Framework.Functions.GetPlayer(src)
    local ID = Player and Player.PlayerData.citizenid
    if ID then
        local tattooPrice = data.price
        if data.method == 'card' then
            if Player.Functions.RemoveMoney('bank', tattooPrice, "Purchased Tattoo - Bank") then
                applyTattoo(data, ID, src, Player)
            else
                TriggerClientEvent('SmallTattoos:Notify', src, 'Insufficient funds in bank account.')
            end
        else
            if Player.Functions.RemoveMoney('cash', tattooPrice, "Purchased Tattoo - Cash") then
                applyTattoo(data, ID, src, Player)
            else
               print('Insufficient cash on hand.')
            end
        end
    end
end)

function applyTattoo(data, ID, src, Player)
    local Players = json.decode(LoadResourceFile(GetCurrentResourceName(), "/Players.json")) or {}
    Players[ID] = Players[ID] or {}

    for _, tattoo in ipairs(data.tattoo) do
        table.insert(Players[ID], tattoo)
    end
    SaveResourceFile(GetCurrentResourceName(), "/Players.json", json.encode(Players), -1)
    TriggerClientEvent('UpdateCurrentTattoos', src, Players[ID])
end


-- RegisterCommand('kanzicakmakvarmi', function(source, args, rawCommand)
--     local src = tonumber(source)
--     local Player = (Config.Framework == "ESX" or Config.Framework == "NewESX") and Framework.GetPlayerFromId(src) or Framework.Functions.GetPlayer(src)
--     local ID = Player and (Player.identifier or Player.PlayerData.citizenid)
--     if ID then
--         local Players = json.decode(LoadResourceFile(GetCurrentResourceName(), "/Players.json")) or {}
--         local playerTattoos = Players[ID]
--         if playerTattoos then
--             TriggerClientEvent('Apply:Tattoo', src, playerTattoos)
--         else
--             print("No tattoo data available for player ID:", ID)
--         end
--     else
--         print("Could not retrieve player ID for source:", src)
--     end
-- end)