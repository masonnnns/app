command = {}

local utils = require("/app/utils.lua")

command.info = {
  Name = "Purge",
  Alias = {},
  Usage = "purge <# of messages>",
  Category = "Utility",
  Description = "Bulk delete messages from a channel.",
  PermLvl = 2,
}

command.execute = function(message,args,client)
  if message.guild:getMember("414030463792054282"):getPermissions():has("manageMessages") == false and message.guild:getMember("414030463792054282"):getPermissions():has("administrator")  == false then return {success = false, msg = "I need the **Manage Messages** permission to do this."} end
  if args[2] == nil then return {success = false, msg = "You must provide **a number of messages** to delete in argument 2."} end
  if tonumber(args[2]) == nil then return {success = false, msg = "Argument 2 must be a number."} end
  message.channel:bulkDelete(message.channel:getMessages(tonumber(args[2])+1))
  return {success = true, msg = "Purged **"..args[2].."** message"..(tonumber(args[2]) == 1 and "" or "s").."."}
end

return command