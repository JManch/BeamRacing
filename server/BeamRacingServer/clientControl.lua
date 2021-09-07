local M = {}

local utils = require("/Resources/Server/BeamRacingServer/utils")

local function teleportPlayer(playerID, posandrot)
	local coords = utils.SplitSpaces(posandrot)
	
	if(utils.tableLength(coords) ~= 6) then
        return
    end
    
	TriggerClientEvent(playerID, "teleportPlayer", coords[1] .. " " .. coords[2] .. " " .. coords[3] .. " " .. coords[4] .. " " .. coords[5] .. " " .. coords[6] .. " " .. coords[7])
end

local function setPlayerFreeze(playerID, freeze)
    TriggerClientEvent(playerID, "setPlayerFreeze", freeze)
end

M.teleportPlayer = teleportPlayer
M.setPlayerFreeze = setPlayerFreeze

return M