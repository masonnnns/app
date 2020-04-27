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

return module