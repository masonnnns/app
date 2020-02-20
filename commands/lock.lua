command = {}

local config = require("/app/config.lua")
local utils = require("/app/resolve-user.lua")

command.info = {
  Name = "Lock",
  Alias = {},
  Usage = "lock <optional channel> <optional reason>",
  Category = "Moderation",
  Description = "Lock a channel or set of channels.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  local lockData = {channel = "", reason = ""}
  --if message.guild:getMember(client.user.id):hasPermission("manageChannels") == false then return {success = false, msg = "I need the **Manage Channels** permission to do this."} end
  if args[2] == nil then
    lockData.channel = message.channel.id
    lockData.reason = "No Reason Provided"
  elseif utils.resolveChannel(message,args[2]) ~= false then
    lockData.channel = utils.resolveChannel(message,args[2]).id
    lockData.reason = (args[3] == nil and "No Reason Provided" or table.concat(args, " ", 3))
  else
    lockData.channel = message.channel.id
    lockData.reason = (args[2] == nil and "No Reason Provided" or table.concat(args, " ", 3))
  end
  local channel = message.guild:getChannel(lockData.channel)
  if channel.type == 0 then
    if channel:getPermissionOverwriteFor(message.guild:getRole(message.guild.id)):getDeniedPermissions():has("sendMessages") or channel:getPermissionOverwriteFor(message.guild:getRole(message.guild.id)):getDeniedPermissions():has("readMessages") then return {success = false, msg = "**"..channel.mentionString.."** is already locked."} end
    local success = channel:getPermissionOverwriteFor(message.guild:getRole(message.guild.id)):denyPermissions("sendMessages")
    if not success then return {success = false, msg = "I need the **Manage Channels** permission to do this."} end
    data.modData.locked[channel.id] = message.author.id
    if channel.id ~= message.channel.id then
      local msg = channel:send("<:aaronlock:678918427523678208> This channel has been locked by server staff.\n**Reason:** "..lockData.reason)
     data.modData.locked[channel.id] = msg.id
    end
    return {success = true, msg = "**"..channel.mentionString.."** has been locked."}
  else
    return {success = false, msg = "I can only lock **text channels**."}
  end
end

-- <:aaronlock:678918427523678208>

return command