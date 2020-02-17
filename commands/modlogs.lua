command = {}

local config = require("/app/config.lua")
local utils = require("/app/resolve-user.lua")
local pages = require("/app/pageination.lua")

command.info = {
  Name = "Modlogs",
  Alias = {"mlogs"},
  Usage = "modlog <user>",
  Category = "Moderation",
  Description = "View all the modlogs of a user.",
  PermLvl = 1,
}

-- message,pageTable,user

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  local page = {}
  pages.addDictionary(message,page,message.author.id)
  return {success = true, msg = "xd"}
end

-- <:aaronlock:678918427523678208>

return command