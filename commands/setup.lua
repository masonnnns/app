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
        {name = "Moderator Role", value = (data.modrole == "nil" and "Disabled." or (message.guild:getRole(data.mutedrole) == nil and "Disabled" or message.guild:getRole(data.mutedrole).mentionString)), inline = true},
      },
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
      color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
    }
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