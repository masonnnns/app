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

module.getRoles = function(message,member)
  if member == nil then member = message.member end
  local config = require("/app/config.lua")
  if config.groupId == nil or config.groupId == 0 then return "no_group" end
  local res, body = require("coro-http").request("GET","https://verify.eryn.io/user/"..member.id)
  print(res.code,member.id)
  if res.code ~= 200 then return (res.code == 404 and "not_verifed" or "verify_err") end
  body = require("json").decode(body)
  local userId, name = body.robloxId, body.robloxUsername
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
  local changes = {added = {}, removed = {}}
  local bindings = config.bindings
  for a,b in pairs(bindings) do
    local role = message.guild.roles:get(b)
    if role then
      if a == groupInfo.Rank and member.roles:get(b) == nil then
        local success, msg = member:addRole(b)
        if (success) then changes.added[1+#changes.added] = role.name end
      elseif a ~= groupInfo.Rank and member.roles:get(b) ~= nil then
        local success, msg = member:removeRole(b)
        if (success) then changes.removed[1+#changes.removed] = role.name end
      end
      require("timer").sleep(250)
    end
  end
  if memeber.roles:get(config.verifiedRole) == nil and message.guild.roles:get(config.verifiedRole) ~= nil then
    local success, msg = member:addRole(config.verifiedRole)
    if (success) then changes.added[1+#changes.added] = message.guild.roles:get(config.verifiedRole).name end
  end
  if member.name:lower() ~= name:lower() then
    member:setNickname(name)
  end
  if #changes.added + #changes.removed == 0 then return "no_changes" end
  return changes
end

return module