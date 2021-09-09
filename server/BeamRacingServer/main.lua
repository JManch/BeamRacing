local M = {}

local raceLogic = require("/Resources/Server/BeamRacingServer/raceLogic")
local clientControl = require("/Resources/Server/BeamRacingServer/clientControl")

function OnPlayerJoin(client)
	print("Player just joined with ID " .. client)
    raceLogic.registerPlayer(client)
end

function OnPlayerDisconnect(client)
	print("Player with ID " .. client .. " disconnected")
end

function OnChatMessage(client, senderName, message)
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
			raceLogic.startRace(argument)
		elseif command == "teleport" then
			clientControl.teleportPlayer(client, argument)
        elseif command == "quali" then
			print("yo")
			raceLogic.startQualifying(argument)
		end
	end
end

function onInit()
	print("Loaded BeamRacing")
	RegisterEvent("onChatMessage", "OnChatMessage")
	RegisterEvent("onPlayerJoin", "OnPlayerJoin")
	RegisterEvent("onPlayerDisconnect", "OnPlayerDisconnect")
end

return M