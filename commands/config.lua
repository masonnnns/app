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
  if args[2] == nil then
    message:reply{embed = {
      title = "AA-R0N Config Help",
      description = "Learn how to use AA-R0N's configuration system here.\n**Setting Name:** Setting Description",
      fields = {
        {
          name = "General Settings",
          value = "To edit settings in this category, use **"..data.prefix.."config <setting name>**\n**Mod-Only:** Limits commands to moderators+ only.\n**DelCmd:** Delete the command invocation message.\n**Auditlog:** The channel where server audits are sent.\n**Modlog:** The channel where moderation actions are sent.\n**Modrole:** The role that designates people as moderators.",
          inline = false,
        }
      },
      color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
    }}
    return {success = "stfu", msg = ""}
  end 
end

return command