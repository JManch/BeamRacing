local M = {}

function OnPlayerJoin(client)

	print("Player just joined with ID " .. client)
    --raceLogic.registerPlayer(client)
end

function OnPlayerDisconnect(client)

	print("Player with ID " .. client .. " disconnected")
	--raceLogic.deregisterPlayer(client)
end

function onInit()

	print("BeamRacing initialized")

	--RegisterEvent("onChatMessage", "OnChatMessage")
	--RegisterEvent("onPlayerJoin", "OnPlayerJoin")
	--RegisterEvent("onPlayerDisconnect", "OnPlayerDisconnect")

	--raceLogic.onInit()
end

return M