local M = {}

local var = ""

local function setVar(value)
    var = value
end

function GlobalFunc()
    print(var)
end

M.setVar = setVar

return M

--require("test2").setVar("test")