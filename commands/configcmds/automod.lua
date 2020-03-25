command = {}

command = function(message,args,client,data)
  if args[3] ~= nil then args[3] = args[3]:lower() end
  if args[3] == "toggle" then
    data.automod.enabled = not data.automod.enabled
    return {success = true, msg = "**"..(data.automod.enabled and "Enabled" or "Disabled").."** the **automod** plugin."}
  elseif args[3] == "log" then
    if args[4] == nil then return {success = false, msg = "You must provide an automod log channel."} end
    local channel = require("/app/utils.lua").resolveChannel(message,table.concat(args," ",4))
    if channel == false then return {success = false, msg = "I couldn't find the channel you mentioned."} end
    data.automod.log = channel.id
    return {success = true, msg = "Set the **automod log channel** to "..channel.mentionString.."."}
  elseif args[3] == "antispam" or args[3] == "spam" then
    data.automod.spam.enabled = not data.automod.spam.enabled
    return {success = true, msg = "**"..(data.automod.spam.enabled and "Enabled" or "Disabled").."** the **anti-spam** filter."}
  elseif args[3] == "antiinvite" or args[3] == "invites" then
    data.automod.invites.enabled = not data.automod.invites.enabled
    return {success = true, msg = "**"..(data.automod.invites.enabled and "Enabled" or "Disabled").."** the **invites** filter."}
  elseif args[3] == "words" then
    data.automod.words.enabled = not data.automod.words.enabled
    return {success = true, msg = "**"..(data.automod.words.enabled and "Enabled" or "Disabled").."** the **words** filter."}
  elseif args[3] == "newline" then
    if args[4] == nil then
      data.automod.newline.enabled = not data.automod.newline.enabled
      return {success = true, msg = "**"..(data.automod.newline.enabled and "Enabled" or "Disabled").."** the **newline** filter."}
    elseif tonumber(args[4]) == nil then
      return {success = false, msg = "You must provide a neumerical newline limit in argument 4."}
    elseif tonumber(args[4]) < 1 then
      return {success = false, msg = "The newline limit must be greater than or equal to 1."}
    else
      data.automod.newline.limit = tonumber(args[4])
      return {success = true, msg = "Set the **newline limit** to **"..args[4].."**."}
    end
  elseif args[3] == "spoilers" then
    if args[4] == nil then
      data.automod.spoilers.enabled = not data.automod.spoilers.enabled
      return {success = true, msg = "**"..(data.automod.spoilers.enabled and "Enabled" or "Disabled").."** the **spoilers** filter."}
    elseif tonumber(args[4]) == nil then
      return {success = false, msg = "You must provide a neumerical spoiler limit in argument 4."}
    elseif tonumber(args[4]) < 1 then
      return {success = false, msg = "The spoiler limit must be greater than or equal to 1."}
    else
      data.automod.spoilers.limit = tonumber(args[4])
      return {success = true, msg = "Set the **spoiler limit** to **"..args[4].."**."}
    end
  elseif args[3] == "mentions" then
    if args[4] == nil then
      data.automod.mentions.enabled = not data.automod.mentions.enabled
      return {success = true, msg = "**"..(data.automod.mentions.enabled and "Enabled" or "Disabled").."** the **mass-mentions** filter."}
    elseif tonumber(args[4]) == nil then
      return {success = false, msg = "You must provide a neumerical mention limit in argument 4."}
    elseif tonumber(args[4]) < 1 then
      return {success = false, msg = "The mention limit must be greater than or equal to 1."}
    else
      data.automod.mentions.limit = tonumber(args[4])
      return {success = true, msg = "Set the **mention limit** to **"..args[4].."**."}
    end
  elseif args[3] == "filter" then
    local found
    for _,items in pairs(data.automod.words.terms) do if items:lower() == table.concat(args[4]," "):lower() then found = true b
  else
    message:reply{embed = {
      title = "Moderation Settings",
      description = "To edit a setting in the general plugin, say **?"..args[1].." "..args[2].." <setting name> <new value>**",
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