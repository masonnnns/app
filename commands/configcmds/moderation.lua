command = {}

command = function(message,args,client,data)
  if args[3] ~= nil then args[3] = args[3]:lower() end
  if args[3] == "modonly" then
    data.general.modonly = not data.general.modonly
    return {success = true, msg = "**"..(data.general.modonly and "Enabled" or "Disabled").."** the **mod only commands** setting."}
  elseif args[3] == "modlog" then
    if args[4] == nil then return {success = false, msg = "You must provide a modlog channel."} end
    local channel = require("/app/utils.lua").resolveChannel(message,table.concat(args," ",4))
    if channel == false then return {success = false, msg = "I couldn't find the channel you mentioned."} end
    data.general.modlog = channel.id
    return {success = true, msg = "Set the **modlog channel** to "..channel.mentionString.."."}
  elseif args[3] == "mutedrole" or args[3] == "muted"
    
  end
end

return command