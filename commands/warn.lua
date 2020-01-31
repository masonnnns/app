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
  local user = resolveUser.resolveUser(message,args[2])
  if user then
    return {success = true, msg = user.name}
  else
    return {success = false, msg = "no user"}
  end
end

return command