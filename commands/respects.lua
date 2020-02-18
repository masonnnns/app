command = {}

local resolveUser = require("/app/resolve-user.lua")
local cache = require("/app/server.lua")

command.info = {
  Name = "Respects",
  Alias = {"f"},
  Usage = "respects <optional user>",
  Category = "Fun",
  Cooldown = 5,
  Description = "Pay respects to a user.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  local user = message.author
  if args[2] ~= nil and resolveUser.resolveUser(message,args[2]) ~= false then user = resolveUser.resolveUser(message,args[2]) end
  local msg = message:reply{embed = {
    description = "Press :regional_indicator_f: to pay respects"..(user.id == message.author.id and "." or " to "..user.mentionString.."."),
    footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
    color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
  }}
  msg:addReaction("🇫")
  return {success = "stfu", msg = "PONG!!", emote = ":ping_pong:"}
end

return command