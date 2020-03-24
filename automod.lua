plugin = {}

local timer = require("timer")

local infractions = {}
-- infractions[GUILDID..USERID] = {1, 2, 3}

local function strike(message,data)
  local id = message.guild.id..message.author.id
  if infractions[id] == nil then infractions[id] = {} infractions[id][1] = os.time() return true end
  infractions[id][1+#infractions[id]] = os.time()
  local ten, thirty, hour = 0, 0, 0
  if #infractions[id] >= 3 then
    for _,items in pairs(infractions[id]) do
      if items + 600 >= os.time() then ten = ten + 1 end
      if items + 
    end
  end
end

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