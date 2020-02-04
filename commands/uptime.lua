command = {}

local utils = require("/app/utils.lua")
local cache = require("/app/server.lua")

command.info = {
  Name = "Uptime",
  Alias = {"up"},
  Usage = "uptime",
  Description = "Shows how long the bot has been online.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  message:reply{embed = {
      title = "Uptime",
      description = utils.getTimeString(os.time() - cache.getCache("ostime"))..".",
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
        color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
    }}
  return {success = "stfu", msg = "PONG!!", emote = ":ping_pong:"}
end

return command