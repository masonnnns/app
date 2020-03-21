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
  elseif args[3] == "modonly" then
    data.general.modonly = not data.general.modonly
    return {success = true, msg = "**"..(data.general.modonly and "Enabled" or "Disabled").."** the **moderator only** setting."}

  end
end

return command