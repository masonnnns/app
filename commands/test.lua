command = {}

local config = require("/app/config.lua")
local utils = require("/app/resolve-user.lua")
local pages = require("/app/pageination.lua")

command.info = {
  Name = "test",
  Alias = {},
  Usage = "test",
  Category = "Private",
  Description = "test",
  PermLvl = 5,
}

-- message,pageTable,user

command.execute = function(message,args,client)
  local page = {
    {title = "xd"},
    {title = "lol"}
  }
  print(#page)
  pages.addDictionary(message,page,message.author.id)
  return {success = true, msg = "xd"}
end

-- <:aaronlock:678918427523678208>

return command