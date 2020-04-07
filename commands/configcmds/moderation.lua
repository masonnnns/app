command = {}

command = function(message,args,client,data)
  if args[3] ~= nil then args[3] = args[3]:lower() end
  if args[3] == "modonly" then
    data.general.modonly = not data.general.modonly
    return {success = true, msg = "**"..(data.general.modonly and "Enabled" or "Disabled").."** the **mod only commands** setting."}
  elseif args[3] == "modlog" or args[3] == "log" then
    if args[4] == nil then return {success = false, msg = "You must provide a modlog channel."} end
    local channel = require("/app/utils.lua").resolveChannel(message,table.concat(args," ",4))
    if channel == false then return {success = false, msg = "I couldn't find the channel you mentioned."} end
    data.general.modlog = channel.id
    return {success = true, msg = "Set the **modlog channel** to "..channel.mentionString.."."}
  elseif args[3] == "mutedrole" or args[3] == "muted" then
    if args[4] == nil then return {success = false, msg = "You must provide a muted role."} end
    local channel = require("/app/utils.lua").resolveRole(message,table.concat(args," ",4))
    if channel == false then return {success = false, msg = "I couldn't find the role you mentioned."} end
    data.general.mutedrole = channel.id
    return {success = true, msg = "Set the **muted role** to "..channel.name.."."}
  elseif args[3] == "mod" or args[3] == "modrole" then
    if args[4] == nil then return {success = false, msg = "You must provide a moderator role."} end
    local channel = require("/app/utils.lua").resolveRole(message,table.concat(args," ",4))
    if channel == false then return {success = false, msg = "I couldn't find the role you mentioned."} end
    local found
    for _,items in pairs(data.general.modroles) do if items == channel.id then found = _ break end end
    if found ~= nil then
      table.remove(data.general.modroles,_)
      return {success = true, msg = "Removed "..channel.name.." as a **moderator role**."}
    else
      data.general.modroles[1+#data.general.modroles] = channel.id
      return {success = true, msg = "Added "..channel.name.." as a **moderator role**."}
    end
  else
    message:reply{embed = {
      title = "Moderation Settings",
      description = "To edit a setting in the general plugin, say **"..data.general.prefix..args[1].." "..args[2].." <setting name> <new value>**",
      fields = {
        {name = "Settings", value = "**Modonly -** Toggles wither or not commands are restricted to server moderators.\n**Modlog -** Sets the modlog channel.\n**Muted -** Sets the muted role.\n**Modrole -** Adds or removes a role from the list of moderator roles.", inline = true},
      },
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
    }}
    return {success = "stfu"}
  end
end

return command