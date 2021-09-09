local M = {}

local timerEnd
local timerType

local function OnTimerEnd(timerType)
    StopThread("TimerRun")
    TriggerGlobalEvent("OnTimerEnd", timerType)
end

function TimerRun()
    --print("Timer running. Current time: " .. tostring(os.clock()) .. " End: " .. tostring(timerEnd))
    if(os.clock() > timerEnd) then
        OnTimerEnd(timerType)
    end
end

-- Only 1 timer can run at a time
local function startTimer(time, type)
    timerEnd = os.clock() + time
    timerType = type
    CreateThread("TimerRun", 1)
end

local function formatTime(seconds)
    local minutes = math.floor((seconds // 60) + 0.5)
    local seconds = math.floor((seconds - minutes * 60) + 0.5)

    if(minutes == 0) then
        return tostring(seconds) .. " seconds"
    elseif minutes == 1 then
        return tostring(minutes) .. " minute and " .. tostring(seconds) .. " seconds"
    else
        return tostring(minutes) .. " minutes and " .. tostring(seconds) .. " seconds"
    end
end

local function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

local function splitSpaces(s)
    local result = {};
    for word in (s.." "):gmatch("(.-)".." ") do
        table.insert(result, word);
    end
    return result;
end

M.formatTime = formatTime
M.tablelength = tablelength
M.SplitSpaces = splitSpaces
M.startTimer = startTimer

return M