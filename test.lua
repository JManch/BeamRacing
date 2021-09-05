#!/usr/local/bin/lua


local playerTracker = {
    {latestCheckpoint = 8, lastCheckpoint = 1, skippedCheckpoints = 0, lapsCompleted = 1},
    {latestCheckpoint = 1, lastCheckpoint = 2, skippedCheckpoints = 0, lapsCompleted = 2},
    {latestCheckpoint = 6, lastCheckpoint = 4, skippedCheckpoints = 0, lapsCompleted = 4},
    {latestCheckpoint = 4, lastCheckpoint = 4, skippedCheckpoints = 0, lapsCompleted = 4},
    {latestCheckpoint = 5, lastCheckpoint = 2, skippedCheckpoints = 0, lapsCompleted = 2}
}


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

print(getClientRacePosition(1))