command = {}

local dictionary = require("/app/pageination.lua")

command.info = {
  Name = "Test",
  Alias = {},
  Usage = "test",
  Category = "Private",
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
  local emoji = message.guild.emojis:find(function(e) return e.name == 'Lua' end)
  message:addReaction("👍")
  msg:addReaction("👍")
  return {success = "stfu"}
end

return command