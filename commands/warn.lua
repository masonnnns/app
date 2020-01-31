command = {}

command.info = {
  Name = "Warn",
  Alias = {},
  Example = "warn <user> <reason>",
  Description = "Issue a warning to a specified user.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  local m = message:reply(":ping_pong: Ping?")
  local latency = m.createdAt - message.createdAt
  m:setContent(":ping_pong: Pong! `"..math.max(latency).."ms`")
  return {success = "stfu", msg = "PONG!!", emote = ":ping_pong:"}
end

return command