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
    lockData.reason = (args[3] == nil and "No Reason Provided" or table.concat(args, " ", 3))
  elseif utils.resolveCategory(message,args[2]) ~= false then
    lockData.channel = utils.resolveChannel(message,args[2]).id
    lockData.reason = (args[3] == nil and "No Reason Provided" or table.concat(args, " ", 3))
  else
    lockData.channel = message.channel.id
    lockData.reason = (args[2] == nil and "No Reason Provided" or table.concat(args, " ", 3))
  end
  local channel = message.guild:getChannel(lockData.channel)
  if channel.type == 0 then
    channel:getPermissionOverwriteFor(message.guild:getRole(message.guild.id)):denyAllPermissions()
  elseif channel.type == 4 then
    return {success = true, msg = "category"}
  else
    return {success = false, msg = "I can only lock **text channels** or **categories**."}
  end
end

-- <:aaronlock:678918427523678208>

return command