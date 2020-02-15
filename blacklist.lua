local json = require('json')
module = {}

module.getBlacklist = function(id)
  if io.open("./blacklist.txt","r"):read() == nil then return true end
  local decode = json.decode(io.open("./blacklist.txt","r"):read())
  if id == "*" then return decode end
  for a,b in pairs(decode) do
    if a == id then
      return b
    end
  end
  return true
end

module.blacklist = function(id,reason)
  local blacklists = {}
  local decode = (io.open("./blacklist.txt","r"):read() == nil and {} or json.decode(io.open("./blacklist.txt","r"):read()))
  for a,b in pairs(decode) do 
    blacklists[a] = b
  end
  blacklists[id] = {notified = false, reason = reason}
  file = io.open("./blacklist.txt", "w+") 
  file:write(json.encode(blacklists))
	file:close()
  return true
end

module.unblacklist = function(id,reason)
  local blacklists = {}
  local decode = json.decode(io.open("./blacklist.txt","r"):read())
  for a,b in pairs(decode) do
    if tostring(a) ~= tostring(id) then
      blacklists[a] = b
    end
  end
  --if blacklists[id] ~= nil then table.remove(blacklists,id) end
  file = io.open("./blacklist.txt", "w+") 
  file:write(json.encode(blacklists))
	file:close()
  print('done')
  return true
end

return module