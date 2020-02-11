command = {}

local config = require("/app/config.lua")
local utils = require("/app/resolve-user.lua")
local cache = require("/app/server.lua")

command.info = {
  Name = "Config",
  Alias = {},
  Usage = "config <setting/plugin> <path/new value> <new value>",
  Category = "Administration",
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
      color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
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
        color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
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
            color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
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
            color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
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
            value = "**Toggle:** "..(data.welcome.enabled and "Disables" or "Enables").." the plugin.\n**View:** Displays the Join and Leave message.\n**JoinChannel:** The channel where the join message is sent. (Accepts 'dm')\n**JoinMsg:** Sets the join message.\n**LeaveChannel:** The channel where the leave message is sent.\n**LeaveMsg:** Sets the leave message.\n**Autorole:** Sets the role to be given to users when they join.",
				  	inline = true,
			  	},
          {
            name = "Vairables",
            value = "**`{user}`** - Mentions the user. (Ex: "..message.author.mentionString..")\n**`{tag}`** - The user's username and discriminator. (Ex: "..message.author.tag..")\n**`{username}`** - The user's username. (Ex: "..message.author.username..")\n**`{discrim}`** - The user's discriminator. (Ex: "..message.author.discriminator..")\n**`{server}`** - The name of the guild. (Ex: "..message.guild.name..")\n**`{members}`** - The amount of people in the guild. (Ex: "..#message.guild.members..")",
            inline = false,
          },
        },
        color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
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
    elseif args[3] == "leavechannel" then
      if args[4] == nil then
        if data.welcome.leavechannel == "nil" then
          return {success = false, msg = "You must provide a **leave message channel** in argument 3."}
        else
          data.welcome.leavechannel = "nil"
          config.updateConfig(message.guild.id,data)
          return {success = true, msg = "**Disabled** the **leave message**."}
        end
      else
        local channel = utils.resolveChannel(message,args[4])
        if channel == false then
          return {success = false, msg = "I couldn't find the channel you mentioned."}
        else
          data.welcome.leavechannel = channel.id
          config.updateConfig(message.guild.id,data)
          return {success = true, msg = "Set the **leave message channel** to "..channel.mentionString.."."} end
      end
    elseif args[3] == "joinmsg" then
      if args[4] == nil then
        return {success = false, msg = "You must provide a **join message**."}
      else
        local msg = string.sub(message.content,(string.len(args[1])+string.len(args[2])+string.len(args[3])+4))
        data.welcome.joinmsg = msg
        config.updateConfig(message.guild.id,data)
        return {success = true, msg = "Changed the **join message**."}
      end
     elseif args[3] == "leavemsg" then
      if args[4] == nil then
        return {success = false, msg = "You must provide a **leave message**."}
      else
        local msg = string.sub(message.content,(string.len(args[1])+string.len(args[2])+string.len(args[3])+4))
        data.welcome.leavemsg = msg
        config.updateConfig(message.guild.id,data)
        return {success = true, msg = "Changed the **leave message**."}
      end 
    elseif args[3] == "view" then
      if data.welcome.joinchannel == "nil" or data.welcome.leavechannel == "nil" then return {success = false, msg = "No **join/leave message** to display."} end
      message:reply{embed = {
        title = "Welcome Messages",
        description = (data.welcome.joinchannel ~= "nil" and "**Join Message:** ```"..data.welcome.joinmsg.."```Sending to "..(data.welcome.joinchannel == "dm" and "**User DMs**" or (message.guild:getChannel(data.welcome.joinchannel) == nil and "**Nowhere.**" or message.guild:getChannel(data.welcome.joinchannel).mentionString)) or "")..(data.welcome.leavechannel ~= "nil" and "\n\n**Leave Message:** ```"..data.welcome.leavemsg.."``` Sending to "..(message.guild:getChannel(data.welcome.leavechannel) == nil and "**Nowhere.**" or message.guild:getChannel(data.welcome.leavechannel).mentionString)),
        color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
        footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
      }}
      return {success = "stfu", msg = ""}
    elseif args[3] == "autorole" then
      if args[4] == nil then
        if data.welcome.autorole == "nil" then
          return {success = false, msg = "You must provide a **autorole** in argument 3."}
        else
          data.welcome.autorole = "nil"
          return {success = true, msg = "Cleared the **autorole**."}
        end
      else
        local role = utils.resolveRole(message,table.concat(args," ",4))
        if role == false then
          return {success = false, msg = "I couldn't find the role you mentioned."}
        elseif role.position > message.guild:getMember(client.user.id).highestRole.position then
          return {success = false, msg = "I cannot manage the **"..role.name.."** role."}
        else
          data.welcome.autorole = role.id
          config.updateConfig(message.guild.id,data)
          return {success = true, msg = "Set the **autorole** to **"..role.name.."**."}
        end
      end
    elseif args[3] == "toggle" then
      data.welcome.enabled = not data.welcome.enabled
      config.updateConfig(message.guild.id,data)
      return {success = true, msg = "**"..(data.welcome.enabled and "Enabled" or "Disabled").."** the **welcome** plugin."}
    else
      local redoCmd = command.execute(message,{data.prefix.."config","welcome"},client)
      return redoCmd
    end
  -- [ END OF WELCOME] [ START OF TICKETS ]
  elseif args[2] == "tickets" then
    if args[3] then args[3] = args[3]:lower() end
    if args[3] == nil then
      message:reply{embed = {
        title = "Tickets Configuration Help",
        description = "To edit a ticket setting say **"..data.prefix.."config tickets <setting name>**\nTo view the current configuration settings say **"..data.prefix.."config view**",
        fields = {
          {
			  		name = "Tickets Settings",
            value = "**Toggle:** "..(data.tickets.enabled and "Disables" or "Enables").." the plugin.\n",
				  	inline = true,
			  	},
        },
        color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
        footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
      }} 
    end
  -- [ END OF TICKETS ] [ START OF AUTOMOD ]
  elseif args[2] == "automod" then
    if args[3] then args[3] = args[3]:lower() end
    if args[3] == nil then
       message:reply{embed = {
        title = "Automod Configuration Help",
        description = "To edit an automod setting say **"..data.prefix.."config automod <setting name>**\nTo view the current configuration settings say **"..data.prefix.."config view**",
        fields = {
          {
			  		name = "Automod Settings",
            value = "**Toggle:** "..(data.automod.enabled and "Disables" or "Enables").." the plugin.\n**View:** Displays a list of filtered terms.\n**Log:** Sets the automod log channel.\n**Invites:** Toggles the invites filter.\n**Mentions:** Toggles the mass-mentions filter, or sets a mention limit.\n**Spoilers:** Toggles the spoiler filter, or sets a spoiler limit.\n**Newline:** Toggles the newline filter, or sets a newline limit.\n**Spam:** Toggles the anti-spam filter.\n**Filter:** Toggles the words filter, or adds/removes a term from the filter.",
				  	inline = true,
			  	},
        },
        color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
        footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
      }} 
      return {success = "stfu", msg = ""}
    elseif args[3] == "toggle" then
      data.automod.enabled = not data.automod.enabled
      config.updateConfig(message.guild.id,data)
      return {success = true, msg = "**"..(data.automod.enabled and "Enabled" or "Disabled").."** the **automod** plugin."}
    elseif args[3] == "view" then
      if #data.terms == 0 then
        return {success = false, msg = "There are no **filtered terms** to display."}
      else
        local success, error = pcall(function() result = message.author:getPrivateChannel():send{embed = {title = "Filtered Words in "..message.guild.name, description = "The following could contain sensitive content. Click to view.\n||"..table.concat(data.terms,", ").."||", footer = {text = "From "..message.guild.name}, color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color)}} end)
        if success and result ~= nil then
           return {success = true, msg = "I sent you a **direct message** with the list of filtered terms."}
        else
          return {success = false, msg = "I **couldn't direct message** you, adjust your privacy settings and try again."}    
        end 
      end
    elseif args[3] == "log" then
       if args[4] == nil then
        if data.automod.log == "nil" then
          return {success = false, msg = "You must provide an **automod log channel** in argument 3."}
        else
          data.automod.log = "nil"
          config.updateConfig(message.guild.id,data)
          return {success = true, msg = "**Disabled** the **automod log message**."}
        end
      else
        local channel = utils.resolveChannel(message,args[4])
        if channel == false then
          return {success = false, msg = "I couldn't find the channel you mentioned."}
        else
          data.automod.log = channel.id
          config.updateConfig(message.guild.id,data)
          return {success = true, msg = "Set the **automod log channel** to "..channel.mentionString.."."} end
      end
    elseif args[3] == "spam" then
      data.automod.types.spam[1] = not data.automod.types.spam[1]
      config.updateConfig(message.guild.id,data)
      return {success = true, msg = "**"..(data.automod.types.spam[1] and "Enabled" or "Disabled").."** the **anti-spam** filter."}
    elseif args[3] == "invites" then
      data.automod.types.invites[1] = not data.automod.types.invites[1]
      config.updateConfig(message.guild.id,data)
      return {success = true, msg = "**"..(data.automod.types.invites[1] and "Enabled" or "Disabled").."** the **invites** filter."}
    elseif args[3] == "mentions" then
      if args[4] == nil then
        if data.automod.types.mentions[1] then
          data.automod.types.mentions[1] = false
          config.updateConfig(message.guild.id,data)
          return {success = true, msg = "**Disabled** the **mass-mentions** filter."}
        else
          return {success = false, msg = "You must provide a **max mentions** number in argument 4."}
        end
      elseif tonumber(args[4]) == nil then
        return {success = false, msg = "Argument 4 must be a **number**."}
      elseif tonumber(args[4]) < 2 then
        return {success = false, msg = "Argument 4 must be **greater than 1**."}
      else
        data.automod.types.mentions[1] = true
        data.automod.types.mentions[2] = tonumber(args[4])
        config.updateConfig(message.guild.id,data)
        return {success = true, msg = "Set the **mention limit** to **"..args[4].."**."}
      end
    elseif args[3] == "spoilers" then
      if args[4] == nil then
        if data.automod.types.spoilers[1] then
          data.automod.types.spoilers[1] = false
          config.updateConfig(message.guild.id,data)
          return {success = true, msg = "**Disabled** the **spoilers** filter."}
        else
          return {success = false, msg = "You must provide a **spoiler limit** in argument 4."}
        end
      elseif tonumber(args[4]) == nil then
        return {success = false, msg = "Argument 4 must be a **number**."}
      elseif tonumber(args[4]) < 2 then
        return {success = false, msg = "Argument 4 must be **greater than 1**."}
      else
        data.automod.types.spoilers[1] = true
        data.automod.types.spoilers[2] = tonumber(args[4])
        config.updateConfig(message.guild.id,data)
        return {success = true, msg = "Set the **spoiler limit** to **"..args[4].."**."}
      end
    elseif args[3] == "newline" then
      if args[4] == nil then
        if data.automod.types.newline[1] then
          data.automod.types.newline[1] = false
          config.updateConfig(message.guild.id,data)
          return {success = true, msg = "**Disabled** the **newline** filter."}
        else
          return {success = false, msg = "You must provide a **newline limit** in argument 4."}
        end
      elseif tonumber(args[4]) == nil then
        return {success = false, msg = "Argument 4 must be a **number**."}
      elseif tonumber(args[4]) < 2 then
        return {success = false, msg = "Argument 4 must be **greater than 1**."}
      else
        data.automod.types.newline[1] = true
        data.automod.types.newline[2] = tonumber(args[4])
        config.updateConfig(message.guild.id,data)
        return {success = true, msg = "Set the **newline limit** to **"..args[4].."**."}
      end
    elseif args[3] == "filter" then
      if args[4] == nil then
        data.automod.types.filter[1] = not data.automod.types.filter[1]
        config.updateConfig(message.guild.id,data)
        return {success = true, msg = "**"..(data.automod.types.filter[1] and "Enabled" or "Disabled").."** the **words filter**."}
      else
        local found
        for a,items in pairs(data.terms) do if items:lower() == table.concat(args," ",4):lower() then found = a break end end
        if found then
          table.remove(data.terms,found)
          config.updateConfig(message.guild.id,data)
          return {success = true, msg = "Removed that term from the **words filter**."}
        else
          data.terms[1+#data.terms] = table.concat(args," ",4)
          message:delete()
          return {success = true, msg = "Added that term to the **words filter**."}
        end
      end
    else
      local redoCmd = command.execute(message,{data.prefix.."config","automod"},client)
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
          value = "**Enabled:** "..(data.automod.enabled and "Yes." or "No.").."\n**Automod Log:** "..(data.automod.log == "nil" and "Disabled." or (message.guild:getChannel(data.automod.log) == nil and "Channel was Deleted." or message.guild:getChannel(data.automod.log).mentionString)).."\n**Invites Filter:** "..(data.automod.types.invites[1] and "Enabled." or "Disabled.").."\n**Mass-Mention Filter:** "..(data.automod.types.mentions[1] and "Enabled. (Limit: "..data.automod.types.mentions[2].."/msg)" or "Disabled.").."\n**Spoilers Filter:** "..(data.automod.types.spoilers[1] and "Enabled. (Limit: "..data.automod.types.spoilers[2].."/msg)" or "Disabled.").."\n**Newline Filter:** "..(data.automod.types.newline[1] and "Enabled. (Limit: "..data.automod.types.newline[2].."/msg)" or "Disabled.").."\n**Words Filter:** "..(data.automod.types.filter[1] and "Enabled." or "Disabled.").."\n**Spam Filter:** "..(data.automod.types.spam[1] and "Enabled." or "Disabled."),
          inline = true,
        },
        {
          name = "Welcome",
          value = "**Enabled:** "..(data.welcome.enabled and "Yes." or "No.").."\n**Join Message Channel:** "..(data.welcome.joinchannel == "nil" and "Disabled." or (data.welcome.joinchannel == "dm" and "DM User." or (message.guild:getChannel(data.welcome.joinchannel) == nil and "Channel was Deleted." or message.guild:getChannel(data.welcome.joinchannel).mentionString))).."\n**Leave Message Channel:** "..(data.welcome.leavechannel == "nil" and "Disabled." or (message.guild:getChannel(data.welcome.leavechannel) == nil and "Channel was Deleted." or message.guild:getChannel(data.welcome.leavechannel).mentionString)).."\n**Autorole:** "..(data.welcome.autorole == "nil" and "Disabled." or (message.guild:getRole(data.welcome.autorole) == nil and "Role was Deleted" or message.guild:getRole(data.welcome.autorole).mentionString)),
          inline = true,
        },
        {
          name = "Tickets",
          value = "**Enabled:** "..(data.tickets.enabled and "Yes." or "No.").."\n**Category:** "..(data.tickets.category == "nil" and "Not Set." or (message.guild:getChannel(data.tickets.category) == nil and "Category was Deleted." or message.guild:getChannel(data.tickets.category).name)),
          inline = true
        },
      },
      color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
    }}
    return {success = "stfu", msg = ""}
  else
    local rerunCmd = command.execute(message,{data.prefix.."config"},client)
    return rerunCmd
  end 
end

return command