local ESX = exports["es_extended"]:getSharedObject()
local closestPoints = {}
local playerPos

local function requestModel(model)
    local HasModelLoaded = HasModelLoaded
    if HasModelLoaded(model) then return end
    local RequestModel = RequestModel
    local tries = 0
    RequestModel(model)
    while not HasModelLoaded(model) and tries < 100 do
        tries += 1
        RequestModel(model)
        Wait(10)
    end

    return HasModelLoaded(model)
end

local function requestAnimDict(dict)
    local HasAnimDictLoaded = HasAnimDictLoaded
    if HasAnimDictLoaded(dict) then return end
    local RequestAnimDict = RequestAnimDict
    local tries = 0
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) and tries < 100 do
        tries += 1
        RequestAnimDict(dict)
        Wait(10)
    end

    return HasAnimDictLoaded(dict)
end

local function createPed(id, data)
    data.model = joaat(data.model)
    if not requestModel(data.model) then return end
    local ped = CreatePed(4, data.model, data.coords.x, data.coords.y, data.coords.z, data.coords.w or 0.0, false, false)
    SetModelAsNoLongerNeeded(data.model)
    while not DoesEntityExist(ped) do Wait(10) end
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityInvincible(ped, true)

    if data.weapon then
        GiveWeaponToPed(ped, joaat(data.weapon), math.random(20, 100), false, true)
    end

    if data.anim then
        if requestAnimDict(data.anim.dict) then
            TaskPlayAnim(ped, data.anim.dict, data.anim.clip, data.anim.blendInSpeed or 8.0, data.anim.blendOutSpeed or 8.0, data.anim.duration or -1, data.anim.flag or 0, data.anim.playbackRate or 0, false, false, false)
            RemoveAnimDict(data.anim.dict)
        end
    end

    closestPoints[id].entity = ped
end

local function removePed(id)
    if not closestPoints[id] then return end
    if not DoesEntityExist(closestPoints[id].entity) then return end
    DeletePed(closestPoints[id].entity)
    closestPoints[id].entity = nil
end

CreateThread(function ()
    while true do
        local playerPed = PlayerPedId()
        playerPos = GetEntityCoords(playerPed)
        for id, data in pairs(Shared.NPC) do
            local distance = #(playerPos - data.coords.xyz)
            if not closestPoints[id] and distance <= 100 then
                closestPoints[id] = data
                createPed(id, data)
            elseif closestPoints[id] and distance > 100 then
                removePed(id)
                closestPoints[id] = nil
            end
        end
        Wait(1000)
    end
end)

CreateThread(function ()
    while true do
        local wait = 1000
        if next(closestPoints) then
            wait = 0
            for _, data in pairs(closestPoints) do
                local distance = #(playerPos - data.coords.xyz)
                if distance <= 8 then
                    local scale = 1.2 - (distance / 8.0)
                    scale = math.max(0.0, math.min(1.2, scale))
                    ESX.Game.Utils.DrawText3D(vector3(data.coords.x, data.coords.y, data.coords.z + 2.10), "~w~" .. data.text, scale, 6)
                    if data.alt_txt and data.alt_txt ~= false then
                        ESX.Game.Utils.DrawText3D(vector3(data.coords.x, data.coords.y, data.coords.z + 1.95), "~w~" .. data.alt_txt, scale, 6)
                    end
                end
            end
        end

        Wait(wait)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if not next(closestPoints) then return end
    for _, data in pairs(closestPoints) do
        if data.entity and DoesEntityExist(data.entity) then
            DeleteEntity(data.entity)
        end
    end
end)
