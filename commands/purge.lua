command = {}

local utils = require("/app/utils.lua")

command.info = {
  Name = "Purge",
  Alias = {},
  Usage = "purge <optional user>",
  Category = "Fun",
  Description = "View a user's avatar.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  if args[2] == nil then args[2] = message.author.mentionString end
  local user = utils.resolveUser(message,table.concat(args," ",2))
  if user == false then user = message.author end
  message:reply{embed = {
      title = (user.id == message.author.id and "Your" or user.tag.."'s").." Avatar",
      description = "[Click here]("..user:getAvatarURL()..") to download.",
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      image = {url = user:getAvatarURL().."?size=256"},
      color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
    }}
  return {success = "stfu", msg = ""}
end

return command