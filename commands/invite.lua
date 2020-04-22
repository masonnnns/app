command = {}

command.info = {
  Name = "Invite",
  Alias = {},
  Usage = "invite",
  Category = "Information",
  Description = "Get the link to invite the bot.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  message:reply{embed = {
      title = "Invite",
      description = "[Click here](https://discordapp.com/oauth2/authorize?client_id=414030463792054282&scope=bot&permissions=502787319) to invite me to your server.",
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = (message.member:getColor() == 0 and 3066993 or message.member:getColor().value),
    }}
  return {success = "stfu", msg = ""}
end

return command