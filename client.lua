local canHide = true
local dumpsters = {
    "prop_dumpster_01a", 
    "prop_dumpster_02a", 
    "prop_dumpster_02b", 
    "prop_dumpster_4a", 
    "prop_dumpster_4b"
}
local inTrash = false

Citizen.CreateThread(function()
    while true do
        Wait(0)
        if inTrash then
            local dumpster = GetEntityAttachedTo(PlayerPedId())
            local dumpPos = GetEntityCoords(dumpster)
            if DoesEntityExist(dumpster) or not IsPedDeadOrDying(PlayerPedId()) or not IsPedFatallyInjured(PlayerPedId()) then
                SetEntityCollision(PlayerPedId(), false, false)
                DrawText3Ds(dumpPos.x, dumpPos.y, dumpPos.z + 1.1, 'Press [~g~E~w~] to get out')
                if not IsEntityPlayingAnim(PlayerPedId(), 'timetable@floyd@cryingonbed@base', 3) then
                    loadDict('timetable@floyd@cryingonbed@base')
                    TaskPlayAnim(PlayerPedId(), 'timetable@floyd@cryingonbed@base', 'base', 8.0, -8.0, -1, 1, 0, false, false, false)
                end
                if IsControlJustReleased(0, 38) and inTrash then
                    SetEntityCollision(PlayerPedId(), true, true)
                    inTrash = false
                    DetachEntity(PlayerPedId(), true, true)
                    SetEntityVisible(PlayerPedId(), true, false)
                    ClearPedTasks(PlayerPedId())
                    SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -0.7, -0.75))
                    Wait(250)
                end
            else
                SetEntityCollision(PlayerPedId(), true, true)
                DetachEntity(PlayerPedId(), true, true)
                SetEntityVisible(PlayerPedId(), true, false)
                ClearPedTasks(PlayerPedId())
                SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -0.7, -0.75))
            end
        end
    end
end)   

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if canHide then
            local ped = GetPlayerPed(-1)
            local pos = GetEntityCoords(ped)
            local dumpsterFound = false

            for i = 1, #dumpsters do
                local dumpster = GetClosestObjectOfType(pos.x, pos.y, pos.z, 1.0, dumpsters[i], false, false, false)
                local dumpPos = GetEntityCoords(dumpster)
                local dist = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, dumpPos.x, dumpPos.y, dumpPos.z, true)

                if dist < 1.8 then
                    if not inTrash then
                        DrawText3Ds(dumpPos.x, dumpPos.y, dumpPos.z + 1.1, 'Press [~g~E~w~] to hide inside')
                        if IsControlJustReleased(0, 38) and not inTrash then
                            if DoesEntityExist(ped) then
                                if not IsEntityAttached(ped) or GetDistanceBetweenCoords(GetEntityCoords(ped), GetEntityCoords(PlayerPedId()), true) >= 5.0 then
                                    AttachEntityToEntity(PlayerPedId(), dumpster, -1, 0.0, -0.3, 2.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)	
                                    loadDict('timetable@floyd@cryingonbed@base')
                                    TaskPlayAnim(PlayerPedId(), 'timetable@floyd@cryingonbed@base', 'base', 8.0, -8.0, -1, 1, 0, false, false, false)
                                    Wait(50)
                                    SetEntityVisible(PlayerPedId(), false, false)
                                    inTrash = true
                                else
                                    TriggerEvent('chat:addMessage', {
                                        color = { 255, 0, 0},
                                        multiline = true,
                                        args = {"SYSTEM", "Someone is already hiding in that dumpster!"}
                                      })
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

loadDict = function(dict)
    while not HasAnimDictLoaded(dict) do Wait(0) RequestAnimDict(dict) end
end

function DrawText3Ds(x, y, z, text)
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local factor = #text / 460
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	
	SetTextScale(0.3, 0.3)
	SetTextFont(6)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 160)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	DrawRect(_x,_y + 0.0115, 0.02 + factor, 0.027, 28, 28, 28, 95)
end

RegisterCommand("resetTrash", function(source, args, rawCommand)

    --SetEntityCollision(PlayerPedId(), true, true)

    inTrash = false
    DetachEntity(PlayerPedId(), true, true)
    SetEntityVisible(PlayerPedId(), true, false)
    ClearPedTasks(PlayerPedId())
    SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, -0.5, -0.75))

    print("Reset Trash")
end, false)