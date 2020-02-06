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
    description = "lol"
  }}
  local msg = message:reply(data)
  dictionary.addDictionary(msg,{data,{title = "2/2", description = "ok"}}, message.author.id)
  msg:addReaction(":arrow_left:")
  msg:addReaction(":arrow_right:")
  return {success = "stfu"}
end

return command