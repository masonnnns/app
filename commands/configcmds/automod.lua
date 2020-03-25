command = {}

command = function(message,args,client,data)
  if args[3] ~= nil then args[3] = args[3]:lower() end
  if args[3] == "toggle" then
    data.automod.enabled = not data.automod.enabled
    return {success = true, msg = "**"..(data.automod.enabled and "Enabled" or "Disabled").."** the **automod** plugin."}
  elseif args[3] == "log" then
    if args[4] == nil then return {success = false, msg = "You must provide an automod log channel."} end
    local channel = require("/app/utils.lua").resolveChannel(message,table.concat(args," ",4))
    if channel == false then return {success = false, msg = "I couldn't find the channel you mentioned."} end
    data.automod.log = channel.id
    return {success = true, msg = "Set the **automod log channel** to "..channel.mentionString.."."}
  end
end

return command