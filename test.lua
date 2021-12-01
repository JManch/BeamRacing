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
    playerTracker[client] = {latestCheckpoint = 0, lastCheckpoint = 0, skippedCheckpoints = 0, lapsCompleted = 0}
    --[[
    playerTracker[client] = {}
    playerTracker[client].latestCheckpoint = latestCheckpoint
    playerTracker[client].lastCheckpoint = lastCheckpoint
    playerTracker[client].skippedCheckpoints = skippedCheckpoints
    playerTracker[client].lapsCompleted = lapsCompleted
    --]]
end

function AccessTracker(client)
    if(playerTracker[client] == nil) then
        print("It is NILL")
    else
        print("It is not NILL")
        print(playerTracker[client].latestCheckpoint)
    end
end

populateTracker(0, 1, 42, 0, 1)
populateTracker(1, 7, 7, 0, 0)


print(AccessTracker(0))
print(AccessTracker(1))