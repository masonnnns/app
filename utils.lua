local module = {}
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

module.getRoles = function(message,reply,member)
  if member == nil then member = message.member.id end
  if config.groupId == nil or conifg.groupId == 0 then return "no_group" end
  if #config.bindings == 0 then return "no_binds" end
  local robloxId
  local res, body = require("coro-http").request("GET","https://verify.eryn.io/user/"..member.id)
  if res.code ~= 200 then return (res.code == 404 and "not_verifed" or "verify_err") end
  body = require("json").decode(body)
  local userId = body.robloxId
  res, body = http.request("GET","https://api.roblox.com/users/"..userId.."/groups")
  if res.code ~= 200 then return "api_down" else body = require("json").decode(body) end
  local groupInfo
  if #body >= 1 then
    for a,b in pairs(body) do
      if b.Id == config.groupId then
        groupInfo = b
        break
      end
    end
  end
  if groupInfo == nil then groupInfo = {Rank = 0, Role = "Guest"} end
  local changes = {added = {}, }
end

return module