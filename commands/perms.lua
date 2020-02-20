command = {}

local resolveUser = require("/app/resolve-user.lua")
local cache = require("/app/server.lua")

command.info = {
  Name = "Perms",
  Alias = {"permissions"},
  Usage = "perms",
  Category = "Administration",
  Description = "View all the permissions the bot has.",
  PermLvl = 2,
}

command.execute = function(message,args,client)
  local msg = message:reply{embed = {
    description = "Press :regional_indicator_f: to pay respects"..(user.id == message.author.id and "." or " to "..user.mentionString.."."),
    footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
    color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
  }}
  msg:addReaction("🇫")
  return {success = "stfu", msg = "PONG!!", emote = ":ping_pong:"}
end

return command