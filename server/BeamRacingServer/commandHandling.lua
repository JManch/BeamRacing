local commandHandling = {}

function HandleChatMessage(sender_id, sender_name, message)

	print("Server received chat message from " .. sender_name .. " with id " .. sender_id .. ". Message is: " .. message)
end

function HandleConsoleInput(command)

    print("Detected console input with command " .. command)
end

MP.RegisterEvent("onChatMessage", "HandleChatMessage")
MP.RegisterEvent("onConsoleInput", "HandleConsoleInput")

return M