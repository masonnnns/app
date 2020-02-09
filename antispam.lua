local authors = {}
local banned = {}
local warned = {}
local messageLog = {}

local warnBuffer = 5
local maxDuplicatesWarning = 5
local interval = 5050

local module = {}

module = function(message)
  local now = os.time()
  print("now",now)
  authors[1+#authors] = {time = now, author = message.author.id, id = message.id}
  messageLog[1+#messageLog] = {time = now, author = message.author.id, message = message.content, id = message.id}
  
  if #messageLog > 200 then messageLog = {} end --// Let's not kill glith's RAM.
  
  for a,items in pairs(messageLog) do
    if now == false or now >= items.time + 7 then
      table.remove(messageLog,a) --// Get rid of old messages to prevent false warnings.
    end
  end
  
  for a,items in pairs(authors) do
    if now == false or now >= items.time + 3 then
      table.remove(authors,a) --// Get rid of old messages to prevent false warnings.
    end
  end

  --// Check how many times the same message has been sent.
  local msgMatch = {}
  for a,items in pairs(messageLog) do
    if items.message:lower() == message.content:lower() and items.id ~= message.id and items.author == message.author.id and message.author.id ~= 414030463792054282 and message.channel:getMessage(items.id) then
      msgMatch[1+#msgMatch] = items.id
    end
  end
  
  --// Check if we found an infraction
  if #msgMatch >= maxDuplicatesWarning then
    for a,items in pairs(messageLog) do if items.author == message.author.id then table.remove(messageLog,a) end end
    for b,c in pairs(authors) do if c.author == message.author.id then table.remove(authors,b) end end
    return {safe = false, reason = "Sending "..#msgMatch.." of the same message in seven seconds.", messages = msgMatch}
  end

  local matched = {}
  for a,items in pairs(authors) do
    if items.time > now - interval and now ~= false then
      print("strike!",#matched + 1)
      matched[1+#matched] = items.id
      if #matched >= warnBuffer then
        for b,c in pairs(authors) do if c.author == message.author.id then table.remove(authors,b) print(c,"removed") end end
        for d,items in pairs(messageLog) do if items.author == message.author.id then table.remove(messageLog,d) end end
        return {safe = false, reason = "Sent "..#matched.." messages in three seconds.", messages = matched}
      end
    elseif items.time < now - interval then
      table.remove(authors,a)
    end
  end
    
  local raid = 0
  for a,items in pairs(authors) do
    if items.time > now - 6000 then
      if raid >= 4 then
        print('raid =')
        return {safe = false, reason = "Sent "..raid.." messages in six seconds."}
      end
    else
      table.remove(authors,a)
    end
  end

  return {safe = true}

end

return module