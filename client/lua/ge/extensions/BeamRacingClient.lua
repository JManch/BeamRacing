local M = {}

local function printText(text)
    print("Your test was: " .. tostring(text))
end

local function SplitSpaces(s)
    local result = {};
    for word in (s.." "):gmatch("(.-)".." ") do
        table.insert(result, word);
    end
    return result;
end

local function onBeamNGTrigger(data)
    print("Trigger activated with name " .. data.triggerName .. " and data event " .. data.event)
    if data.subjectID == be:getPlayerVehicleID(0) and data.event == "enter" then
        TriggerServerEvent("onClientPassedCheckpoint", data.triggerName)
    end
end

local function teleportPlayer(position)
    print("Teleport player was called for vehicle ID " .. be:getPlayerVehicleID(0))
    local coords = SplitSpaces(position)
    vehicleSetPositionRotation(be:getPlayerVehicleID(0), coords[1], coords[2], coords[3], coords[4], coords[5], coords[6], coords[7])
end

local function testEvent(data)
    print("Test event received: " .. tostring(data))
end

local function onExtensionLoaded()
    print("BeamRacingClient loaded")
    AddEventHandler("teleportPlayer", teleportPlayer)
    AddEventHandler("testEvent", testEvent)
end

M.printText = printText
M.onExtensionLoaded = onExtensionLoaded
M.teleportPlayer = teleportPlayer
M.testEvent = testEvent
M.onBeamNGTrigger = onBeamNGTrigger

return M