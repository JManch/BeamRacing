#!/usr/local/bin/lua

--[[
local playerTracker = {
    {latestCheckpoint = 8, lastCheckpoint = 1, skippedCheckpoints = 0, lapsCompleted = 1},
    {latestCheckpoint = 1, lastCheckpoint = 2, skippedCheckpoints = 0, lapsCompleted = 2},
    {latestCheckpoint = 6, lastCheckpoint = 4, skippedCheckpoints = 0, lapsCompleted = 4},
    {latestCheckpoint = 4, lastCheckpoint = 4, skippedCheckpoints = 0, lapsCompleted = 4},
    {latestCheckpoint = 5, lastCheckpoint = 2, skippedCheckpoints = 0, lapsCompleted = 2}
}
]]--


local playerTracker = {}

local function populateTracker(client, latestCheckpoint, lastCheckpoint, skippedCheckpoints, lapsCompleted) 
    playerTracker[client] = {}
    playerTracker[client].latestCheckpoint = latestCheckpoint
    playerTracker[client].lastCheckpoint = lastCheckpoint
    playerTracker[client].skippedCheckpoints = skippedCheckpoints
    playerTracker[client].lapsCompleted = lapsCompleted
end

local function formatTime(seconds)
    local minutes = seconds // 60
    local seconds = seconds - minutes * 60

    if(minutes == 0) then
        return tostring(seconds) .. " seconds"
    elseif minutes == 1 then
        return tostring(minutes) .. " minute and " .. tostring(seconds) .. " seconds"
    else
        return tostring(minutes) .. " minutes and " .. tostring(seconds) .. " seconds"
    end
end

local function playerPosComp(p1, p2)

    -- First compare by laps else compare by latest checkpoint
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
        print("Iterating player tracker i is " .. i)
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

populateTracker(0, 1, 42, 0, 1)
populateTracker(1, 7, 7, 0, 0)
print(getClientRacePosition(0))
print(formatTime(421))