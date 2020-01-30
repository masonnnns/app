command = {}

command.info = {
  Name = "Restart",
  Alias = {},
  Example = "restart",
  Description = "restart the bot.",
  PermLvl = 5,
}

command.execute = function(message,config)
  
  return {success = "stfu", msg = "console", emote = ":ping_pong:"}
end

return command