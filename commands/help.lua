command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")

command.info = {
  Name = "Help",
  Alias = {},
  Usage = "help <command>",
  Category = "Information",
  Description = "View a list of commands or get information on a specific commmand.",
  PermLvl = 1,
} 

command.execute = function(message,args,client)
  local search = ("NO_")
end

return command