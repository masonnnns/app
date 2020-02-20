command = {}

command.info = {
  Name = "Ping",
  Alias = {},
  Usage = "ping",
  Category = "Information",
  Description = "Test AA-R0N's connection to Discord.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  local m = message:reply(":ping_pong: Ping?")
  if m == nil then return {success = "stfu"} end
  local latency = m.createdAt - message.createdAt
  m:setContent(":ping_pong: Pong! `"..math.max(latency).."ms`")
  return {success = "stfu", msg = "PONG!!", emote = ":ping_pong:"}
end

return command