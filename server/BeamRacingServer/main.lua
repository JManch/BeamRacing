local M = {}

--local json = require "json"

local gridSlots = {{"-305.713 727.595 321.181", "0 0 0.959394 0.28207"}, {"-307.662 716.872 321.086", "0 0 0.959394 0.28207"}, {"-297.280 714.036 320.927", "0 0 0.959394 0.28207"}}

--{ {"lastest checkpoint", "last checkpoint", "skipped checkpoints", "laps completed"} }
local playerTracker = {}

function onInit()
	print("========== LOADED BEAM RACING =========")
	RegisterEvent("onChatMessage", "OnChatMessage")
	RegisterEvent("onPlayerJoin", "OnPlayerJoin")
	RegisterEvent("onClientPassedCheckpoint", "OnClientPassedCheckpoint")
end

-- Utilities --

local function SplitSpaces(s)
    local result = {};
    for word in (s.." "):gmatch("(.-)".." ") do
        table.insert(result, word);
    end
    return result;
end

---------------

function OnClientPassedCheckpoint(client, data)
	print("Client " .. tostring(client) .. " passed checkpoint " .. data)

	playerTracker[client][1] = data:sub(12)
	if(playerTracker[client][2] ~= nil) then
		if playerTracker[client][1] - playerTracker[client][2] > 1 then -- if they skipped a checkpoint
			if(playerTracker[client][3] == nil) then
				playerTracker[client][3] = 0
			end
			playerTracker[client][3] = playerTracker[client][3] + (playerTracker[client][1] - playerTracker[client][2] - 1)
		end
	end

	playerTracker[client][2] = playerTracker[client][1]

	print("Client " .. tostring(client) .. " latest checkpoint is " .. playerTracker[client][1] .. " last checkpoint is " .. playerTracker[client][2] .. " skipped checkpoints is " .. (playerTracker[client][3] or "nil"))
end

local function teleportPlayer(playerID, posandrot)
	local coords = SplitSpaces(posandrot)
	-- Check that coords has 6 elements
	print("coords is " .. coords[1] .. " " .. coords[2] .. " " .. coords[3] .. " " .. coords[4] .. " " .. coords[5] .. " " .. coords[6] .. " " .. coords[7])
	TriggerClientEvent(playerID, "teleportPlayer", coords[1] .. " " .. coords[2] .. " " .. coords[3] .. " " .. coords[4] .. " " .. coords[5] .. " " .. coords[6] .. " " .. coords[7])
end

local function gridLineup()
	print("Performing grid lineup")
	local players = GetPlayers()
	for playerID, playerName in pairs(players) do
		print("Found player id " .. playerID)
		teleportPlayer(playerID, gridSlots[playerID + 1][1] .. " " .. gridSlots[playerID + 1][2])
	end
end

local function startRace()
	gridLineup()
	SendChatMessage(-1, "Race countdown about to start!")
	Sleep(1000)
	SendChatMessage(-1, "3")
	Sleep(1000)
	SendChatMessage(-1, "2")
	Sleep(1000)
	SendChatMessage(-1, "1")
end

function OnPlayerJoin(playerID)
	print("Player just joined with ID " .. playerID)
    SendChatMessage(-1, "Someone just joined!")
	playerTracker[playerID] = {}
end

function OnChatMessage(playerID, senderName, message)
	message = message:sub(2)
	if(message:sub(1, 1) == "/") then
		local spacePos = message:find(" ")
		local command, argument
		if spacePos ~= nil then
			command = message:sub(2, spacePos - 1)
			argument = message:sub(spacePos + 1)
		else
			command = message:sub(2)
			argument = ""
		end
		print("Command is:" .. command)
		if command == "start" then
			startRace()
		elseif command == "teleport" then
			teleportPlayer(playerID, argument)
		elseif command == "test" then
			TriggerClientEvent(-1, "testEvent", "yo")
		end
	end
end

return M