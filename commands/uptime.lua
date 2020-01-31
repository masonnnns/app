command = {}

local startOS = os.time()

command.info = {
  Name = "Uptime",
  Alias = {"up"},
  Example = "uptime",
  Description = "Shows how long the bot has been online.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  local m = message:reply(":ping_pong: Ping?")
  local latency = m.createdAt - message.createdAt
  m:setContent(":ping_pong: Pong! `"..math.max(latency).."ms`")
  return {success = "stfu", msg = "PONG!!", emote = ":ping_pong:"}
end

return command