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
    if args[3] == nil then
      if data.auditlog == "nil" then
        return {success = false, msg = "You must provide a **auditlog channel** in argument 3."}
      else
        data.auditlog = "nil"
        config.updateConfig(message.guild.id,data)
        return {success = true, msg = "**Disabled** the **auditlog**."}
      end
    else
        local channel = utils.resolveChannel(message,args[3])
        if channel == false then
          return {success = false, msg = "I couldn't find the channel you mentioned."}
        else
          data.auditlog = channel.id
          config.updateConfig(message.guild.id,data)
          return {success = true, msg = "Set the **auditlog channel** to "..channel.mentionString.."."}
        end
    end
  elseif args[2] == "modlog" then
    if args[3] == nil then
      if data.modlog == "nil" then
        return {success = false, msg = "You must provide a **modlog channel** in argument 3."}
      else
        data.modlog = "nil"
        config.updateConfig(message.guild.id,data)
        return {success = true, msg = "**Disabled** the **modlog**."}
      end
    else
      local channel = utils.resolveChannel(message,args[3])
      if channel == false then
        return {success = false, msg = "I couldn't find the channel you mentioned."}
      else
        data.modlog = channel.id
        config.updateConfig(message.guild.id,data)
        return {success = true, msg = "Set the **modlog channel** to "..channel.mentionString.."."}
      end
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
        return {success = false, msg = "I couldn't find the role you mentioned."}
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
        return {success = false, msg = "I couldn't find the role you mentioned."}
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
        description = "To edit a tag setting say **"..data.prefix.."config tags <setting name>**\nTo view the current configuration settings say **"..data.prefix.."config view**",
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
    elseif args[3] == "add" then
      if args[4] == nil then
        return {success = false, msg = "You must provide a **title for the tag** in argument 4."}
      elseif args[5] == nil then
        return {success = false, msg = "You must provide a **message for the tag**."}
      else
        for _,items in pairs(data.tags.tags) do if string.lower(items.term) == string.lower(args[4]) then return {success = false, msg = "A tag with that name **already exists**."} end end
        local msg = string.sub(message.content,(string.len(args[1])+string.len(args[2])+string.len(args[3])+string.len(args[4])+5))
        data.tags.tags[1+#data.tags.tags] = {term = args[4], response = msg}
        config.updateConfig(message.guild.id,data)
        return {success = true, msg = "Added the **"..args[4].."** tag."}
      end
    elseif args[3] == "edit" then
      if args[4] == nil then
        return {success = false, msg = "You must provide a **tag to edit** in argument 4."}
      else
        local found
        for num,items in pairs(data.tags.tags) do if string.lower(items.term) == string.lower(args[4]) then found = num break end end
        if found == nil then
          return {success = false, msg = "I couldn't find the tag you mentioned."}
        elseif args[5] == nil then
          return {success = false, msg = "You must provide a **new message for the tag**."}
        else
          local msg = string.sub(message.content,(string.len(args[1])+string.len(args[2])+string.len(args[3])+string.len(args[4])+5))
          data.tags.tags[found] = {term = data.tags.tags[found].term, response = msg}
          config.updateConfig(message.guild.id,data)
          return {success = true, msg = "Edited the **"..data.tags.tags[found].term.."** tag."}
        end
      end
    elseif args[3] == "delete" then
      if args[4] == nil then
        return {success = false, msg = "You must provide a **tag to delete** in argument 4."}
      else
        local found
        for num,items in pairs(data.tags.tags) do if string.lower(items.term) == string.lower(args[4]) then found = num break end end
        if found == nil then
          return {success = false, msg = "I couldn't find the tag you mentioned."}
        else 
          local name = data.tags.tags[found].term
          table.remove(data.tags.tags,found)
          config.updateConfig(message.guild.id,data)
          return {success = true, msg = "Deleted the **"..name.."** tag."}
        end
      end
    elseif args[3] == "view" then
      if args[4] == nil then
        if #data.tags.tags == 0 then
          return {success = false, msg = "There are **no tags** to display."}
        else
          local txts = ""
          for _,items in pairs(data.tags.tags) do txts = txts.."\n**"..items.term.."** - "..(string.len(items.response) >= 100 and string.sub(items.response,1,100).."..." or items.response) end
          message:reply{embed = {
            title = "Tags",
            description = "To view a specific tag's content say **"..data.prefix.."config tags view <tag name>**\n"..txts,
            color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
            footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
          }}
          return {success = "stfu", msg = ""}
        end
      else
        local found 
        for num,items in pairs(data.tags.tags) do if string.lower(items.term) == string.lower(args[4]) then found = num break end end
        if found == nil then
          return {success = false, msg = "I couldn't find the tag you mentioned."}
        else
          message:reply{embed = {
            title = data.tags.tags[found].term.." Tag",
            description = "```\n"..data.tags.tags[found].response.."\n```",
            color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
            footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
          }}
          return {success = "stfu", msg = ""}
        end
      end
    else
      local redoCmd = command.execute(message,{data.prefix.."config","tags"},client)
      return redoCmd
    end
  -- [ END OF TAGS] [ START OF WELCOME ]
  elseif args[2] == "welcome" then
    if args[3] then args[3] = args[3]:lower() end
    if args[3] == nil then
      message:reply{embed = {
        title = "Welcome Configuration Help",
        description = "To edit a welcome setting say **"..data.prefix.."config welcome <setting name>**\nTo view the current configuration settings say **"..data.prefix.."config view**",
        fields = {
          {
			  		name = "Welcome Settings",
            value = "**Toggle:** "..(data.welcome.enable and "Disables" or "Enables").." the plugin.\n**View:** Displays the Join and Leave message.\n**JoinChannel:** The channel where the join message is sent. (Accepts 'dm')\n**JoinMsg:** Sets the join message.\n**LeaveChannel:** The channel where the leave message is sent.\n**LeaveMsg:** Sets the leave message.\n**Autorole:** Sets the role to be given to users when they join.",
				  	inline = true,
			  	},
          {
            name = "Vairables",
            value = "**`{user}`** - Mentions the user. (Ex: "..message.author.mentionString..")\n**`{tag}`** - The user's username and discriminator. (Ex: "..message.author.tag..")\n**`{username}`** - The user's username. (Ex: "..message.author.username..")\n**`{discrim}`** - The user's discriminator. (Ex: "..message.author.discriminator..")\n**`{server}`** - The name of the guild. (Ex: "..message.guild.name..")\n**`{members}`** - The amount of people in the guild. (Ex: "..#message.guild.members..")",
            inline = false,
          },
        },
        color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
        footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
      }}
      return {success = "stfu", msg = ""}
    elseif args[3] == "joinchannel" then
      if args[4] == nil then
        if data.welcome.joinchannel == "nil" then
          return {success = false, msg = "You must provide a **join message channel** in argument 3."}
        else
          data.welcome.joinchannel = "nil"
          config.updateConfig(message.guild.id,data)
          return {success = true, msg = "**Disabled** the **join message**."}
        end
      else
        local channel = utils.resolveChannel(message,args[4])
        if args[4]:lower() == "dm" then
          data.welcome.joinchannel = "dm"
          config.updateConfig(message.guild.id,data)
          return {success = true, msg = "Set the **join message channel** to **user DMs**."}
        elseif channel == false then
          return {success = false, msg = "I couldn't find the channel you mentioned."}
        else
          data.welcome.joinchannel = channel.id
          config.updateConfig(message.guild.id,data)
          return {success = true, msg = "Set the **join message channel** to "..channel.mentionString.."."} end
      end
    else
      local redoCmd = command.execute(message,{data.prefix.."config","welcome"},client)
      return redoCmd
    end
  -- [ END OF PLUGINS] [ START OF VIEW ]
  elseif args[2] == "view" then
    message:reply{embed = {
      title = message.guild.name.." Configuration",
      description = "To edit a general setting say **"..data.prefix.."config**\nTo edit a plugin (besides general) say **"..data.prefix.."config <plugin name>**",
      fields = {
        {
          name = "General",
          value = "**Command Prefix:** "..data.prefix.."\n**Delete Invocation Message:** "..(data.deletecmd and "Enabled." or "Disabled.").."\n**Mod-Only Commands:** "..(data.modonly and "Enabled." or "Disabled.").."\n**Moderator Role:** "..(data.modrole == "nil" and "None Set." or (message.guild:getRole(data.modrole) == nil and "Role was Deleted." or message.guild:getRole(data.modrole).mentionString)).."\n**Muted Role:** "..(data.mutedrole == "nil" and "None Set." or (message.guild:getRole(data.mutedrole) == nil and "Role was Deleted." or message.guild:getRole(data.mutedrole).mentionString)).."\n**Auditlog:** "..(data.auditlog == "nil" and "Disabled." or (message.guild:getChannel(data.auditlog) == nil and "Channel was Deleted." or message.guild:getChannel(data.auditlog).mentionString)).."\n**Modlog:** "..(data.modlog == "nil" and "Disabled." or (message.guild:getChannel(data.modlog) == nil and "Channel was Deleted." or message.guild:getChannel(data.modlog).mentionString)),
          inline = true,
        },
        {
          name = "Tags",
          value = "**Enabled:** "..(data.tags.enabled and "Yes." or "No.").."\n**Delete Invocation Message:** "..(data.tags.delete and "Enabled." or "Disabled.").."\n**Total Tags:** "..(#data.tags.tags == 0 and "None!" or #data.tags.tags),
          inline = true,
        },
        {
          name = "Automod",
          value = "coming soon",
          inline = true,
        },
        {
          name = "Welcome",
          value = "**Enabled:** "..(data.welcome.enabled and "Yes." or "No.").."\n**Join Message Channel:** "..(data.welcome.joinchannel == "nil" and "Disabled." or (data.welcome.joinchannel == "dm" and "DM User." or (message.guild:getChannel(data.welcome.joinchannel) == nil and "Channel was Deleted." or message.guild:getChannel(data.welcome.joinchannel).mentionString))).."\n**Leave Message Channel:** "..(data.welcome.leavechannel == "nil" and "Disabled." or (message.guild:getChannel(data.welcome.leavechannel) == nil and "Channel was Deleted." or message.guild:getChannel(data.welcome.leavechannel).mentionString)).."\n**Autorole:** "..(data.welcome.autorole == "nil" and "Disabled." or (message.guild:getRole(data.welcome.autorole) == nil and "Role was Deleted" or message.guild:getRole(data.welcome.autorole).mentionString)),
          inline = true,
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