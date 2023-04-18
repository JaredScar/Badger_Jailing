function SaveFile(data)
	SaveResourceFile(GetCurrentResourceName(), "players.json", json.encode(data, { indent = true }), -1)
end
function LoadFile()
	local al = LoadResourceFile(GetCurrentResourceName(), "players.json")
    local cfg = json.decode(al)
    return cfg;
end
function ExtractIdentifiers(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }

    --Loop over all identifiers
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        --Convert it to a nice table.
        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end

    return identifiers
end
JailTracker = {};
RegisterCommand('jail', function(src, args, raw)
	-- /jail <id> <time> 
	if IsPlayerAceAllowed(src, "Badger_Jailing.Jail") then 
		if #args < 2 then 
			-- Not enough args 
			TriggerClientEvent('chatMessage', src, Config.Prefix .. "^1ERROR: Invalid usage. ^2Usage: /jail <id> <time>");
			return;
		end
		if GetPlayerIdentifiers(args[1])[1] ~= nil then 
			-- Valid player 
			if tonumber(args[2]) ~= nil then 
				-- Valid number supplied 
				if (tonumber(args[2]) <= Config.Max_Jail_Time_Allowed) then 
					TriggerClientEvent('chatMessage', -1, Config.Prefix .. "Player ^5" .. GetPlayerName(args[1]) .. " ^3has been jailed for ^1" ..
						args[2] .. " ^3seconds...");
					Citizen.CreateThread(function()
						local cfg = LoadFile();
						local ids = ExtractIdentifiers(args[1]);
						cfg[ids.license] = {Cell = nil, Time = tonumber(args[2])};
						SaveFile(cfg); 
						while not IsCellFree() do
							TriggerClientEvent('chatMessage', args[1], Config.Prefix .. "Waiting on a free cell at jail..."); 
							Citizen.Wait(10000);
						end
						local key = GetFreeCell();
						local coords = Config.Cells[key];
						CellTracker[key] = ids.license;
						local cfg = LoadFile();
						cfg[ids.license] = {Cell = key, Time = tonumber(args[2])};
						JailTracker[tonumber(args[1])] = tonumber(args[2]);
						SaveFile(cfg); 
						TriggerClientEvent('Badger_Jailing:JailPlayer', tonumber(args[1]), coords, tonumber(args[2]), key);
					end)
				else 
					-- Too long of a jail time allowed
					TriggerClientEvent('chatMessage', src, Config.Prefix .. "^1ERROR: You cannot jail for longer than ^3" .. Config.Max_Jail_Time_Allowed .. " ^1seconds...");
				end
			else 
				-- Invalid number supplied 
				TriggerClientEvent('chatMessage', src, Config.Prefix .. "^1ERROR: The 2nd argument was not a proper number...");
			end
		else 
			-- Invalid player 
			TriggerClientEvent('chatMessage', src, Config.Prefix .. "^1ERROR: Invalid player supplied...");
		end
	end
end)

RegisterCommand('free', function(src, args, raw)
	-- /unjail <id> 
	if IsPlayerAceAllowed(src, "Badger_Jailing.Unjail") then 
		if #args ~= 1 then 
			-- Not enough args 
			TriggerClientEvent('chatMessage', src, Config.Prefix .. "^1ERROR: Invalid usage. ^2Usage: /free <id>");
			return;
		end
		if GetPlayerIdentifiers(args[1])[1] ~= nil then 
			-- Valid player 
			TriggerClientEvent('chatMessage', -1, Config.Prefix .. "Player ^5" .. GetPlayerName(args[1]) .. " ^3has been released from jail by ^2" 
				.. GetPlayerName(src));

			TriggerClientEvent('Badger_Jailing:UnjailPlayer', args[1]);
			local ids = ExtractIdentifiers(args[1]);
			local cfg = LoadFile();
			cfg[ids.license] = nil;
			JailTracker[tonumber(args[1])] = nil;
			SaveFile(cfg); 
		else 
			-- Not valid player 
			TriggerClientEvent('chatMessage', src, Config.Prefix .. "^1ERROR: Invalid player supplied...");
		end
	end
end)
Citizen.CreateThread(function()
	while true do 
		Citizen.Wait(1000);
		for k, v in pairs(JailTracker) do 
			if JailTracker[k] ~= nil and JailTracker[k] > 0 then 
				JailTracker[k] = JailTracker[k] - 1;
			end
			if JailTracker[k] ~= nil and JailTracker[k] == 0 then 
				JailTracker[k] = nil;
			end
		end
	end
end)
RegisterNetEvent("Badger_Jailing:Connected")
AddEventHandler("Badger_Jailing:Connected", function()
	local src = source;
	local ids = ExtractIdentifiers(src);
	local cfg = LoadFile();
	if cfg[ids.license] ~= nil then 
		local time = cfg[ids.license].Time
		local cell = cfg[ids.license].Cell;
		if CellTracker[cell] == nil then 
			-- Jail them in this cell 
			CellTracker[cell] = ids.license;
			local coords = Config.Cells[cell];
			TriggerClientEvent('Badger_Jailing:JailPlayer', tonumber(src), coords, time, cell);
		else 
			-- Jail them in another cell 
			Citizen.CreateThread(function()
				while not IsCellFree() do
					TriggerClientEvent('chatMessage', src, Config.Prefix .. "Waiting on a free cell at jail..."); 
					Citizen.Wait(10000);
				end
				local key = GetFreeCell();
				local coords = Config.Cells[key];
				local ids = ExtractIdentifiers(src);
				CellTracker[key] = ids.license;
				local cfg = LoadFile();
				cfg[ids.license] = {Cell = key, Time = tonumber(time)};
				JailTracker[src] = tonumber(time);
				SaveFile(cfg); 
				TriggerClientEvent('Badger_Jailing:JailPlayer', tonumber(src), coords, tonumber(time), key);
			end)
		end
	end
end)
AddEventHandler("playerDropped", function()
	local src = source;
	local ids = ExtractIdentifiers(src);
	local cfg = LoadFile();
	if cfg[ids.license] ~= nil then 
		cfg[ids.license].Time = JailTracker[src];
	end
	SaveFile(cfg);
	JailTracker[src] = nil;
	SaveFile(cfg);
	for key, license in pairs(CellTracker) do 
		if license == ids.license then 
			CellTracker[key] = nil;
		end
	end
end)

CellTracker = {}

RegisterNetEvent('Badger_Jailing:FreeCell')
AddEventHandler('Badger_Jailing:FreeCell', function(cell)
	local ids = ExtractIdentifiers(source);
	local cfg = LoadFile();
	cfg[ids.license] = nil;
	JailTracker[source] = nil;
	SaveFile(cfg); 
	CellTracker[cell] = nil;
end)

function GetFreeCell()
	for k, v in pairs(Config.Cells) do
		if CellTracker[k] == nil then 
			return k;
		end
	end
	return nil;
end

function IsCellFree()
	for k, v in pairs(Config.Cells) do
		if CellTracker[k] == nil then 
			return true;
		end
	end
	return false;
end