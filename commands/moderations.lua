command = {}

local config = require("/app/config.lua")
local utils = require("/app/resolve-user.lua")
local cache = require("/app/server.lua")

command.info = {
  Name = "Moderations",
  Alias = {},
  Usage = "moderations",
  Description = "View all the active moderations in the server.",
  PermLvl = 2,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
end

return command