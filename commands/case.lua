command = {}

local config = require("/app/config.lua")
local cache = require("/app/server.lua")

command.info = {
  Name = "Case",
  Alias = {},
  Usage = "case <case number>",
  Description = "View information on a specific case.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if args[2] == nil then
    return {success = false, msg = "You must provide a **case number** in argument 2."}
  elseif tonumber(args[2]) == nil then
    return {success = false, msg = "Argument 2 must be a **number**."}
  elseif data.modData.cases[tonumber(args[2])] == nil then
    return {success = false, msg = "**Case "..args[2].."** doesn't exist."}
  else
    local case = data.modData.cases[tonumber(args[2])]
    if string.lower(case.type) == "warn" then
      message:reply{embed = {
        title = "Warning - Case "..args[2],
        fields = {
          {
            name = "Member",
            value = client:getUser(case.user).tag.." (`"..case.user.."`)",
            inline = true,
          },
          {
            name = "Reason",
            value = case.reason,
            inline = true,
          },
          {
            name = "Responsible Moderator",
            value = client:getUser(case.moderator).tag.." (`"..case.moderator.."`)",
            inline = false,
          },
        },
        footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
        color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
      }}
      return {success = "stfu", message = ""}
    elseif string.lower(case.type) == "kick" then
      message:reply{embed = {
        title = "Kick - Case "..args[2],
        fields = {
          {
            name = "Member",
            value = client:getUser(case.user).tag.." (`"..case.user.."`)",
            inline = true,
          },
          {
            name = "Reason",
            value = case.reason,
            inline = true,
          },
          {
            name = "Responsible Moderator",
            value = client:getUser(case.moderator).tag.." (`"..case.moderator.."`)",
            inline = false,
          },
        },
        footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
        color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
      }}
      return {success = "stfu", message = ""}
    elseif string.lower(case.type) == "mute" then
      message:reply{embed = {
        title = "Mute - Case "..args[2],
        fields = {
          {
            name = "Member",
            value = client:getUser(case.user).tag.." (`"..case.user.."`)",
            inline = false,
          },
          {
            name = "Reason",
            value = case.reason,
            inline = true,
          },
          {
            name = "Duration",
            value = case.duration,
            inline = true,
          },
          {
            name = "Responsible Moderator",
            value = client:getUser(case.moderator).tag.." (`"..case.moderator.."`)",
            inline = false,
          },
        },
        footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
        color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
      }}
      return {success = "stfu", message = ""}
    elseif string.lower(case.type) == "auto unmute" then
      message:reply{embed = {
        title = "Auto Unmute - Case "..args[2],
        fields = {
          {
            name = "Member",
            value = client:getUser(case.user).tag.." (`"..case.user.."`)",
            inline = true,
          },
          {
            name = "Reason",
            value = case.reason,
            inline = true,
          },
          {
            name = "Responsible Moderator",
            value = client:getUser(case.moderator).tag.." (`"..case.moderator.."`)",
            inline = false,
          },
        },
        footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
        color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
      }}
      return {success = "stfu", message = ""}
    elseif string.lower(case.type) == "ban" then
      message:reply{embed = {
        title = "Ban - Case "..args[2],
        fields = {
          {
            name = "Member",
            value = client:getUser(case.user).tag.." (`"..case.user.."`)",
            inline = false,
          },
          {
            name = "Reason",
            value = case.reason,
            inline = true,
          },
          {
            name = "Duration",
            value = case.duration,
            inline = true,
          },
          {
            name = "Responsible Moderator",
            value = client:getUser(case.moderator).tag.." (`"..case.moderator.."`)",
            inline = false,
          },
        },
        footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
        color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
      }}
      return {success = "stfu", message = ""} 
    elseif string.lower(case.type) == "auto unban" then
      message:reply{embed = {
        title = "Auto Unban - Case "..args[2],
        fields = {
          {
            name = "Member",
            value = client:getUser(case.user).tag.." (`"..case.user.."`)",
            inline = true,
          },
          {
            name = "Reason",
            value = case.reason,
            inline = true,
          },
          {
            name = "Responsible Moderator",
            value = client:getUser(case.moderator).tag.." (`"..case.moderator.."`)",
            inline = false,
          },
        },
        footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
        color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
      }}
      return {success = "stfu", message = ""}
    else
      return {success = false, msg = "**Case "..args[2].."** couldn't be displayed."}
    end
  end
end

return command