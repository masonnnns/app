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
  if args[2] then args[2] = args[2]:lower() end
  if args[2] == nil then
    message:reply{embed = {
      title = "AA-R0N Config Help",
      description = "To view how to configure a specific plugin say **"..data.prefix.."config <plugin name>** or say **"..data.prefix.."config view** to view the current settings.",
      fields = {
        {
					name = "General Settings",
					value = "**ModOnly:** Makes commands restricted to server moderators and higher.\n**DelCmd:** Deletes the command invocation message.\n**Auditlog:** A channel where changes in the server are audited.\n**Modlog:** A channel where moderation actions are audited.\n**Modrole:** A role that declares the moderators of the server.",
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
  end 
end

return command