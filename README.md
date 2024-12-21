# [TATTOOS SHOPS](https://www.youtube.com/watch?v=2WVjORQ_Xro)

[![YouTube Subscribe](https://img.shields.io/badge/YouTube-Subscribe-red?style=for-the-badge&logo=youtube)](https://www.youtube.com/watch?v=2WVjORQ_Xro)
[![Discord](https://img.shields.io/badge/Discord-Join-blue?style=for-the-badge&logo=discord)](https://discord.gg/EkwWvFS)
[![Tebex Store](https://img.shields.io/badge/Tebex-Store-green?style=for-the-badge&logo=shopify)](https://eyestore.tebex.io/)

**Tattoos Shops** is a simple script that allows you to discover and apply a variety of different tattoos. For now, this script is specifically designed to work with the QBCore framework.

Use the example below to refresh and upload tattoos in a refreshskin or x way:

```
RegisterCommand("refresh", function()
    local playerPed = PlayerPedId()
    local maxhealth = GetEntityMaxHealth(playerPed)
    local health = GetEntityHealth(playerPed)

   -- This is the important part, according to your framework, if it is ESX, use ESX.RegisterServerCallback as ESX.RegisterServerCallback means get the data and confirm tatto 
     and load it.
    QBCore.Functions.TriggerCallback("SmallTattoos:GetPlayerTattoos", function(tattoo)
        if tattoo then
            TriggerEvent('Apply:Tattoo', tattoo)
        else
            print("No tattoos found for this player.")
        end
    end)
    --

    reloadSkin(health, maxhealth) 
end)

function reloadSkin(health, maxhealth)
    local model = nil
    local gender = QBCore.Functions.GetPlayerData().charinfo.gender
    if gender == 1 then 
        model = GetHashKey("mp_f_freemode_01") 
    else
        model = GetHashKey("mp_m_freemode_01") 
    end
    RequestModel(model)
    while not HasModelLoaded(model) do -
        Citizen.Wait(500)
    end
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)
    Citizen.Wait(1000) 
    TriggerServerEvent("qb-clothes:loadPlayerSkin")
    TriggerServerEvent("qb-clothing:loadPlayerSkin")
    SetPedMaxHealth(PlayerId(), maxhealth)
    Citizen.Wait(1000) 
    SetEntityHealth(playerPed, health)
end
```

Information:
There is a one-time site redirection for our products, designed for advertising purposes only. Please note, this is not a virus; it is simply an href transfer.

![Tattoos Shops Script Preview](https://github.com/raiderss/es-tattoos/assets/53000629/31e5e972-83fb-424c-95df-dcb6d3708d54)

## Features
- **Extensive Tattoo Collection**: Access a wide range of tattoo designs tailored to different preferences.
- **QBCore Integration**: Fully compatible with QBCore, ensuring a seamless integration.

## Tebex Store
Explore premium features and support our development by visiting our Tebex store:
[![Tebex](https://img.shields.io/badge/Tebex-EYE%20STORE-00A2FF.svg)](https://eyestore.tebex.io/)

## Discord Community
Join our Discord community for real-time support and regular updates:
[![Discord](https://img.shields.io/badge/Discord-ES%20Community-7289DA.svg)](https://discord.gg/EkwWvFS)

## Contributors
- **Raider#0101**
