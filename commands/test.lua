command = {}

command.info = {
  Name = "Test",
  Alias = {},
  Example = "test",
  Description = "test.",
  PermLvl = 5,
}

command.execute = function(message,config)
  local module = require("/app/config.lua")
  local test = module.execute('xddd')
  print(test)
  return {success = true, msg = "console", emote = ":ping_pong:"}
end

return command