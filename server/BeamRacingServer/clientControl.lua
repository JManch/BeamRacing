local M = {}

local utils = require("/Resources/Server/BeamRacingServer/utils")

local function teleportClient(client, posandrot)
	local coords = utils.SplitSpaces(posandrot)
	
    print("Table length is " .. utils.tableLength(coords))
	--if(utils.tableLength(coords) ~= 6) then
      --  return
    --end
    
	TriggerClientEvent(client, "teleportPlayer", coords[1] .. " " .. coords[2] .. " " .. coords[3] .. " " .. coords[4] .. " " .. coords[5] .. " " .. coords[6] .. " " .. coords[7])
end

local function setClientFreeze(client, freeze)
    TriggerClientEvent(client, "setPlayerFreeze", freeze)
end

M.teleportPlayer = teleportClient
M.setClientFreeze = setClientFreeze

return M