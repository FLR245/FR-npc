ESX = exports["es_extended"]:getSharedObject()

Draw = function()
    for i,v in pairs(Shared.NPC) do
        Model(v.model)
    
        RequestAnimDict("mini@strip_club@idles@bouncer@base")
        while not HasAnimDictLoaded("mini@strip_club@idles@bouncer@base") do
          Wait(1)
        end
        local ped = CreatePed(4, v.model, v.coords.x, v.coords.y, v.coords.z, v.coords.w, false, false)
    
        FreezeEntityPosition(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetEntityInvincible(ped, true)
        if v.weapon == false then
            else
            GiveWeaponToPed(ped, GetHashKey(v.weapon), math.random(20, 100), true, true)
      end
    end

    while true do
        local pos = GetEntityCoords(GetPlayerPed(-1), true)
        Wait(0)
        for _,v in pairs(Shared.NPC) do
            local x = v.coords.x
            local y = v.coords.y
            local z = v.coords.z
            local distance = Vdist(pos.x, pos.y, pos.z, x, y, z)
            local scale = 1.2 - (distance / 8.0)
            scale = math.max(0.0, math.min(1.2, scale))
            if distance < 8.0 then
                ESX.Game.Utils.DrawText3D(vector3(x, y, z + 2.10), "~w~" .. v.text, scale, 6)
                if v.alt_txt and v.alt_txt ~= false then
                    ESX.Game.Utils.DrawText3D(vector3(x, y, z + 1.95), "~w~" .. v.alt_txt, scale, 6)
                end
            end
        end
    end
end

CreateThread(Draw)


Model = function(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Wait(100)
    end
end
