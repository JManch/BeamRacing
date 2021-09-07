local M = {}

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

return M