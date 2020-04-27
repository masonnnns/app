command = {}

local utils = require("/app/utils.lua")

command.info = {
  Name = "Getroles",
  Alias = {},
  Cooldown = 5,
}

command.execute = function(message,args,client)
  local config = require("/app/config.lua")
  local getRoles = utils.getRoles(message)
  if type(getRoles) == "table" then
    return {success = true, msg = "changes were made"}
  else
    return {success = false, msg = getRoles}
  end
end

return command