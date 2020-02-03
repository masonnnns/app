command = {}

command.info = {
  Name = "Roles",
  Alias = {},
  Usage = "roles",
  Description = "Displays a list of all the roles in the guild.",
  PermLvl = 2,
}

command.execute = function(message,args,client)
  local roles = {}  for _,items in pairs(message.guild.roles) do roles[1+#roles] = items.mentionString end
  message:reply{embed = {
    title = "Roles",
    description = table.concat()
    footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
	  color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
  }}
  return {success = "stfu", msg = ""}
end

return command