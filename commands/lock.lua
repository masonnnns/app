command = {}

local config = require("/app/config.lua")
local utils = require("/resolve-user.lua")

command.info = {
  Name = "Lock",
  Alias = {},
  Usage = "lock <optional channel/category> <optional duration> <optional reason>",
  Category = "Administration",
  Description = "Lock a channel or set of channels.",
  PermLvl = 2,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  local lockData = {channel = "", reason = "", duration = ""}
  if args[2] == nil then
    lockData.channel = message.channel.id
    lockData.reason = "No Reason Provided"
    lockData.duration = "Permanent"
    message:reply()
  end
end

return command