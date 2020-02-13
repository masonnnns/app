command = {}

local blacklists = require("/app/blacklist.lua")

command.info = {
  Name = "Blacklist",
  Alias = {},
  Usage = "blacklist <id> <reason>",
  Category = "Private",
  Description = "Blacklist the specified user.",
  PermLvl = 5,
}

command.execute = function(message,args,client)
  if bl
end

return command