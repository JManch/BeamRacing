local M = {}

--local json = require "json"

local gridSlots = {{"-305.713 727.595 321.181", "0 0 0.959394 0.28207"}, {"-307.662 716.872 321.086", "0 0 0.959394 0.28207"}, {"-297.280 714.036 320.927", "0 0 0.959394 0.28207"}}
local checkpointCount = 42
local lapCount

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

local function playerPosComp(p1, p2)
    -- First compare by laps else compare by latest checkpoint
    -- Can potentially add some weighting based on checkpoints skipped here
    if(p1.player.lapsCompleted < p2.player.lapsCompleted) then
        return false
    elseif(p1.player.lapsCompleted > p2.player.lapsCompleted) then
        return true
    else
        if(p1.player.latestCheckpoint < p2.player.latestCheckpoint) then
            return false
        else
            return true
        end
    end

    return nil
end

local function getClientRacePosition(client)
    local temp = {}
    
    for i, v in ipairs(playerTracker) do
        table.insert(temp, {client = i - 1, player = v})
    end

    table.sort(temp, playerPosComp)

    for i, v in ipairs(temp) do
        if v.client == client then
            return i
        end
    end

    return nil
end

local function onLapCompleted(client)

    -- Increment lap counter
    local lapsCompleted = playerTracker[client].lapsCompleted + 1
    playerTracker[client].lapsCompleted = lapsCompleted
    local racePosition = getClientRacePosition(client)

    SendChatMessage(client, "Lap: " .. playerTracker[client].lapsCompleted ..  " Position: " .. (getClientRacePosition(client) or "Unknown"))

    if(lapsCompleted == lapCount) then
        SendChatMessage(client, "This is your final lap!")

        if(racePosition == 1) then
            -- send massage to all other players saying leader is on final lap
            local name = GetPlayerName(client)
            print("Player " .. name .. " is on their final lap!")
            for playerID, playerName in pairs(players) do
                
                SendChatMessage(playerID, "Player " .. name .. " is on their final lap!")
            end
        end
    end

    if(lapsCompleted == lapCount + 1) then
        SendChatMessage("You finished the race in position " .. racePosition)
    end

    print("Client " .. client .. " completed a lap! They have completed " .. playerTracker[client].lapsCompleted .. " laps.")
end

local function onCheckpointSkipped(client, amountSkipped)
    -- Update total skippped
    playerTracker[client].skippedCheckpoints = playerTracker[client].skippedCheckpoints + amountSkipped
end

function OnClientPassedCheckpoint(client, data)
	
    print("Client " .. tostring(client) .. " passed checkpoint " .. data)
    
    -- Initialise the player array if it does not exists. Only needed for debugging when the
    -- mod is reloaded whilst the player is on the server.
    playerTracker[client] = playerTracker[client] or {latestCheckpoint = 0, lastCheckpoint = 0, skippedCheckpoints = 0, lapsCompleted = 0, racing = false}

    if(playerTracker[client].racing == false) then
        return
    end

    local latestCheckpoint = tonumber(data:sub(12))
    local lastCheckpoint = playerTracker[client].lastCheckpoint
    
    -- Only update latest checkpoint if it is greater than last or if it is checkpoint 1
    if(latestCheckpoint ~= 1 and latestCheckpoint <= lastCheckpoint) then
        print("Client " .. client .. " went backwards")
        return
    end

	playerTracker[client].latestCheckpoint = latestCheckpoint

    -- Check for checkpoint skips
    local checkpointDiff = latestCheckpoint - lastCheckpoint - 1
	if checkpointDiff > 0 then -- if they skipped a checkpoint
        onCheckpointSkipped(client, checkpointDiff)
    end
		
    -- Check for lap completed
	if latestCheckpoint == 1 and lastCheckpoint ~= 0 then
        -- Check for skipped laps by last checkpoint to total checkpoints
        if checkpointCount - latestCheckpoint > 0 then
            onCheckpointSkipped(client, checkpointCount - latestCheckpoint)
        end

        onLapCompleted(client)
    end 

    -- Update last checkpoint
	playerTracker[client].lastCheckpoint = latestCheckpoint

	print("Client " .. tostring(client) .. " latest checkpoint is " .. playerTracker[client].latestCheckpoint .. " last checkpoint is " .. playerTracker[client].lastCheckpoint .. " skipped checkpoints is " .. (playerTracker[client].skippedCheckpoints))
end


local function teleportPlayer(playerID, posandrot)
	local coords = SplitSpaces(posandrot)
	-- Check that coords has 6 elements
	print("coords is " .. coords[1] .. " " .. coords[2] .. " " .. coords[3] .. " " .. coords[4] .. " " .. coords[5] .. " " .. coords[6] .. " " .. coords[7])
	TriggerClientEvent(playerID, "teleportPlayer", coords[1] .. " " .. coords[2] .. " " .. coords[3] .. " " .. coords[4] .. " " .. coords[5] .. " " .. coords[6] .. " " .. coords[7])
end

local function resetPlayerTracker()
    for i, player in ipairs(playerTracker) do
        for j, var in ipairs(player) do
            player[j] = 0
        end
    end
end

local function gridLineup()
	print("Performing grid lineup")
	local players = GetPlayers()
	for playerID, playerName in pairs(players) do
		print("Teleporting player id " .. playerID)
		teleportPlayer(playerID, gridSlots[playerID + 1][1] .. " " .. gridSlots[playerID + 1][2])
	end

    for i, player in ipairs(playerTracker) do
        player.racing = true
    end
end

local function startRace(laps)
    lapCount = tonumber(laps)
    -- Need to fix all cars here before teleporting them
    resetPlayerTracker()
	gridLineup()

	SendChatMessage(-1, "Race countdown about to start!")
	--Sleep(3000)
	SendChatMessage(-1, "3")
	--Sleep(3000)
	SendChatMessage(-1, "2")
	--Sleep(3000)
	SendChatMessage(-1, "1")
end

function OnPlayerJoin(playerID)
	print("Player just joined with ID " .. playerID)
    SendChatMessage(-1, "Someone just joined!")
	playerTracker[playerID] = {latestCheckpoint = 0, lastCheckpoint = 0, skippedCheckpoints = 0, lapsCompleted = 0, racing = false}
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
			startRace(argument)
		elseif command == "teleport" then
			teleportPlayer(playerID, argument)
		elseif command == "test" then
			TriggerClientEvent(-1, "testEvent", "yo")
		end
	end
end

return M