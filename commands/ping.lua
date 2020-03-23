command = {}

local function parse(num)
num = math.max(num)
num = tostring(num)
print(num)
local pos, tables, done = 1, {}, false
repeat
    if string.sub(num,pos) ~= "." then tables[pos] = string.sub(num,pos) pos = pos+1 else done = true end
    require("timer").sleep(250)
until pos >= string.len(num) or done == true
  num = table.concat(tables,"")
  print(num)
  return num
end

command.info = {
  Name = "Ping",
  Alias = {},
  Usage = "ping",
  Category = "Information",
  Description = "Test AA-R0N's connection to Discord.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  local m = message:reply(":ping_pong: Ping")
  if m == nil then return {success = "stfu"} end
  local latency = require("discordia").Date.fromISO(m.timestamp):toMilliseconds() - require("discordia").Date.fromISO(message.timestamp):toMilliseconds()
  m:setContent(":ping_pong: Ping? `"..parse(latency).."ms`")
  local edited = require("discordia").Date.fromISO(m.editedTimestamp):toMilliseconds() - require("discordia").Date.fromISO(m.timestamp):toMilliseconds()
  latency = latency + edited
  m:setContent(":ping_pong: Pong! `"..parse(latency).."ms`")
  return {success = "stfu", msg = "PONG!!", emote = ":ping_pong:"}
end

return command