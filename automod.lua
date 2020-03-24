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
      if items + 1800 >= os.time() then thirty = thirty + 1 end
      if items + 3600 >= os.time() then hour = hour + 1 end
      if items + 3600 < os.time() then table.remove(infractions[id],_) end
    end
  end
  if hour >= 13 then --// we're just going to start kicking them
    return false
  elseif hour == 10 then
    return false
  elseif thirty == 7 then
    return false
  elseif ten == 3 then
    return false
  else
    return true
  end
end

plugin = function(message, data, client)
  local a, b = string.gsub(message.content,"\n","")
  local c, d = string.gsub(message.content,"||","")
  if data.automod.newline.enabled and b + 1 > data.automod.newline.limit then
    message:delete()
    if strike(message,data) == true then
      local reply = message:reply(message.author.mentionString..", too many newlines.")
      timer.sleep(3000)
      reply:delete()
    end
  end
end

return plugin