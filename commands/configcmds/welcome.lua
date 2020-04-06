command = {}

command = function(message,args,client,data)
  if args[3] ~= nil then args[3] = args[3]:lower() end
  if args[3] == "joinchannel" then
    
  else
    message:reply{embed = {
      title = "General Settings",
      description = "To edit a setting in the general plugin, say **?"..args[1].." "..args[2].." <setting name> <new value>**",
      fields = {
        {name = "Settings", value = "**Prefix -** Changes the prefix of the server.\n**Delcmd -** Toggles on or off AA-R0N deleting the command invocation message.\n**Auditlog -** Sets the auditlog channel.\n**Ignore -** Adds channel to the audit log's ignored channels.", inline = true},
      },
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
    }}
    return {success = "stfu"}
  end
end

return command