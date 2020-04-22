command = {}

command = function(message,args,client,data)
  if args[3] ~= nil then args[3] = args[3]:lower() end
  if args[3] == "view" then
    if #data.tags.tags == 0 then return {success = false, msg = "There are no tags setup."} end
    local embed = {
      title = "Tags ["..#data.tags.tags.."]",
      description = "",
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = (message.member:getColor() == 0 and 3066993 or message.member:getColor().value),
    }
    local tble = {}
    for a,b in pairs(data.tags.tags) do
      tble[1+#tble] = b.name
    end
    embed.description = table.concat(tble,", ")
    message:reply{embed = embed}
  elseif args[3] == "delete" then
    if args[4] == nil then return {success = false, msg = "You must provide a tag to delete."} end
    for a,b in pairs(data.tags.tags) do
      if b.name:lower() == args[4]:lower() then
        table.remove(a,data.tags.tags)
        return {success = true, msg = "Deleted the **"..args[4:]}
      end
    end
  else
    message:reply{embed = {
      title = "Moderation Settings",
      description = "To edit a setting in the general plugin, say **"..data.general.prefix..args[1].." "..args[2].." <setting name> <new value>**",
      fields = {
        {name = "Settings", value = "**Modonly -** Toggles wither or not commands are restricted to server moderators.\n**Modlog -** Sets the modlog channel.\n**Muted -** Sets the muted role.\n**Modrole -** Adds or removes a role from the list of moderator roles.", inline = true},
      },
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = (message.member:getColor() == 0 and 3066993 or message.member:getColor().value),
    }}
    return {success = "stfu"}
  end
end

return command