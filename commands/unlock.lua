command = {}

local config = require("/app/config.lua")
local utils = require("/app/resolve-user.lua")

command.info = {
  Name = "Unlock",
  Alias = {},
  Usage = "unlock <optional channel>",
  Category = "Moderation",
  Description = "Unlock a locked channel.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  local lockData = {channel = "", reason = ""}
  if message.guild:getMember(client.user.id):hasPermission("manageChannels") == false then return {success = false, msg = "I need the **Manage Channels** permission to do this."} end
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
    end
    local success = channel:getPermissionOverwriteFor(message.guild:getRole(message.guild.id)):allowPermissions("sendMessages")
    if not success then return {success = false, msg = "I need the **Manage Channels** permission to do this."} end
    if channel.id ~= message.channel.id then
      channel:send("<:aaronlock:678918427523678208> This channel has been locked by server staff.\n**Reason:** "..lockData.reason)
    end
    data.modData.locked[channel.id] = message.author.id
    return {success = true, msg = "**"..channel.mentionString.."** has been unlocked."}
  else
    return {success = false, msg = "I can only unlock **text channels**."}
  end
end

-- <:aaronlock:678918427523678208>

return command