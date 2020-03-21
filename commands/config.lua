command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")

command.info = {
  Name = "Config",
  Alias = {"settings","setup"},
  Usage = "config <plugin> (setting name) (new value)",
  Category = "Administration",
  Description = "Configure AA-R0N in your server.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if args[2] ~= nil then args[2] = args[2]:lower() end
  if args[2] == nil then
    local pages = {}
    pages[1] = {
      title = "General Settings",
      description = "To edit a setting in this plugin, say **"..data.general.prefix..args[1].." general**.",
      fields = {
        {name = "Command Prefix", value = data.general.prefix, inline = true},
        {name = "Delete Invocation Message", value = (data.general.delcmd and "Enabled." or "Disabled."), inline = true},
        {name = "Mod Only Commands", value = (data.general.modonly and "Enabled." or "Disabled."), inline = true},
        {name = "Audit Log", value = (data.general.auditlog == "nil" and "Disabled." or (message.guild:getChannel(data.general.auditlog) == nil and "Disabled." or message.guild:getChannel(data.general.auditlog).mentionString)), inline = true},
        {name = "Muted Role", value = (data.general.mutedrole == "nil" and "Disabled." or (message.guild:getRole(data.general.mutedrole) == nil and "Disabled." or message.guild:getRole(data.general.mutedrole).mentionString)), inline = true},
        {name = "Moderation Log", value = (data.general.modlog == "nil" and "Disabled." or (message.guild:getChannel(data.general.modlog) == nil and "Disabled." or message.guild:getChannel(data.general.modlog).mentionString)), inline = true},
        {name = "Moderator Roles [0]", value = "", inline = false},
        {name = "Audit Ignored Channels [0]", value = "s", inline = false},
      },
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
    }
    local num = 0
    for _,items in pairs(data.general.modroles) do local role = message.guild:getRole(items) if role then num = num + 1 if pages[1].fields[7].value == "" then pages[1].fields[7].value = role.mentionString else pages[1].fields[7].value = pages[1].fields[7].value..", "..role.mentionString end end end
    pages[1].fields[7].name = "Moderator Roles ["..num.."]"
    if num == 0 then pages[1].fields[7].value = "None set!" end
    require("/app/pages.lua").addDictionary(message,pages,message.author.id)
  end
  return {success = "stfu"}
end

return command