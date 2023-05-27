if Config.Global.Framework == "esx" then
    ESX = nil
    Citizen.CreateThread(function()
        while ESX == nil do
            TriggerEvent(Config.Global.SharedObject, function(obj) ESX = obj end)
            Citizen.Wait(100)
        end
        ESX.PlayerData = ESX.GetPlayerData()
    end)
elseif Config.Global.Framework == "newEsx" then 
    ESX = exports["es_extended"]:getSharedObject()
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
	ESX.PlayerData.job = job  
end)

RegisterNetEvent('esx:setJob2')
AddEventHandler('esx:setJob2', function(job2)  
	ESX.PlayerData.job2 = job2 
end)

local rotateSpeed, moveSpeed  = 0.5, 0.01
local object = {}

function MoveEntity(entity, direction, speed)
    local coords = GetEntityCoords(entity)
    local newCoords = coords + direction * speed
    SetEntityCoords(entity, newCoords)
end

function SpawnObj(obj)
    local playerPed = PlayerPedId()
    local coords, forward = GetEntityCoords(playerPed), GetEntityForwardVector(playerPed)
    local objectCoords = (coords + forward * 1.0)
    local Ent = nil
    Ent = SpawnObject(obj, objectCoords)
    SetEntityHeading(Ent, GetEntityHeading(playerPed))
    PlaceObjectOnGroundProperly(Ent)
    SetEntityAlpha(Ent, 170, 170)
    SetEntityCollision(Ent, false, true)
    local placed = false
    while not placed do
        Citizen.Wait(0)
        ESX.ShowHelpNotification("~INPUT_VEH_FLY_PITCH_UP_ONLY~ / ~INPUT_VEH_FLY_PITCH_DOWN_ONLY~ - Avancer/Reculer\n~INPUT_VEH_FLY_ROLL_LEFT_ONLY~ - Rotation Gauche\n~INPUT_VEH_FLY_ROLL_RIGHT_ONLY~ - Rotation Droite\n~INPUT_CELLPHONE_DOWN~ - Descendre\n~INPUT_CELLPHONE_UP~ - Monter\n~INPUT_CONTEXT~ - Placer")
        if IsControlPressed(0, 108) then SetEntityHeading(Ent, GetEntityHeading(Ent) + rotateSpeed) end
        if IsControlPressed(0, 107) then SetEntityHeading(Ent, GetEntityHeading(Ent) - rotateSpeed) end
        local direction = GetEntityForwardVector(Ent)
        if IsControlPressed(0, 111) then MoveEntity(Ent, direction, moveSpeed) end
        if IsControlPressed(0, 110) then MoveEntity(Ent, -direction, moveSpeed) end
        local up = vector3(0.0, 0.0, 1.0)
        if IsControlPressed(0, 172) then MoveEntity(Ent, up, moveSpeed) end
        if IsControlPressed(0, 173) then MoveEntity(Ent, -up, moveSpeed) end
        if IsControlJustReleased(1, 38) then placed = true end
    end
    FreezeEntityPosition(Ent, true)
    SetEntityCollision(Ent, true, true)
    SetEntityInvincible(Ent, true)
    ResetEntityAlpha(Ent)
    local NetId = NetworkGetNetworkIdFromEntity(Ent)
    table.insert(object, NetId)
end

function SpawnObject(model, coords)
    local model = GetHashKey(model)
    RequestModels(model)
    local obj = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
    return obj
end

function RequestModels(modelHash)
    if not HasModelLoaded(modelHash) and IsModelInCdimage(modelHash) then
        RequestModel(modelHash)
        while not HasModelLoaded(modelHash) do
            Citizen.Wait(1)
        end
    end
end

function RemoveObj(id, k)
    Citizen.CreateThread(function()
        SetNetworkIdCanMigrate(id, true)
        local entity = NetworkGetEntityFromNetworkId(id)
        NetworkRequestControlOfEntity(entity)
        local test = 0
        while test > 100 and not NetworkHasControlOfEntity(entity) do
            NetworkRequestControlOfEntity(entity)
            Wait(1)
            test = test + 1
        end
        SetEntityAsNoLongerNeeded(entity)

        local test = 0
        while test < 100 and DoesEntityExist(entity) do 
            SetEntityAsNoLongerNeeded(entity)
            TriggerServerEvent("DeleteEntity", NetworkGetNetworkIdFromEntity(entity))
            DeleteEntity(entity)
            DeleteObject(entity)
            if not DoesEntityExist(entity) then 
                table.remove(object, k)
            end
            SetEntityCoords(entity, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0)
            Wait(1)
            test = test + 1
        end
    end)
end

function GoodName(hash)
    for _,v in pairs (Config.Props) do
        if hash == GetHashKey(v.Model) then
            return v.Label
        else
            return hash
        end
    end
end

PropsPose = 0

function MenuProps()
    local selectedCategory = nil 
    local MenuProps = RageUI.CreateMenu("Props", Config.Global.TextColor.."Liste des props")
    local PropsSup = RageUI.CreateSubMenu(MenuProps, "Suppression", Config.Global.TextColor.."Suppression des props")
    local PropsList = RageUI.CreateSubMenu(MenuProps, "Props", Config.Global.TextColor.."Liste des props")
    MenuProps:SetRectangleBanner(Config.Global.ColorMenuR, Config.Global.ColorMenuG, Config.Global.ColorMenuB, Config.Global.ColorMenuA)
    PropsSup:SetRectangleBanner(Config.Global.ColorMenuR, Config.Global.ColorMenuG, Config.Global.ColorMenuB, Config.Global.ColorMenuA)
    PropsList:SetRectangleBanner(Config.Global.ColorMenuR, Config.Global.ColorMenuG, Config.Global.ColorMenuB, Config.Global.ColorMenuA)

    RageUI.Visible(MenuProps, not RageUI.Visible(MenuProps))
    while MenuProps do
        Citizen.Wait(0)

            RageUI.IsVisible(MenuProps, true, true, true, function()

                local coords  = GetEntityCoords(PlayerPedId())

                RageUI.Separator(Config.Global.TextColor.."Props posé : ~s~"..PropsPose..""..Config.Global.TextColor.."/~s~"..Config.Global.PropsMax)

                RageUI.ButtonWithStyle(Config.Global.TextColor.."→~s~ Liste de mes props", nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                end, PropsSup)

                RageUI.Separator("↓ "..Config.Global.TextColor.."Props~s~ ↓")

                for _, category in pairs(Config.Props) do
                    if (not category.job or (ESX.PlayerData.job and ESX.PlayerData.job.name == category.job)) and
                    (not category.job2 or (ESX.PlayerData.job2 and ESX.PlayerData.job2.name == category.job2)) then              
                        RageUI.ButtonWithStyle(Config.Global.TextColor.."→~s~ "..category.name, nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                            if Selected then
                                selectedCategory = category
                            end
                        end, PropsList)
                    end
                end

            end, function() 
            end)

            RageUI.IsVisible(PropsList, true, true, true, function()

                    if selectedCategory then
                        for _, prop in ipairs(selectedCategory.Props) do
                            RageUI.ButtonWithStyle(Config.Global.TextColor.."→~s~ "..prop.Label, nil, {RightLabel = ""}, true, function(Hovered, Active, Selected)
                                if Selected then
                                    if PropsPose == Config.Global.PropsMax then
                                        ESX.ShowNotification("~r~Vous avez fait spawn le maximum de props possible")
                                        return
                                    end
                                    SpawnObj(prop.Model)
                                    local pid = PlayerPedId()
                                    RequestAnimDict("pickup_object")
                                    while (not HasAnimDictLoaded("pickup_object")) do Citizen.Wait(0) end
                                    TaskPlayAnim(pid,"pickup_object","pickup_low",1.0,-1.0, -1, 2, 1, true, true, true)
                                    FreezeEntityPosition(PlayerPedId(), true)
                                    Wait(1500)
                                    ClearPedTasks(PlayerPedId())
                                    FreezeEntityPosition(PlayerPedId(), false)
                                    PropsPose = PropsPose + 1
                                    ESX.ShowNotification("~r~Vous pouvez encore faire spawn ~g~x"..(Config.Global.PropsMax - PropsPose).." ~r~Props")
                                    RageUI.GoBack()
                                end
                            end)
                        end
                    end

            end, function() 
            end)

            RageUI.IsVisible(PropsSup, true, true, true, function()

                local newObject = {}
                for k,v in pairs(object) do
                    local propName = GoodName(GetEntityModel(NetworkGetEntityFromNetworkId(v)))
                    if propName ~= 0 then 
                        RageUI.ButtonWithStyle("[Props] = "..propName, nil, {RightLabel = "→ ~r~Supprimer"}, true, function(Hovered, Active, Selected)
                            if Active then
                                local entity = NetworkGetEntityFromNetworkId(v)
                                local ObjCoords = GetEntityCoords(entity)
                                DrawMarker(0, ObjCoords.x, ObjCoords.y, ObjCoords.z+1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.3, 0.3, Config.Global.ColorMenuR, Config.Global.ColorMenuG, Config.Global.ColorMenuB, 170, 1, 0, 2, 1, nil, nil, 0)
                            end
                            if Selected then
                                RemoveObj(v)
                                PropsPose = PropsPose - 1
                                RageUI.GoBack()
                            else
                                table.insert(newObject, v)
                            end
                        end)
                    end
                end
                object = newObject
            
            end, function()
            end)

        if not 
        RageUI.Visible(MenuProps) and not 
        RageUI.Visible(PropsSup) and not  
        RageUI.Visible(PropsList) 
        then
            MenuProps = RMenu:DeleteType(MenuProps, true)
        end
    end
end

RegisterCommand("props", function()
    MenuProps()
end, false)

exports("PropsMenu", function()
    MenuProps()
end)
