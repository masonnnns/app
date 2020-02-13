local json = require('json')
module = {}
local blacklist = {}

module.getBlacklist(id)
  if io.open("./blacklist.txt","r"):read() == nil then return end
  local decode = json.decode(io.open("./blacklist.txt","r"):read())
  for a,b in pairs(decode) do
    if b.user == id then
      if b.notified == false then
        return "notTold"
      else
        return "told"
      end
    end
  end
  return
end