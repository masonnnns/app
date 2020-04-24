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
  client:emit("infoCmd","uptime",message)
  return {success = "stfu", msg = "PONG!!", emote = ":ping_pong:"}
end

return command