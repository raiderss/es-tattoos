local currentTattoos = {}
local cam = nil
local display = false
local zoom, camera, cameraActive, cameraAlignment, zoomOffset
Framework = nil
Framework = GetFramework()
Citizen.CreateThread(function()
   while Framework == nil do Citizen.Wait(750) end
   Citizen.Wait(2500)
end)
Callback = Config.Framework == "ESX" or Config.Framework == "NewESX" and Framework.TriggerServerCallback or Framework.Functions.TriggerCallback

RegisterNUICallback("exit",function(data)
    SetDisplay(false)
    DisplayRadar(true)
    ResetCamera()
    exports[GetCurrentResourceName()]:reloadSkin()
end)

Citizen.CreateThread(function()
	AddTextEntry("ParaTattoos", "Tattoo Shop")
	for k, v in pairs(Config.Shops) do
		local blip = AddBlipForCoord(v)
		SetBlipSprite(blip, 75)
		SetBlipColour(blip, 1)
		SetBlipScale(blip, 0.8)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("ParaTattoos")
		EndTextCommandSetBlipName(blip)
	end
end)

local keyToInteract = 38 -- Default: E

function DrawText3D(text, x, y, z, scale, font, r, g, b, a)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)
    scale = (1 / dist) * 20 * scale
    if onScreen then
        SetTextScale(0.0, scale)
        SetTextFont(font)
        SetTextProportional(1)
        SetTextColour(r, g, b, a)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local handled = false
        for _, shopCoords in ipairs(Config.Shops) do
            local dist = #(playerCoords - shopCoords)
            if dist < 5 then  
                if dist < Config.Marker.drawDistance then  
                    DrawMarker(Config.Marker.markerType, shopCoords.x, shopCoords.y, shopCoords.z - 1.0, 0, 0, 0, 0, 0, 0, Config.Marker.markerScale.x, Config.Marker.markerScale.y, Config.Marker.markerScale.z, Config.Marker.markerColor.r, Config.Marker.markerColor.g, Config.Marker.markerColor.b, Config.Marker.markerColor.a, false, true, 2, nil, nil, false)
                    DrawText3D(shopCoords.x, shopCoords.y, shopCoords.z + 0.5, "[E] Interact", 0.4, 4, 255, 255, 255, 255)
                    if IsControlJustReleased(0, Config.InteractionKeyCode) then
                        handled = true
                        local playerPed = PlayerPedId()  
                        Callback('SmallTattoos:GetPlayerTattoos', function(tattooList)
                            if tattooList and #tattooList > 0 then
                                ClearPedDecorations(playerPed)  
                                for _, tattoo in ipairs(tattooList) do
                                    currentTattoos = tattooList  
                                    local collectionHash = GetHashKey(tattoo.Collection)
                                    local overlayHash = GetHashKey(tattoo.HashNameMale) 
                                    if IsPedMale(playerPed) == false and tattoo.HashNameFemale ~= "" then
                                        overlayHash = GetHashKey(tattoo.HashNameFemale) 
                                    end
                                    ApplyPedOverlay(playerPed, collectionHash, overlayHash)
                                end
                                for _, tattoo in ipairs(tattooList) do
                                    local data = {
                                        Zone = tattoo.Zone,
                                        Collection = tattoo.Collection,
                                        Name = tattoo.Name,
                                        Price = tattoo.Price or ""
                                    }
                                    SendNUIMessage({ data = "GET", remove = data})
                                end
                                SetDisplay(true)  
                                GetNaked()  
                            else
                                SetDisplay(true) 
                                GetNaked()
                                SendNUIMessage({ data = "GET" }) 
                            end
                        end)  
                        break  
                    end
                end
            end
        end
        if handled then
            Citizen.Wait(500)  
        end
    end
end)


-- TriggerServerEvent('qb-clothes:loadPlayerSkin')


local function reloadSkin()
    TriggerServerEvent('qb-clothes:loadPlayerSkin')
    Citizen.Wait(1000)  
    local playerPed = PlayerPedId() 
    ClearPedDecorations(playerPed)  
    if currentTattoos and #currentTattoos > 0 then
        for _, tattoo in ipairs(currentTattoos) do
            local collectionHash = GetHashKey(tattoo.Collection)
            local overlayHash = GetHashKey(IsPedMale(playerPed) and tattoo.HashNameMale or tattoo.HashNameFemale)
            SetPedDecoration(playerPed, collectionHash, overlayHash)  -- Dövmeyi uygular
        end
    else
        print("Forging list empty or failed to load.")
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    Citizen.Wait(3000) 
    local playerPed = PlayerPedId() 
    Callback('SmallTattoos:GetPlayerTattoos', function(tattooList)
        if tattooList and #tattooList > 0 then
            ClearPedDecorations(playerPed)
            for _, tattoo in ipairs(tattooList) do
                local collectionHash = GetHashKey(tattoo.Collection)
                local overlayHash = GetHashKey(IsPedMale(playerPed) and tattoo.HashNameMale or tattoo.HashNameFemale)
                ApplyPedOverlay(playerPed, collectionHash, overlayHash)
            end
            currentTattoos = tattooList
            print("Tattoos loaded successfully.")
        else
            print("Tattoo list empty or failed to load tattoos.")
        end
    end)
end)


RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
	currentTattoos = {}
end)

RegisterNetEvent('Apply:Tattoo', function(tattooList)
    local playerPed = PlayerPedId()
    ClearPedDecorations(playerPed) 
    if tattooList then
        for _, tattoo in ipairs(tattooList) do
            local collectionHash = GetHashKey(tattoo.Collection)
            local overlayHash = IsPedMale(playerPed) and GetHashKey(tattoo.HashNameMale) or GetHashKey(tattoo.HashNameFemale)
            ApplyPedOverlay(playerPed, collectionHash, overlayHash)
        end
        currentTattoos = tattooList
    end
end)



-- Exports
exports('reloadSkin', reloadSkin)


RegisterNUICallback("buy", function(data, price, cb)
    TriggerServerEvent("SmallTattoos:PurchaseTattoo", data, price)
end)

RegisterNUICallback("tattoo", function(data)
    if data and data.tattoo then 
        local tattooData = data.tattoo
        if tattooData.Collection and tattooData.HashNameMale then 
            DrawTattoo(tattooData.Collection, tattooData.HashNameMale, 1)  
            DisplayRadar(false)
        else
            print("The required tattoo data is missing!")
        end
    else
        print("Tattoo list empty or failed to load tattoos")
    end
end)

DisplayRadar(false)

function DrawTattoo(collection, name, opacity)
    local playerPed = PlayerPedId()
    ClearPedDecorations(playerPed) 
    for _, tattoo in pairs(currentTattoos) do
        local collectionHash = GetHashKey(tattoo.collection)
        local nameHash = GetHashKey(tattoo.nameHash)
        SetPedDecoration(playerPed, collectionHash, nameHash)
    end
    local newCollectionHash = GetHashKey(collection)
    local newNameHash = GetHashKey(name)
    for i = 1, opacity do
        SetPedDecoration(playerPed, newCollectionHash, newNameHash)
    end
end

RegisterNetEvent('UpdateCurrentTattoos')
AddEventHandler('UpdateCurrentTattoos', function(updatedTattoos)
    currentTattoos = updatedTattoos
    RefreshTattooDisplay() 
    print("Current tattoos updated:", json.encode(currentTattoos))
end)

function RefreshTattooDisplay()
    local playerPed = PlayerPedId()
    ClearPedDecorations(playerPed)  
    for _, tattoo in ipairs(currentTattoos) do
        local collectionHash = GetHashKey(tattoo.Collection)
        local overlayHash = GetHashKey(IsPedMale(playerPed) and tattoo.HashNameMale or tattoo.HashNameFemale)
        ApplyPedOverlay(playerPed, collectionHash, overlayHash)  
    end
end


RegisterNUICallback("remove", function(data, cb)  
    Callback('SmallTattoos:RemoveTattoo', function(updatedTattoos)
        if updatedTattoos then
            currentTattoos = updatedTattoos  
            cb('ok') 
        else
            print("Failed to update tattoos.")
            cb('error', 'Failed to update tattoos')  
        end
    end, data.tattoo)  
    print('Request sent to remove tattoo:', json.encode(data))
end)



---------------------------------------------------------------------------------------------

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
end

function SetupCamera(offsetMultiplier)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, false)
    local cameraCoords = playerCoords + GetEntityForwardVector(playerPed) * offsetMultiplier 
    SetCamCoord(cam, cameraCoords.x, cameraCoords.y, cameraCoords.z + 0.5)
    PointCamAtCoord(cam, playerCoords.x, playerCoords.y, playerCoords.z + 0.5)
end

RegisterNUICallback('turn', function(data, cb)
    if data.direction == "left" then
        SetupCamera(1.5)  
    elseif data.direction == "right" then
        SetupCamera(-1.5)  
    end
    if cb then cb('ok') end
end)

function GetNaked()
	if GetEntityModel(PlayerPedId()) == `mp_m_freemode_01` then
		TriggerEvent('qb-clothing:client:loadOutfit', {
			outfitData = {
				["arms"] = { item = 15, texture = 0 },
				["t-shirt"] = { item = 15, texture = 0 },
				["torso2"] = { item = 91, texture = 0 },
				["pants"] = { item = 14, texture = 0 },
				["shoes"] = { item = 5, texture = 0 },
				["glass"] = { item = 0, texture = 0 }
			}
		})
	else
		TriggerEvent('qb-clothing:client:loadOutfit', {
			outfitData = {
				["arms"] = { item = 15, texture = 0 },
				["t-shirt"] = { item = 34, texture = 0 },
				["torso2"] = { item = 101, texture = 1 },
				["pants"] = { item = 16, texture = 0 },
				["shoes"] = { item = 5, texture = 0 },
				["glass"] = { item = 5, texture = 0 }
			}
		})
	end
end


RegisterNUICallback("camera",function(zone)
    CreateCamera()
    zoom = zone.camera
end)


function ResetCamera()
    RenderScriptCams(false, true, 250, 1, 0)
    DestroyCam(cam, false)
    FreezeEntityPosition(PlayerPedId(), false)
end

function CreateCamera()
    if not DoesCamExist(camera) then
        camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    end
    DisplayRadar(false)

    SetCamActive(camera, true)
    RenderScriptCams(true, true, 500, true, true)

    local playerPed = PlayerPedId()
    local playerHeading = GetEntityHeading(playerPed)
    FreezeEntityPosition(playerPed, false)
    
    if playerHeading + 94 < 360.0 then
        cameraAlignment = playerHeading + 94.0
    else
        cameraAlignment = playerHeading - 266.0 
    end
    
    cameraActive = true
    SetCamCoord(camera, GetEntityCoords(playerPed))
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if cameraActive then
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local zoomOffset, camOffset
            if zoom == "ZONE_HEAD" then
                zoomOffset = 0.5
                camOffset = 0.7
            elseif zoom == "ZONE_TORSO" then
                zoomOffset = 1.2
                camOffset = 0.5
            elseif zoom == "ZONE_REMOVAL" then 
                zoomOffset = 1.2
                camOffset = 0.5
            elseif zoom == "ZONE_LEFT_LEG" then
                zoomOffset = 1.2
                camOffset = -0.3
            elseif zoom == "ZONE_RIGHT_LEG" then 
                zoomOffset = 1.2
                camOffset = -0.3
            elseif zoom == "ZONE_LEFT_ARM" then
                zoomOffset = 1.8 
                camOffset = 0.0   
            elseif zoom == "ZONE_RIGHT_ARM" then
                zoomOffset = 1.8  
                camOffset = 0.0  
            end
            
            local angle = cameraAlignment * math.pi / 180
            local direction = {
                x = math.cos(angle),
                y = math.sin(angle)
            }

            local cameraPosition = {
                x = coords.x + (zoomOffset * direction.x),
                y = coords.y + (zoomOffset * direction.y)
            }

            local lookAngle = cameraAlignment - 180
            if lookAngle > 360 then
                lookAngle = lookAngle - 360
            elseif lookAngle < 0 then
                lookAngle = lookAngle + 360
            end

            lookAngle = lookAngle * math.pi / 180
            local lookDirection = {
                x = math.cos(lookAngle),
                y = math.sin(lookAngle)
            }

            local lookPosition = {
                x = coords.x + (zoomOffset * lookDirection.x),
                y = coords.y + (zoomOffset * lookDirection.y)
            }

            SetCamCoord(camera, cameraPosition.x, cameraPosition.y, coords.z + camOffset)
            PointCamAtCoord(camera, lookPosition.x, lookPosition.y, coords.z + camOffset)
        else
            Citizen.Wait(500)
        end
    end
end)

Citizen.CreateThread(function()
    AddTextEntry("ParaTattoos", "Tattoo Shop")
    for k, v in pairs(Config.Shops) do
        local blip = AddBlipForCoord(v)
        SetBlipSprite(blip, 75)
        SetBlipColour(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("ParaTattoos")
        EndTextCommandSetBlipName(blip)
    end
end)