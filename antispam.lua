local authors = {}
local banned = {}
local warned = {}
local messageLog = {}

local warnBuffer = 3
local maxDuplicatesWarning = 5
local interval = 5050

local module = {}

module = function(message)
  local now = os.time()
  authors[1+#authors] = {time = now, author = message.author.id}
  messageLog[1+#messageLog] = {time = now, author = message.author.id, message = message.content, id = message.id}
  
  if #messageLog > 200 then messageLog = {} end --// Let's not kill glith's RAM.
  
  for a,items in pairs(messageLog) do
    print(now,items.time + 5)
    if now >= items.time + 5 then
      table.remove(messageLog,a) --// Get rid of old messages to prevent false warnings.
    end
  end
  
  for a,items in pairs(authors) do
    if now >= items.time + 5 then
      table.remove(messageLog,a) --// Get rid of old messages to prevent false warnings.
    end
  end

  --// Check how many times the same message has been sent.
  local msgMatch = 0
  for a,items in pairs(messageLog) do
    if items.message:lower() == message.content and items.author == message.author.id and message.author.id ~= 414030463792054282 and message.channel:getMessage(items.id) then
      msgMatch = msgMatch + 1
    end
  end
  
  --// Check if we found an infraction
  if msgMatch >= maxDuplicatesWarning then
    return {safe = false, reason = "Sending "..msgMatch.." of the same message in five seconds."}
  end

  local matched = 0
  for a,items in pairs(authors) do
    if items.time > now - interval then
      matched = matched + 1
      if matched >= warnBuffer then
        return {safe = false, reason = "Sent "..matched.." messages in five seconds."}
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