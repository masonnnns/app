command = {}

local utils = require("/app/utils.lua")
local cache = require("/app/server.lua")

command.info = {
  Name = "Info",
  Alias = {"stats"},
  Usage = "info",
  Category = "Information",
  Description = "Shows information about AA-R0N.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  client:emit("infoCmd","info",message)
  return {success = "stfu", msg = "PONG!!", emote = ":ping_pong:"}
end

return command