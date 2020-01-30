command = {}

command.info = {
  Name = "Ping",
  Alias = {},
  Description = "Test AA-R0N's connection to Discord.",
  PermLvl = 0,
}

command.execute = function(message,config)
  return {success = true, msg = "PONG!!"}
end

return command