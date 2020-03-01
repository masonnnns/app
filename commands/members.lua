command = {}

local config = require("/app/config.lua")
local utils = require("/app/utils.lua")

command.info = {
  Name = "Members",
  Alias = {},
  Usage = "members <optional role/name>",
  Category = "Utility",
  Description = "Get a list of members in a specified role or with a certain name.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if args[2] == nil then
    -- complete member overview
  else
    local role = utils.resolveRole(message,table.concat(args," ",2))
    
  end
end

return command