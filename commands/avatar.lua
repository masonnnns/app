command = {}

local cache = require("/app/server.lua")
local utils = require("/app/resolve-user.lua")

command.info = {
  Name = "Avatar",
  Alias = {"av"},
  Usage = "avatar <optional user>",
  Category = "Fun",
  Description = "View a user's avatar.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  if args[2] == nil then args[2] = message.author.mentionString end
  error("gay")
  local user = utils.resolveUser(message,table.concat(args," ",2))
  if user == false then user = message.author end
  message:reply{embed = {
      title = (user.id == message.author.id and "Your" or user.name.."'s").." Avatar",
      description = "[Click here]("..user:getAvatarURL()..") to download.",
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
      image = {url = user:getAvatarURL().."?size=256"},
      color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
    }}
  return {success = "stfu", msg = ""}
end

return command