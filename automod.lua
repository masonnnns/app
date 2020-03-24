plugin = {}

local timer = require("timer")

local function addInfraction()

local infractions = {}
-- infractions[GUILDID..USERID] = {1, 2, 3}

plugin = function(message, data, client)
  local a, b = string.gsub(message.content,"\n","")
  local c, d = string.gsub(message.content,"||","")
  if data.automod.newline.enabled and b + 1 > data.automod.newline.limit then
    message:delete()
    local reply = message:reply(message.author.mentionString..", too many newlines.")
    timer.sleep(3000)
    reply:delete()
    
  end
end

return plugin