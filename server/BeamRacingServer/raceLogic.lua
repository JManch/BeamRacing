local M = {}

local utils = require("/Resources/Server/BeamRacingServer/utils")
local trackData = require("/Resources/Server/BeamRacingServer/trackData")
local clientControl = require("/Resources/Server/BeamRacingServer/clientControl")

local function onInit()
    RegisterEvent("onClientPassedCheckpoint","OnClientPassedCheckpoint")
    RegisterEvent("OnTimerEnd", "OnRaceTimerEnd")
end

local playerTracker = {}
local lapCount = 0
local raceState = ""

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

-- when p2 is better return false 
local function playerLapComp(p1, p2)

    if p2.fastestLapTime < p1.fastestLapTime then
        return false
    else
        return true
    end
end

local function getClientQualiPosition(client)
    local temp = {}
    
    for i, v in pairs(playerTracker) do
        table.insert(temp, {client = i, player = v})
    end

    table.sort(temp, playerLapComp)

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
		clientControl.setClientFreeze(playerID, 1)
	end
end

local function unFreezePlayers(players)
    for playerID, playerName in pairs(players) do
		clientControl.setClientFreeze(playerID, 0)
	end
end

local function gridLineup(players)
	for playerID, playerName in pairs(players) do
		clientControl.teleportPlayer(playerID, trackData.gridSlots[playerID + 1][1] .. " " .. trackData.gridSlots[playerID + 1][2])
	end
end

local function pitLineup(players)
    for playerID, playerName in pairs(players) do
		clientControl.teleportPlayer(playerID, trackData.pitSlots[playerID + 1][1] .. " " .. trackData.gridSlots[playerID + 1][2])
	end
end

local function registerPlayer(client)
    print("Registering player " .. client)
    playerTracker[client] = {latestCheckpoint = 0, lastCheckpoint = 0, skippedCheckpoints = 0, lapsCompleted = 0, lapStartTime = 0, lastLapTime = 0, fastestLapTime = 0}
end

-- IMPROVE THIS
local function deregisterPlayer(client)
    playerTracker[client] = nil
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

local function qualiCountdown(duration)
    SendChatMessage(-1, "Qualifying about to start!")
    SendChatMessage(-1, "You will have " .. utils.formatTime(duration) .. " to set a fastest lap")
	Sleep(5000)
	SendChatMessage(-1, "3")
	Sleep(1000)
	SendChatMessage(-1, "2")
	Sleep(1000)
	SendChatMessage(-1, "1")
    Sleep(1000)
    SendChatMessage(-1, "Go!")
end

local function setLapUI(client, currentLap)
    TriggerClientEvent(client, "setLapUI", currentLap .. " " .. lapCount)
end

local function resetRaceUI(players) 
    for playerID, playerName in pairs(players) do
		setLapUI(playerID, 0)
	end
end

-------------------------------------------------


-------------------Race Control------------------

local function startRace(laps)
    local players = GetPlayers()
    lapCount = tonumber(laps)
    raceState = "racing"
    resetPlayerTracker()
    resetRaceUI(players)
    freezePlayers(players)
	gridLineup(players)
    SendChatMessage(-1, "Starting a " .. lapCount .. " lap race")
    raceCountdown()
    unFreezePlayers(players)
end


-- Quali duration is in seconds
local function startQualifying(duration)
    local players = GetPlayers()
    resetPlayerTracker()
    SendChatMessage(-1, "Starting qualifying with duration " .. utils.formatTime(duration))
    raceState = "qualifying"
    pitLineup(players)
    freezePlayers(players)
    qualiCountdown(duration)
    unFreezePlayers(players)
    utils.startTimer(duration, "quali")
end

local function endQualifying()
    local players = GetPlayers()
    SendChatMessage(-1, "Qualifying has ended")
    pitLineup(players)
    freezePlayers(players)
    -- Get fastest laps for each player
end

-------------------------------------------------

-------------------Race Events-------------------

local function onLapCompleted(client)

    print("Fastest lap value is " .. (playerTracker[client].fastestLapTime or "nil"))
    print("Last lap value is " .. (playerTracker[client].lastLapTime or "nil"))

    -- Need to check that the lap was actually a hotlap
    playerTracker[client].lastLapTime = os.clock() - playerTracker[client].lapStartTime
    if playerTracker[client].skippedCheckpoints == 0 then
        if(playerTracker[client].fastestLapTime == 0) then
            playerTracker[client].fastestLapTime = playerTracker[client].lastLapTime
        elseif playerTracker[client].lastLapTime < playerTracker[client].fastestLapTime then
            playerTracker[client].fastestLapTime = playerTracker[client].lastLapTime
        end
    end

    print("Race state is " .. (raceState or "nil"))
    
    if(raceState == "racing") then
        -- Increment lap counter
        local lapsCompleted = playerTracker[client].lapsCompleted + 1
        playerTracker[client].lapsCompleted = lapsCompleted
        local racePosition = getClientRacePosition(client)

        -- Update UI
        setLapUI(client, lapsCompleted)

        SendChatMessage(client, "Completed lap: " .. playerTracker[client].lapsCompleted ..  "/" .. (lapCount or "Unkown") .. " Lap time: " .. utils.formatTime(playerTracker[client].lastLapTime))

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

    elseif(raceState == "qualifying") then
        
        local qualiPosition = getClientQualiPosition(client)
        if(lastLapTime == fastestLapTime) then
            SendChatMessage(client, "You set a personal fastest lap with a " .. utils.formatTime(playerTracker[client].lastLapTime))
        else 
            SendChatMessage(client, "Your last lap was a " .. utils.formatTime(playerTracker[client].lastLapTime) .. " your fastest is a " .. utils.formatTime(playerTracker[client].fastestLapTime))
        end

        SendChatMessage("Your current qualifying position is P" .. qualiPosition .. ". Time remaining is: " .. utils.formatTime(utils.getTimeLeft()))
    end

    -- Reset skipped checkpoints to 0
    playerTracker[client].skippedCheckpoints = 0
end

local function onCheckpointSkipped(client, amountSkipped)
    -- Update total skippped
    playerTracker[client].skippedCheckpoints = playerTracker[client].skippedCheckpoints + amountSkipped
end



function OnClientPassedCheckpoint(client, data)

    print("Race state is " .. raceState)
    print("Client " .. client .. " passed checkpoint " .. data)
    
    -- Initialise the player array if it does not exists. Only needed for debugging when the mod is reloaded whilst the player is on the server.
    --playerTracker[client] = playerTracker[client] or {latestCheckpoint = 0, lastCheckpoint = 0, skippedCheckpoints = 0, lapsCompleted = 0, lapStartTime = 0, lastLapTime = 0, fastestLapTime = 0}

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

function OnRaceTimerEnd(timerType)
    if(timerType == "quali") then
        endQualifying()
    end
end

-------------------------------------------------

M.onInit = onInit
M.startRace = startRace
M.startQualifying = startQualifying
M.registerPlayer = registerPlayer
M.deregisterPlayer = deregisterPlayer
M.raceState = raceState

return M