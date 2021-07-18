-- ==============================
local jailTime = nil
local jailCell = nil
local jailCoords = nil

-- ==============================
RegisterNetEvent('Badger_Jailing:JailPlayer')
AddEventHandler('Badger_Jailing:JailPlayer', function(coords, time, cell)
    jailTime = time
    jailCoords = coords
    jailCell = cell

    TriggerEvent('chatMessage', Config.Prefix .. "You have been jailed for ^1" .. jailTime .. "^3 seconds.")

    -- NOTE: Teleporting gets handled by the function at the bottom of the file
end)

RegisterNetEvent('Badger_Jailing:UnjailPlayer')
AddEventHandler('Badger_Jailing:UnjailPlayer', function()
    jailTime = nil

    -- Teleport the player to the prison exit
    SetEntityCoords(PlayerPedId(), Config.PrisonExit.x, Config.PrisonExit.y, Config.PrisonExit.z)

    TriggerServerEvent('Badger_Jailing:FreeCell', jailCell)
    TriggerEvent('chatMessage', Config.Prefix .. "You have been released from jail!")

    jailCell = nil
    jailCoords = nil
end)

-- ==============================
Citizen.CreateThread(function()
    TriggerServerEvent("Badger_Jailing:Connected")
    while true do
        Citizen.Wait(1000)
        if jailTime ~= nil and jailCoords ~= nil then
            -- Update jail timer
            if jailTime > 0 then
                jailTime = jailTime - 1;
            end

            -- Check for time left
            if jailTime ~= 0 then
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)

                -- Only teleport back when the player is too far from original jail place
                local dist = Vdist2(playerCoords, jailCoords.x, jailCoords.y, jailCoords.z)
                if dist > Config.MaxDiffDistance then
                    SetEntityCoords(playerPed, jailCoords.x, jailCoords.y, jailCoords.z)
                end

                -- I know, messy but it works
                if jailTime == 1 then
                    TriggerEvent('chatMessage', Config.Prefix .. "You have ^11^3 second left in jail...")
                elseif jailTime < 6 then
                    TriggerEvent('chatMessage',
                        Config.Prefix .. "You have ^1" .. jailTime .. "^3 seconds left in jail...")
                elseif jailTime == 15 then
                    TriggerEvent('chatMessage', Config.Prefix .. "You have ^115^3 seconds left in jail...")
                elseif jailTime == 60 then
                    TriggerEvent('chatMessage', Config.Prefix .. "You have ^11^3 minute left in jail...")
                elseif jailTime == 120 then
                    TriggerEvent('chatMessage', Config.Prefix .. "You have ^12^3 minutes left in jail...")
                elseif jailTime == 180 then
                    TriggerEvent('chatMessage', Config.Prefix .. "You have ^13^3 minutes left in jail...")
                elseif jailTime == 300 then
                    TriggerEvent('chatMessage', Config.Prefix .. "You have ^15^3 minutes left in jail...")
                elseif jailTime == 600 then
                    TriggerEvent('chatMessage', Config.Prefix .. "You have ^110^3 minutes left in jail...")
                elseif jailTime == 900 then
                    TriggerEvent('chatMessage', Config.Prefix .. "You have ^115^3 minutes left in jail...")
                elseif jailTime == 1800 then
                    TriggerEvent('chatMessage', Config.Prefix .. "You have ^130^3 minutes left in jail...")
                elseif jailTime == 3600 then
                    TriggerEvent('chatMessage', Config.Prefix .. "You have ^11^3 hour left in jail...")
                elseif jailTime == 7200 then
                    TriggerEvent('chatMessage', Config.Prefix .. "You have ^12^3 hours left in jail...")
                end
            else
                TriggerEvent('Badger_Jailing:UnjailPlayer')
                jailTime = nil
            end
        end
    end
end)
