command = {}

command = function(message,args,client,data)
  if args[3] ~= nil then args[3] = args[3]:lower() end
  if args[3] == "prefix" then
    if args[4] == nil then return {success = false, msg = "You must provide a **new prefix**."} end
    if string.len(args[4]) >= 11 then return {success = false, msg = "The prefix must be **less than 10 characters**."} end
    data.general.prefix = args[4]:lower()
    return {success = true, msg = "Set the prefix to `"..data.general.prefix.."`."}
  elseif args[3] == "delcmd" then
    data.general.delcmd = not data.general.delcmd
    return {success = true, msg = "**"..(data.general.delcmd and "Enabled" or "Disabled").."** the **delete invocation message** setting."}
  elseif args[3] == "auditlog" or args[3] == "audit" then
    if args[4] == nil then return {success = false, msg = "You must provide an auditlog channel."} end
    local channel = require("/app/utils.lua").resolveChannel(message,table.concat(args," ",4))
    if channel == false then return {success = false, msg = "I couldn't find the channel you mentioned."} end
    data.general.auditlog = channel.id
    return {success = true, msg = "Set the **auditlog channel** to "..channel.mentionString.."."}
  elseif args[3] == "ignore" or args[3] == "ignored" then
    if args[4] == nil then return {success = false, msg = "You must provide a channel to ignore."} end
    local channel = require("/app/utils.lua").resolveChannel(message,table.concat(args," ",4))
    if channel == false then return {success = false, msg = "I couldn't find the channel you mentioned."} end
    local found = false
    for _,items in pairs(data.general.auditignore) do if items == channel.id then found = _ break end end
    if found ~= false then
      table.remove(data.general.auditignore,found)
    else
      data.general.auditignore[1+#data.general.auditignore] = channel.id
    end
    return {success = true, msg = (found == false and "Added" or "Removed").." "..channel.mentionString.." as an ignored channel."}
  end
end

return command