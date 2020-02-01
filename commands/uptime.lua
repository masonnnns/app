command = {}

local uptimeOS = os.time()
local utils = require("/app/utils.lua")

command.info = {
  Name = "Uptime",
  Alias = {"up"},
  Usage = "uptime",
  Description = "Shows how long the bot has been online.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  message:reply{embed = {
      title = "**Uptime**",
      description = utils.getTimeString(os.time() - uptimeOS)..".",
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
      color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
    }}
  return {success = "stfu", msg = "PONG!!", emote = ":ping_pong:"}
end

return command