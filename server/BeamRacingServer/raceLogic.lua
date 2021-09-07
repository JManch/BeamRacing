local M = {}

local utils = require("/Resources/Server/BeamRacingServer/utils")
local trackData = require("/Resources/Server/BeamRacingServer/trackData")
local clientControl = require("/Resources/Server/BeamRacingServer/clientControl")

local playerTracker = {}
local lapCount = 0

-------------------Race Util---------------------

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
    
    for i, v in pairs(playerTracker) do
        table.insert(temp, {client = i, player = v})
    end

    table.sort(temp, playerPosComp)

    for i, v in ipairs(temp) do
        if v.client == client then
            return i
        end
    end

    return nil
end

local function resetPlayerTracker()
    print("Resetting tracker")
    for i, player in pairs(playerTracker) do
        for j, var in pairs(player) do
            print("Resetting player " .. i .. " variable " .. j)
            player.j = 0
        end
    end
end

local function freezePlayers(players)
    for playerID, playerName in pairs(players) do
		clientControl.setPlayerFreeze(playerID, 1)
	end
end

local function unFreezePlayers(players)
    for playerID, playerName in pairs(players) do
		clientControl.setPlayerFreeze(playerID, 0)
	end
end

local function gridLineup(players)
	for playerID, playerName in pairs(players) do
		clientControl.teleportPlayer(playerID, trackData.gridSlots[playerID + 1][1] .. " " .. trackData.gridSlots[playerID + 1][2])
	end
end

local function registerPlayer(client)
    playerTracker[client] = {latestCheckpoint = 0, lastCheckpoint = 0, skippedCheckpoints = 0, lapsCompleted = 0, lapStartTime = 0}
end

-------------------------------------------------


-------------------Race Events-------------------

local function onLapCompleted(client)

    -- Increment lap counter
    local lapsCompleted = playerTracker[client].lapsCompleted + 1
    playerTracker[client].lapsCompleted = lapsCompleted
    local racePosition = getClientRacePosition(client)

    SendChatMessage(client, "Completed lap: " .. playerTracker[client].lapsCompleted ..  "/" .. (lapCount or "Unkown") .. " Lap time: " .. utils.formatTime(os.clock() - playerTracker[client].lapStartTime))

    if(lapsCompleted == lapCount) then
        SendChatMessage(client, "This is your final lap!")
        if(racePosition == 1) then
            -- send massage to all other players saying leader is on final lap
            local name = GetPlayerName(client)
            local players = GetPlayers()
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

    --[[
    print("Table length is " .. tablelength(playerTracker))

    for i, v in pairs(playerTracker) do
        for j, v2 in pairs(v) do
            print("Player " .. i .. " key " .. j .. " is " .. v2)
        end
    end
    ]]--
    print("Client " .. client .. " passed checkpoint " .. data)
    
    -- Initialise the player array if it does not exists. Only needed for debugging when the mod is reloaded whilst the player is on the server.
    playerTracker[client] = playerTracker[client] or {latestCheckpoint = 0, lastCheckpoint = 0, skippedCheckpoints = 0, lapsCompleted = 0, lapStartTime = 0}

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
        if trackData.checkpointCount - latestCheckpoint > 0 then
            onCheckpointSkipped(client, trackData.checkpointCount - latestCheckpoint)
        end

        onLapCompleted(client)
    end 

    -- Set lap start time if passing through start line
    if latestCheckpoint == 1 then
        playerTracker[client].lapStartTime = os.clock()
    end

    -- Update last checkpoint
	playerTracker[client].lastCheckpoint = latestCheckpoint

    if(latestCheckpoint % 5 == 0) then
        SendChatMessage(client, "You are in position " .. getClientRacePosition(client) .. " on lap " .. playerTracker[client].lapsCompleted .. "/" .. lapCount)
    end

	print("Client " .. tostring(client) .. " latest checkpoint is " .. playerTracker[client].latestCheckpoint .. " last checkpoint is " .. playerTracker[client].lastCheckpoint .. " skipped checkpoints is " .. (playerTracker[client].skippedCheckpoints))
end

local function raceCountdown()
    SendChatMessage(-1, "Race countdown about to start!")
	Sleep(5000)
	SendChatMessage(-1, "3")
	Sleep(1000)
	SendChatMessage(-1, "2")
	Sleep(1000)
	SendChatMessage(-1, "1")
    Sleep(1000)
    SendChatMessage(-1, "Go!")
end

-------------------------------------------------


-------------------Race Control------------------

local function startRace(laps)
    local players = GetPlayers()
    lapCount = tonumber(laps)
    resetPlayerTracker()
    freezePlayers(players)
	gridLineup(players)
    SendChatMessage(-1, "Starting a " .. lapCount .. " lap race")
    raceCountdown()
    unFreezePlayers(players)
end

-------------------------------------------------

function onInit()
    RegisterEvent("onClientPassedCheckpoint", "OnClientPassedCheckpoint")
end

M.startRace = startRace
M.registerPlayer = registerPlayer

return M