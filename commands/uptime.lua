command = {}

local utils = require("/app/utils.lua")
local cache = require("/app/server.lua")

command.info = {
  Name = "Uptime",
  Alias = {"up"},
  Usage = "uptime",
  Category = "Information",
  Description = "Shows how long the bot has been online.",
  PermLvl = 0,
}

local start = os.time()

command.execute = function(message,args,client)
    message:reply{embed = {
      title = "Uptime",
      description = utils.getTimeString(os.time() - start)..".",
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
      color = (message.member:getColor() == 0 and 3066993 or message.member:getColor().value),
    }}
  return {success = "stfu", msg = "PONG!!", emote = ":ping_pong:"}
end

return command