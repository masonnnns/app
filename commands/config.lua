command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")

command.info = {
  Name = "Config",
  Alias = {"settings","setup"},
  Usage = "config <plugin/start> (setting name) (new value)",
  Category = "Administration",
  Description = "Configure AA-R0N in your server.",
  PermLvl = 2,
  Cooldown = 5,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if args[2] ~= nil then args[2] = args[2]:lower() end
  if args[2] == "start" and message.author.id == client.owenr.id then
    require("/app/prompts.lua").startPrompt(message,"config")
    return {success = "stfu"}
  elseif args[2] == "general" then
    local xd = require("/app/commands/configcmds/general.lua")(message,args,client,data)
    return xd
  elseif args[2] == "welcome" then
    if data.welcome.enabled == false and args[3]:lower() ~= "toggle" then return {success = false, msg = "This plugin is disabled, enable it to edit it's settings."} end
    local xd = require("/app/commands/configcmds/welcome.lua")(message,args,client,data)
    return xd
  elseif args[2] == "moderation" then
    local xd = require("/app/commands/configcmds/moderation.lua")(message,args,client,data)
    return xd
  elseif args[2] == "automod" then
    if data.automod.enabled == false and args[3]:lower() ~= "toggle" then return {success = false, msg = "This plugin is disabled, enable it to edit it's settings."} end
    local xd = require("/app/commands/configcmds/automod.lua")(message,args,client,data)
    return xd
  elseif args[2] == "tags" then
    if data.tags.enabled == false and args[3]:lower() ~= "toggle" then return {success = false, msg = "This plugin is disabled, enable it to edit it's settings."} end
    local xd = require("/app/commands/configcmds/tags.lua")(message,args,client,data)
    return xd
  elseif args[2] == "nolock" then
    data.general.funlock = not data.general.funlock
    return {success = true, msg = "**"..(data.general.funlock and "Enabled" or "Disabled").."** the NSFW Channel lock on fun commands."}
  else
    local pages = {}
    pages[1] = {
      title = "General Settings",
      description = "To edit a setting in this plugin, say **"..data.general.prefix..args[1].." general**.",
      fields = {
        {name = "Command Prefix", value = data.general.prefix, inline = true},
        {name = "Delete Invocation Message", value = (data.general.delcmd and "Enabled." or "Disabled."), inline = true},
        {name = "Audit Log", value = (data.general.auditlog == "nil" and "Disabled." or (message.guild:getChannel(data.general.auditlog) == nil and "Disabled." or message.guild:getChannel(data.general.auditlog).mentionString)), inline = true},
        {name = "Audit Ignored Channels [0]", value = "", inline = false},
      },
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = (message.member:getColor() == 0 and 3066993 or message.member:getColor().value),
    }
    local num = 0
    for _,items in pairs(data.general.auditignore) do local role = message.guild:getChannel(items) if role then num = num + 1 if pages[1].fields[4].value == "" then pages[1].fields[4].value = role.mentionString else pages[1].fields[4].value = pages[1].fields[4].value..", "..role.mentionString end end end
    pages[1].fields[4].name = "Audit Ignored Channels ["..num.."]"
    if num == 0 then pages[1].fields[4].value = "None set!" end
    pages[2] = {
      title = "Moderation Settings",
      description = "To edit a setting in this plugin, say **"..data.general.prefix..args[1].." moderation**.",
      fields = {
        {name = "Mod Only Commands", value = (data.general.modonly and "Enabled." or "Disabled."), inline = true},
        {name = "Muted Role", value = "Not Configured.", inline = true},
        {name = "Moderation Log", value = "Not Configured.", inline = true},
        {name = "Moderator Roles", value = "Not Configured.", inline = false},
      },
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = (message.member:getColor() == 0 and 3066993 or message.member:getColor().value),
    }
    if data.general.modlog ~= "nil" and message.guild:getChannel(data.general.modlog) ~= nil then pages[2].fields[3].value = message.guild:getChannel(data.general.modlog).mentionString end
    if data.general.mutedrole ~= "nil" and message.guild:getRole(data.general.mutedrole) ~= nil then pages[2].fields[2].value = message.guild:getRole(data.general.mutedrole).mentionString end
    local modRoles = {}
    for _,items in pairs(data.general.modroles) do local role = message.guild:getRole(items) if role ~= nil then modRoles[1+#modRoles] = role.mentionString end end
    if #modRoles >= 1 then pages[2].fields[4].value = table.concat(modRoles," ") end
    if #modRoles == 1 then pages[2].fields[4].name = "Moderator Role [1]" else pages[2].fields[4].name = "Moderator Roles ["..#modRoles.."]" end
    pages[3] = {
      title = "Automod Settings",
      description = "To edit a setting in this plugin, say **"..data.general.prefix..args[1].." automod**.",
      fields = {
        {name = "Automod Log", value = "Not Configured.", inline = false},
        {name = "Anti-Spam", value = (data.automod.spam.enabled and "Enabled." or "Disabled."), inline = true},
        {name = "Anti-Invites", value = (data.automod.invites.enabled and "Enabled." or "Disabled."), inline = true},
        {name = "Words Filter", value = (data.automod.words.enabled and "Enabled." or "Disabled."), inline = true},
        {name = "Newline Filter", value = (data.automod.newline.enabled and "Enabled. ("..data.automod.newline.limit.."/msg)" or "Disabled."), inline = true},
        {name = "Spoiler Filter", value = (data.automod.spoilers.enabled and "Enabled. ("..data.automod.spoilers.limit.."/msg)" or "Disabled."), inline = true},
        {name = "Mass-Mentions Filter", value = (data.automod.mentions.enabled and "Enabled. ("..data.automod.mentions.limit.."/msg)" or "Disabled."), inline = true},
        {name = "Filtered Terms ["..#data.automod.words.terms.."]", value = "||"..table.concat(data.automod.words.terms,", ").."||", inline = false}
      },
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = (message.member:getColor() == 0 and 3066993 or message.member:getColor().value),
    }
    if data.automod.log ~= "nil" and message.guild:getChannel(data.automod.log) ~= nil then pages[3].fields[1].value = message.guild:getChannel(data.automod.log).mentionString end
    if data.automod.enabled == false then pages[3].description = "This plugin is disabled, say  **"..data.general.prefix..args[1].." automod toggle** to enable it." pages[3].fields = nil pages[3].color = 15158332 end
    pages[4] = {
      title = "Welcome Settings",
      description = "To edit a setting in this plugin, say **"..data.general.prefix..args[1].." welcome**.",
      fields = {
        {name = "Join Channel", value = "Not Configured.", inline = true},
        {name = "Leave Channel", value = "Not Configured.", inline = true},
        {name = "Join Message", value = "```"..data.welcome.join.msg.."```", inline = false},
        {name = "Leave Message", value = "```"..data.welcome.leave.msg.."```", inline = false},
        {name = "Autorole [0]", value = "Not Configured.", inline = false},
      },
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = (message.member:getColor() == 0 and 3066993 or message.member:getColor().value),
    }
    if data.welcome.join.channel ~= "nil" and message.guild:getChannel(data.welcome.join.channel) ~= nil then pages[4].fields[1].value = message.guild:getChannel(data.welcome.join.channel).mentionString end
    if data.welcome.leave.channel ~= "nil" and message.guild:getChannel(data.welcome.leave.channel) ~= nil then pages[4].fields[2].value = message.guild:getChannel(data.welcome.leave.channel).mentionString end
    local tble = {}
    for _,items in pairs(data.welcome.autorole) do
      if message.guild.roles:get(items) ~= nil then
        tble[1+#tble] = message.guild.roles:get(items).mentionString
      end
    end
    if #tble >= 1 then pages[4].fields[5].value = table.concat(tble," ") pages[4].fields[5].name = "Autorole ["..#tble.."]" end
    if data.welcome.join.msg == "nil" or pages[4].fields[1].value == "Not Configured." then table.remove(pages[4].fields,3) end
    if data.welcome.leave.msg == "nil" or pages[4].fields[2].value == "Not Configured." then table.remove(pages[4].fields,#pages[4].fields-1) end
    if data.welcome.enabled == false then pages[4].description = "This plugin is disabled, say  **"..data.general.prefix..args[1].." welcome toggle** to enable it." pages[4].fields = nil pages[4].color = 15158332 end
    pages[5] = {
      title = "Tags Settings",
      description = "To edit a setting in this plugin, say **"..data.general.prefix..args[1].." tags**.",
      fields = {
        {name = "Amount of Tags", value = #data.tags.tags, inline = true},
        {name = "Delete Command", value = (data.tags.delete and "Enabled." or "Disabled."), inline = true},
      },
    }
    if data.tags.enabled == false then pages[5].description = "This plugin is disabled, say  **"..data.general.prefix..args[1].." tags toggle** to enable it." pages[5].fields = nil pages[5].color = 15158332 end
    require("/app/pages.lua").addDictionary(message,pages,message.author.id)
  end
  return {success = "stfu"}
end

return command