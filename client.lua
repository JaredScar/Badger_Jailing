jailTime = nil;
cords = nil;
jailCell = nil;
teleported = false;
RegisterNetEvent('Badger_Jailing:JailPlayer')
AddEventHandler('Badger_Jailing:JailPlayer', function(jailCoords, time, cell)
	local ped = GetPlayerPed(-1);
	jailTime = time;
	cords = jailCoords;
	jailCell = cell;
	SetEntityCoords(ped, jailCoords.x, jailCoords.y, jailCoords.z, 1, 0, 0, 1);
end)

RegisterNetEvent('Badger_Jailing:UnjailPlayer')
AddEventHandler('Badger_Jailing:UnjailPlayer', function()
	jailTime = nil;
	local coords = Config.PrisonExit;
	local ped = GetPlayerPed(-1);
	SetEntityCoords(ped, coords.x, coords.y, coords.z, 1, 0, 0, 1)
	TriggerEvent('chatMessage', Config.Prefix .. "You have been released from jail!...");
	TriggerServerEvent('Badger_Jailing:FreeCell', jailCell);
	jailCell = nil;
	cords = nil;
end)

Citizen.CreateThread(function()
	TriggerServerEvent("Badger_Jailing:Connected");
	while true do 
		Citizen.Wait(1000);
		local ped = GetPlayerPed(-1)
		if jailTime ~= nil then 
			if jailTime > 0 then 
				jailTime = jailTime - 1;
			end
			if mod(jailTime, Config.Teleport_And_Notify_Every) == 0 and jailTime ~= 0 then 
				TriggerEvent('chatMessage', Config.Prefix .. "You have ^1" .. jailTime .. "^3 seconds left in jail...");
				if (Config.Teleport_Enabled) then 
					SetEntityCoords(ped, cords.x, cords.y, cords.z, 1, 0, 0, 1)
				end
			end
			if jailTime == 0 then 
				TriggerEvent('Badger_Jailing:UnjailPlayer');
				jailTime = nil;
			end
		end
	end
end)
function mod(a, b)
    return a - (math.floor(a/b)*b)
end
function Draw2DText(x, y, text, scale, center)
    -- Draw text on screen
    SetTextFont(4)
    SetTextProportional(7)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    if center then 
    	SetTextJustification(0)
    end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end