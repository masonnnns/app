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

local function manageRoles(member)
  if config.groupId == nil or conifg.groupId == 0 then return "no_group" end
  if member == nil then member = message.member end
  local robloxId
  local res, body = require("coro-http").request("GET","https://verify.eryn.io/user/"..member.id)
  if res.code ~= 200 then return (res.code == 404 and "not_verifed" or "verify_err") end
  body = require("json").decode(body)
  local userId = body.robloxId
  result, body = http.request("GET","https://api.roblox.com/users/"..userId.."/groups")
  
end

module.getRoles = function(message,reply,member)
  if member == nil then member = message.member end
  local getRoles = manageRoles(member)
end

return module