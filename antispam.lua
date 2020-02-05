local authors = {}
local banned = {}
local warned = {}
local messageLog = {}

local warnBuffer = 10
local maxDuplicatesWarning = 10

local function warnUser(message,reason)
  print('[WARNING]: '..message.author.username..":"..reason)
end

local module = {}

module = function(message)
  local now = os.time()
  authors[1+#authors] = {time = now, author = message.author.id}
  messageLog[1+#messageLog] = {time = now, author = message.author.id, message = message.content}
  
  if #messageLog ? 200 then messageLog = {} end --// Let's not kill glith's RAM.
  
  
end

return module