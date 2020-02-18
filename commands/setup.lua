command = {}

local config = require("/app/config.lua")
local utils = require("/app/resolve-user.lua")
local cache = require("/app/server.lua")
local page = require("/app/pageination.lua")

command.info = {
  Name = "Setup",
  Alias = {},
  Usage = "config <setting/plugin> <path/new value> <new value>",
  Category = "Private",
  Description = "Edit AA-R0N's configuation in your server.",
  PermLvl = 5,
}

local usersPage = {} -- [ID..GUILDID] = "PAGE NAME"

command.execute = function(message,args,client)
  if message.author.id ~= client.owner.id then return {success = "stfu"} end
  local data = config.getConfig(message.guild.id)
  if args[2] ~= nil then args[2] = args[2]:lower() end
  if args[2] == nil then
    local pages = {}
    pages[1] = {
      title = "General Settings",
      description = "Confused? Say **"..data.prefix.."config help** for information on how to use this system.",
      fields = {
        {name = "Command Prefix", value = data.prefix, inline = true},
        {name = "Delete Invocation Message", value = (data.deletecmd and "Enabled." or "Disabled."), inline = true},
        {name = "Mod Only Commands", value = (data.modonly and "Enabled." or "Disabled."), inline = true},
        {name = "Audit Log", value = (data.auditlog == "nil" and "Disabled." or (message.guild:getChannel(data.auditlog) == nil and "Disabled." or message.guild:getChannel(data.auditlog).mentionString)), inline = true},
        {name = "Muted Role", value = (data.mutedrole == "nil" and "Disabled." or (message.guild:getRole(data.mutedrole) == nil and "Disabled" or message.guild:getRole(data.mutedrole).mentionString)), inline = true},
        {name = "Moderation Log", value = (data.modlog == "nil" and "Disabled." or (message.guild:getChannel(data.modlog) == nil and "Disabled." or message.guild:getChannel(data.modlog).mentionString)), inline = true},
        {name = "Moderator Role", value = (data.modrole == "nil" and "Disabled." or (message.guild:getRole(data.modrole) == nil and "Disabled" or message.guild:getRole(data.modrole).mentionString)), inline = true},
      },
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
      color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
    }
    pages[2] = {
      title = "Tag Plugin Settings",
      fields = {
        {name = "Delete Invocation Message", value = (data.tags.delete and "Enabled." or "Disabled."), inline = true},
        {name = "Commands in Plugin", value = ">>> **?tag**\n**?tags**", inline = false},
      },
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
      color = (data.tags.enabled and 3066993 or 15158332)
    }
    pages[3] = {
      title = "Automod Plugin Settings",
      fields = {
        {name = "Infraction Log", value = (data.automod.log == nil and "Disabled." or (message.guild:getChannel(data.automod.log) == nil and "Disabled." or message.guild:getChannel(data.automod.log).mentionString)), inline = false},
        {name = "Invites Filter", value = (data.automod.types.invites[1] and "Enabled." or "Disabled."), inline = true},
        {name = "Mass-Mention Filter", value = (data.automod.types.mentions[1] and "Enabled. (Limit: "..data.automod.types.mentions[2].."/msg)" or "Disabled."), inline = true},
        {name = "Spoilers Filter", value = (data.automod.types.spoilers[1] and "Enabled. (Limit: "..data.automod.types.spoilers[2].."/msg)" or "Disabled."), inline = true},
        {name = "Newline Filter", value = (data.automod.types.newline[1] and "Enabled. (Limit: "..data.automod.types.newline[2].."/msg)" or "Disabled."), inline = true},
        {name = "Words Filter", value = (data.automod.types.filter[1] and "Enabled." or "Disabled."), inline = true},
        {name = "Spam Filter", value = (data.automod.types.spam[1] and "Enabled." or "Disabled."), inline = true},
      },
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
      color = (data.automod.enabled and 3066993 or 15158332)
    }
    pages[4] = {
      title = "Welcome Plugin Settings",
      fields = {
        {name = "Join Message Channel", value = (data.welcome.joinchannel == nil and "Disabled." or (message.guild:getChannel(data.welcome.joinchannel) == nil and "Disabled." or message.guild:getChannel(data.welcome.joinchannel).mentionString)), inline = true},
        {name = "Auto Role", value = (data.welcome.autorole == "nil" and "Disabled." or (message.guild:getRole(data.welcome.autorole) == nil and "Disabled" or message.guild:getRole(data.welcome.autorole).mentionString)), inline = true},
        {name = "Leave Message Channel", value = (data.welcome.leavechannel == nil and "Disabled." or (message.guild:getChannel(data.welcome.leavechannel) == nil and "Disabled." or message.guild:getChannel(data.welcome.leavechannel).mentionString)), inline = true},
      },
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
      color = (data.automod.enabled and 3066993 or 15158332)
    }
    if data.tags.enabled == false then pages[2].fields = nil pages[2].description = "This plugin is disabled. Say **"..data.prefix.."config toggle** to enable it." end
    if data.automod.enabled == false then pages[3].fields = nil pages[3].description = "This plugin is disabled. Say **"..data.prefix.."config toggle** to enable it." end
    if data.welcome.enabled then
      if pages[4].fields[1].value ~= "Disabled." then
        pages[4].fields[1+#pages[4].fields] = {name = "Join Message", value = data.welcome.joinmsg, inline = false}
      end
      if pages[4].fields[3].value ~= "Disabled." then
        pages[4].fields[1+#pages[4].fields] = {name = "Leave Message", value = data.welcome.leavemsg, inline = false}
      end
    else
      pages[4].fields = nil
      pages[4].description = "This plugin is disabled. Say **"..data.prefix.."**config toggle** to enable it."
    end
    page.addDictionary(message,pages,message.author.id)
    return {success = "stfu"}
  elseif args[2] == "help" then
    message:reply{embed = {
      title = "AA-R0N Configuration",
      description = "To begin editing the configuration of AA-R0N, say **"..data.prefix.."config**. (more of a tutorial here)",
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
      color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
    }}
    return {success = "stfu"}
  end
end

return command