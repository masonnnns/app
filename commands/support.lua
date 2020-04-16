command = {}

command.info = {
  Name = "Support",
  Alias = {},
  Usage = "support",
  Category = "Information",
  Description = "Get the link to the support server.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  message:reply{embed = {
      title = "Support Server",
      description = "[Click here](https://discord.gg/PjKaAXx) to join the server.",
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
    }}
  return {success = "stfu", msg = ""}
end

return command