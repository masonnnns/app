command = {}

local cache = require("/app/server.lua")

command.info = {
  Name = "Invite",
  Alias = {},
  Usage = "invite",
  Description = "Get the link to invite the bot.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  message:reply{embed = {
      title = "Invite",
      description = "[Click here](https://discordapp.com/oauth2/authorize?client_id=414030463792054282&scope=bot&permissions=502787319) to invite me to your server.",
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
      color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
    }}
  return {success = "stfu", msg = ""}
end

return command