local M = {}

local function printText(text)
    print("Your test was: " .. tostring(text))
end

local function splitSpaces(s)
    local result = {};
    for word in (s.." "):gmatch("(.-)".." ") do
        table.insert(result, word);
    end
    return result;
end

local function setLapUI(data)
    -- format needs to be {current = 2, count = 3}
    local lapData = splitSpaces(data)
    guihooks.trigger('RaceLapChange', {current = lapData[1], count = lapData[2]} )
    --be:queueLuaCommand('')
end

local function setPositionUI(data)
    guihooks.trigger('Position', tonumber(data))
end

local function onBeamNGTrigger(data)
    print("Trigger activated with name " .. data.triggerName .. " and data event " .. data.event)
    if data.subjectID == be:getPlayerVehicleID(0) and data.event == "enter" then
        TriggerServerEvent("onClientPassedCheckpoint", data.triggerName)
    end
end

local function setPlayerFreeze(freeze)
    local command = 'controller.setFreeze(' .. tostring(freeze) .. ')'
    be:getObjectByID(be:getPlayerVehicleID(0)):queueLuaCommand(command)
end

local function teleportPlayer(position)
    print("Teleport player was called for vehicle ID " .. be:getPlayerVehicleID(0))
    local vehicleID = be:getPlayerVehicleID(0)

    -- First recover the vehicle in place
    be:getObjectByID(vehicleID):queueLuaCommand('recovery.recoverInPlace()')

    local coords = splitSpaces(position)
    vehicleSetPositionRotation(vehicleID, coords[1], coords[2], coords[3], coords[4], coords[5], coords[6], coords[7])
end

local function testEvent(data)
    print("Test event received: " .. tostring(data))
end

local function onExtensionLoaded()
    print("BeamRacingClient loaded")
    AddEventHandler("teleportPlayer", teleportPlayer)
    AddEventHandler("setPlayerFreeze", setPlayerFreeze)
    AddEventHandler("testEvent", testEvent)
end

M.printText = printText
M.onExtensionLoaded = onExtensionLoaded
M.teleportPlayer = teleportPlayer
M.setPlayerFreeze = setPlayerFreeze
M.testEvent = testEvent
M.onBeamNGTrigger = onBeamNGTrigger
M.setLapUI = setLapUI
M.setPositionUI = setPositionUI

return M