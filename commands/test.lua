command = {}

command.info = {
  Name = "Test",
  Alias = {},
  Example = "test",
  Description = "test.",
  PermLvl = 5,
}

command.execute = function(message,config)
  local module = require("././config.lua")
  print(module)
  return {success = true, msg = "!", emote = ":ping_pong:"}
end

return command