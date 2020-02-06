command = {}

local dictionary = require("/app/pageination.lua")

command.info = {
  Name = "Test",
  Alias = {},
  Usage = "test",
  Description = "test.",
  PermLvl = 5,
}

command.execute = function(message,args,client)
  local data = {embed = {
    title = "xd",
    description = "lol",
  }},
  message:reply(data)
  dictionary.addDictionary(message,{data,{embed = {title = "2/2", description = "ok"}}})
  return {success = "stfu"}
end

return command