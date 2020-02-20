command = {}

local config = require("/app/config.lua")
local utils = require("/app/resolve-user.lua")
local timer = require("timer")
local cache = require("/app/server.lua")

command.info = {
  Name = "Unlock",
  Alias = {},
  Usage = "unlock <optional channel>",
  Category = "Moderation",
  Description = "Unlock a locked channel.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  if cache.getCache("getperm",message.guild.id,"manageChannels") == false and cache.getCache("getperm",message.guild.id,"administrator") == false then return {success = false, msg = "I need the **Manage Channels** permission to do this."} end
  local data = config.getConfig(message.guild.id)
  local lockData = {channel = "", reason = ""}
  --if message.guild:getMember(client.user.id):hasPermission("manageChannels") == false then return {success = false, msg = "I need the **Manage Channels** permission to do this."} end
  if args[2] == nil then
    lockData.channel = message.channel.id
  elseif utils.resolveChannel(message,args[2]) ~= false then
    lockData.channel = utils.resolveChannel(message,args[2]).id
  else
    lockData.channel = message.channel.id
  end
  local channel = message.guild:getChannel(lockData.channel)
  if channel.type == 0 then
    if channel:getPermissionOverwriteFor(message.guild:getRole(message.guild.id)):getDeniedPermissions():has("readMessages") then
      return {success = false, msg = channel.mentionString.." is a private channel."}
    elseif channel:getPermissionOverwriteFor(message.guild:getRole(message.guild.id)):getAllowedPermissions():has("sendMessages") then
      return {success = false, msg = channel.mentionString.." isn't locked."}
    elseif data.modData.locked[channel.id] == nil then
      return {success = false, msg = "I didn't lock "..channel.mentionString.."!"}
    end
    local success = channel:getPermissionOverwriteFor(message.guild:getRole(message.guild.id)):allowPermissions("sendMessages")
    if not success then return {success = false, msg = "I need the **Manage Channels** permission to do this."} end
    message:reply("<:atickyes:678186418937397249>  "..channel.mentionString.." has been unlocked.")
    local msg
    if channel.id ~= message.channel.id then
      if tonumber(data.modData.locked[channel.id]) ~= nil and channel:getMessage(data.modData.locked[channel.id]) then
        msg = channel:getMessage(data.modData.locked[channel.id])
        channel:getMessage(data.modData.locked[channel.id]):setContent("<:aaronunlock:679431104138313766> This channel has been unlocked!")
      else
        msg = channel:send("<:aaronunlock:679431104138313766> This channel has been unlocked!")
      end
      timer.sleep(5000)
      msg:delete()
    end
    data.modData.locked[channel.id] = nil
    return {success = "stfu", msg = "**"..channel.mentionString.."** has been unlocked."}
  else
    return {success = false, msg = "I can only unlock **text channels**."}
  end
end

-- <:aaronlock:678918427523678208>

return command