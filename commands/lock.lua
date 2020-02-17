command = {}

local config = require("/app/config.lua")
local utils = require("/app/resolve-user.lua")

command.info = {
  Name = "Lock",
  Alias = {},
  Usage = "lock <optional channel/category> <optional reason>",
  Category = "Administration",
  Description = "Lock a channel or set of channels.",
  PermLvl = 2,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  local lockData = {channel = "", reason = ""}
  if args[2] == nil then
    lockData.channel = message.channel.id
    lockData.reason = "No Reason Provided"
  elseif utils.resolveChannel(message,args[2]) ~= false then
    lockData.channel = utils.resolveChannel(message,args[2]).id
    locakData.reason = (args[3] == nil and "No Reason Provided" or table.concat(args, " ", 3))
  elseif utils.resolveCategory(message,args[2]) ~= false then
    lockData.channel = utils.resolveChannel(message,args[2]).id
    locakData.reason = (args[3] == nil and "No Reason Provided" or table.concat(args, " ", 3))
  else
    lockData.channel = message.channel.id
    lockData.reason = (args[2] == nil and "No Reason Provided" or table.concat(args, " ", 3))
  end
  if message.guild:getChannel(lockData.channel)
end

-- <:aaronlock:678918427523678208>

return command