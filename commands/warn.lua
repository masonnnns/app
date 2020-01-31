command = {}

local config = require("/app/config.lua")
local resolveUser = require("/app/resolve-user.lua")

command.info = {
  Name = "Warn",
  Alias = {},
  Example = "warn <user> <reason>",
  Description = "Issue a warning to a specified user.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  if args[2] == nil then return {success = false, msg = "You must provide a **member to "..command.info.Name:lower().." in argument 2."} end
  local user = resolveUser.resolveUser(message,args[2])
  if user == false then
    return {success = false, msg = "I couldn't find the user you mentioned."}
  elseif resolveUser.getPermission(message,user.id,)
  end
end

return command