command = {}

command.info = {
  Name = "Config",
  Alias = {},
  Usage = "config <setting/plugin> <path/newvalue> <new value>",
  Description = "Edit AA-R0N's configuation in your server.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  local m = message:reply(":ping_pong: Ping?")
  local latency = m.createdAt - message.createdAt
  m:setContent(":ping_pong: Pong! `"..math.max(latency).."ms`")
  return {success = "stfu", msg = "PONG!!", emote = ":ping_pong:"}
end

return command