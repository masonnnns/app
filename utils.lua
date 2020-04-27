local module = {}
local verifyCache = {}
local config = require("/app/config.lua")

module.getPerm = function(message,id)
  if id == nil then id = message.author.id end
  if message.guild.owner.id == id then return 3 end
  if message.guild.roles:get(config.perms.adminRole) ~= nil and message.guild.members:get(id).roles:get(config.perms.adminRole) ~= nil then
    return 2
  elseif message.guild.roles:get(config.perms.modRole) ~= nil and message.guild.members:get(id).roles:get(config.perms.modRole) ~= nil then
    return 1
  else
    for _,users in pairs(config.perms.users) do
      if users[1] == id then
        if users[2]:lower() == "admin" then return 2 end
        if users[2]:lower() == "mod" then return 1 end
        return 0
      end
    end
    return 0
  end
end

module.verifyUser = function(message,id)
  if id == nil then id = message.author.id end
  if verifyCache[id] ~= nil then return verifyCache[id] end
  local verifyRes, verifyBody
  verifyRes, verifyBody = require("http").request("GET","https://verify.eryn.io/api/user/"..id)
  if verifyRes.code == 200 then
    verifyBody = require('json').decode(verifyBody)
    verifyCache[id] = {id = verifyBody.robloxId, username = verifyBody.robloxUsername}
    return {success = true, msg = verifyCahce[id]}
  elseif verifyRes.code == 404 then
    return {success = false, msg = "not_verified"}
  else
    return {success = false, msg = verifyRes.code}
  end
end

return module