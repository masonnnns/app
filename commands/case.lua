command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")

command.info = {
  Name = "Case",
  Alias = {},
  Usage = "case <number>",
  Category = "Moderation",
  Description = "View a moderation case.",
  PermLvl = 1,
} 

command.execute = function(message,args,client)
  if args[2] == nil then return {success = false, msg = "You must provide a **case to view** in argument 2."} end
  if tonumber(args[2]) == nil then return {success = false, msg = "Invalid argument**```"..command.info.Usage.."```"} end
  local data = config.getConfig(message.guild.id)
end

return command