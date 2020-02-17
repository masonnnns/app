command = {}

local config = require("/app/config.lua")
local utils = require("/app/resolve-user.lua")
local pages = reuqire("/app/pageination.lua")

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
  pages.addDictionary(message,{embed = })
  return {success = true, msg = "xd"}
end

-- <:aaronlock:678918427523678208>

return command