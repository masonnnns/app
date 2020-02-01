command = {}

local config = require("/app/config.lua")

command.info = {
  Name = "Config",
  Alias = {},
  Usage = "config <setting/plugin> <path/newvalue> <new value>",
  Description = "Edit AA-R0N's configuation in your server.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if args[2] then args[2] = args[2]:lower() end
  if args[2] == nil then
    message:reply{embed = {
      title = "Configuration Help",
      description = "To edit a general setting say **"..data.prefix.."config <setting name>**\nTo learn how to configure other plugins say **"..data.prefix.."config <plugin name>**\nTo view the current configuration settings say **"..data.prefix.."config view**",
      fields = {
        {
					name = "General Settings",
					value = "**ModOnly:** Makes commands restricted to server moderators and higher.\n**DelCmd:** Deletes the command invocation message.\n**Auditlog:** A channel where changes in the server are audited.\n**Modlog:** A channel where moderation actions are audited.\n**Modrole:** A role that declares the moderators of the server.\n**Muterole:** A role given to muted users.",
					inline = true,
				},
      },
      color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
    }}
    return {success = "stfu", msg = ""}
  elseif args[2] == "modonly" then
    data.modonly = not data.modonly
    config.updateConfig(message.guild.id,data)
    return {success = true, msg = "**"..(data.modonly and "Enabled" or "Disabled").."** the **mod-only** setting."}
  elseif args[2] == "delcmd" then
    data.deletecmd = not data.deletecmd
    config.updateConfig(message.guild.id,data)
    return {success = true, msg = "**"..(data.deletecmd and "Enabled" or "Disabled").."** the **delete command** setting."}
  elseif args[2] == "auditlog" then
    if #message.mentionedChannels == 0 then
      if data.auditlog ~= "nil" then
        data.auditlog = "nil"
        config.updateConfig(message.guild.id,data)
        return {success = true, msg = "**Disabled** the **auditlog**."}
      else
        return {success = false, msg = "You must provide a **new auditlog channel** in argument 3."}
      end
    else
      data.auditlog = message.mentionedChannels[1][1]
      config.updateConfig(message.guild.id,data)
      return {success = true, msg = "Set the **auditlog channel** to "..message.guild:getChannel(message.mentionedChannels[1][1]).mentionString.."."}
    end
  elseif args[2] == "modlog" then
    if #message.mentionedChannels == 0 then
      if data.modlog ~= "nil" then
        data.modlog = "nil"
        config.updateConfig(message.guild.id,data)
        return {success = true, msg = "**Disabled** the **modlog**."}
      else
        return {success = false, msg = "You must provide a **new modlog channel** in argument 3."}
      end
    else
      data.modlog = message.mentionedChannels[1][1]
      config.updateConfig(message.guild.id,data)
      return {success = true, msg = "Set the **modlog channel** to "..message.guild:getChannel(message.mentionedChannels[1][1]).mentionString.."."}
    end
  end 
end

return command