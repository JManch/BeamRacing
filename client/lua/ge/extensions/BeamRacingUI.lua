local M = {}

M.dependencies = {"ui_imgui"}
M.gui = {setupEditorGuiTheme = nop}

local gui_module = require("ge/extensions/editor/api/gui")
local im = ui_imgui

local function draw()
    if not M.gui.isWindowVisible("BeamRacing") then return end

    M.gui.setupWindow("BeamRacing")
    im.Begin("BeamRacing Menu")
    im.Columns(2)
    im.Text("Race status:")
    im.NextColumn()
    im.Text("Qualifying")
    im.NextColumn()
    im.Text("Spawn button:")
    im.NextColumn()
    if im.Button("Spawn") then
        print("Button pressed!")
    end
end

local function showUI()
    M.gui.showWindow("BeamRacing")
end

local function hideUI()
    M.gui.showWindow("BeamRacing")
end

local function initializeUI()

    gui_module.initialize(M.gui)
    M.gui.registerWindow("BeamRacing", im.ImVec2(256, 256))
    showUI()
end

local function onExtensionLoaded()
    
    print("Loaded BeamRacing UI Module")
    initializeUI()
end

local function onExtensionUnloaded()
    M.gui.unregisterWindow("BeamRacing")
end

local function onUpdate()
    draw()
end

M.onExtensionLoaded = onExtensionLoaded
M.onExtensionUnloaded = onExtensionUnloaded
M.onUpdate = onUpdate

return M