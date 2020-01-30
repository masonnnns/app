command = {}

command.info = {
  Name = "Ping",
  Alias = {},
  Example = "ping"
  Description = "Test AA-R0N's connection to Discord.",
  PermLvl = 0,
}

command.execute = function(message,config)
  local m = message:reply(":ping_pong: Ping?")
  local latency = m.createdAt - message.createdAt
  m:setContent(":ping_pong: Pong! `"..math.max(latency).."ms`")
  return {success = "stfu", msg = "PONG!!", emote = ":ping_pong:"}
end

return command