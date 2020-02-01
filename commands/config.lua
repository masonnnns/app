command = {}

local config = require("/app/config.lua")
local utils = require("/app/resolve-user.lua")

command.info = {
  Name = "Config",
  Alias = {},
  Usage = "config <setting/plugin> <path/new value> <new value>",
  Description = "Edit AA-R0N's configuation in your server.",
  PermLvl = 2,
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
        return {success = false, msg = "You must provide a **auditlog channel** in argument 3."}
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
        return {success = false, msg = "You must provide a **modlog channel** in argument 3."}
      end
    else
      data.modlog = message.mentionedChannels[1][1]
      config.updateConfig(message.guild.id,data)
      return {success = true, msg = "Set the **modlog channel** to "..message.guild:getChannel(message.mentionedChannels[1][1]).mentionString.."."}
    end
  elseif args[2] == "modrole" then
    if args[3] == nil then
      if data.modrole == "nil" then
        return {success = false, msg = "You must provide a **moderator role** in argument 3."}
      else
        data.modrole = "nil"
        return {success = true, msg = "Cleared the **moderator role**."}
      end
    else
      local role = utils.resolveRole(message,table.concat(args," ",3))
      if role == false then
        return {success = false, msg = "I couldn't the role you mentioned."}
      elseif role.position > message.guild:getMember(client.user.id).highestRole.position then
        return {success = false, msg = "I cannot manage the **"..role.name.."** role."}
      else
        data.modrole = role.id
        config.updateConfig(message.guild.id,data)
        return {success = true, msg = "Set the **moderator role** to **"..role.name.."**."}
      end
    end
  elseif args[2] == "muterole" then
    if args[3] == nil then
      if data.mutedrole == "nil" then
        return {success = false, msg = "You must provide a **muted role** in argument 3."}
      else
        data.mutedrole = "nil"
        return {success = true, msg = "Cleared the **muted role**."}
      end
    else
      local role = utils.resolveRole(message,table.concat(args," ",3))
      if role == false then
        return {success = false, msg = "I couldn't the role you mentioned."}
      elseif role.position > message.guild:getMember(client.user.id).highestRole.position then
        return {success = false, msg = "I cannot manage the **"..role.name.."** role."}
      else
        data.mutedrole = role.id
        config.updateConfig(message.guild.id,data)
        return {success = true, msg = "Set the **muted role** to **"..role.name.."**."}
      end
    end
  -- [ GENERAL PLUGINS END] [ START OF TAGS PLUGIN ]
  elseif args[2] == "tags" then
    if args[3] then args[3] = args[3]:lower() end
    if args[3] == nil then
      message:reply{embed = {
        title = "Tags Configuration Help",
        description = "To edit a tag setting say **"..data.prefix.."config tags <setting name>**\nTo learn how to configure other plugins say **"..data.prefix.."config <plugin name>**\nTo view the current configuration settings say **"..data.prefix.."config view**",
        fields = {
          {
			  		name = "Tag Settings",
            value = "**Toggle:** "..(data.tags.enabled and "Disables" or "Enables").." the plugin.\n**DelCmd:** Deletes the tag invocation message __only.__\n**Add:** Creates a new tag.\n**Edit:** Edits an existing tag.\n**Delete:** Deletes an existing tag.\n**View:** Views all existing tags, or a specified one.",
				  	inline = true,
			  	},
        },
        color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
        footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
      }}
      return {success = "stfu", msg = ""}
    elseif args[3] == "toggle" then
      data.tags.enabled = not data.tags.enabled
      config.updateConfig(message.guild.id,data)
      return {success = true, msg = "**"..(data.tags.enabled and "Enabled" or "Disabled").."** the **tags** plugin."}
    elseif args[3] == "delcmd" then
      data.tags.delete = not data.tags.delete
      config.updateConfig(message.guild.id,data)
      return {success = true, msg = "**"..(data.tags.delete and "Enabled" or "Disabled").."** the **delete tag command** setting."}
    else
      local redoCmd = command.execute(message,{data.prefix.."config","tags"},client)
      return redoCmd
    end
  -- [ END OF PLUGINS] [ START OF VIEW ]
  elseif args[2] == "view" then
    message:reply{embed = {
      title = message.guild.name.." Configuration",
      description = "To edit a general setting say **"..data.prefix.."config <setting name>**\nTo edit a plugin (besides general) say **"..data.prefix.."config <plugin name> <setting name>**",
      fields = {
        {
          name = "General",
          value = "**Command Prefix:** "..data.prefix.."\n**Delete Invocation Message:** "..(data.deletecmd and "Enabled." or "Disabled.").."\n**Mod-Only Commands:** "..(data.modonly and "Enabled." or "Disabled.").."\n**Moderator Role:** "..(data.modrole == "nil" and "None Set." or (message.guild:getRole(data.modrole) == nil and "Role was Deleted." or message.guild:getRole(data.modrole).mentionString)).."\n**Muted Role:** "..(data.mutedrole == "nil" and "None Set." or (message.guild:getRole(data.mutedrole) == nil and "Role was Deleted." or message.guild:getRole(data.mutedrole).mentionString)).."\n**Auditlog:** "..(data.auditlog == "nil" and "Disabled." or (message.guild:getChannel(data.auditlog) == nil and "Channel was Deleted." or message.guild:getChannel(data.auditlog).mentionString)).."\n**Modlog:** "..(data.modlog == "nil" and "Disabled." or (message.guild:getChannel(data.modlog) == nil and "Channel was Deleted." or message.guild:getChannel(data.modlog).mentionString)),
          inline = false,
        },
        {
          name = "General",
          value = "**Command Prefix:** "..data.prefix.."\n**Delete Invocation Message:** "..(data.deletecmd and "Enabled." or "Disabled.").."\n**Mod-Only Commands:** "..(data.modonly and "Enabled." or "Disabled.").."\n**Moderator Role:** "..(data.modrole == "nil" and "None Set." or (message.guild:getRole(data.modrole) == nil and "Role was Deleted." or message.guild:getRole(data.modrole).mentionString)).."\n**Muted Role:** "..(data.mutedrole == "nil" and "None Set." or (message.guild:getRole(data.mutedrole) == nil and "Role was Deleted." or message.guild:getRole(data.mutedrole).mentionString)).."\n**Auditlog:** "..(data.auditlog == "nil" and "Disabled." or (message.guild:getChannel(data.auditlog) == nil and "Channel was Deleted." or message.guild:getChannel(data.auditlog).mentionString)).."\n**Modlog:** "..(data.modlog == "nil" and "Disabled." or (message.guild:getChannel(data.modlog) == nil and "Channel was Deleted." or message.guild:getChannel(data.modlog).mentionString)),
          inline = false,
        },
      },
      color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
    }}
    return {success = "stfu", msg = ""}
  else
    local rerunCmd = command.execute(message,{data.prefix.."config"},client)
    return rerunCmd
  end 
end

return command