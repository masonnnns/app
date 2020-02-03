command = {}

local utils = require("/app/resolve-user.lua")
local cache = require("/app/server.lua")

command.info = {
  Name = "Role",
  Alias = {},
  Usage = "role <user> <role>",
  Description = "Gives or takes a specified role.",
  PermLvl = 2,
}

command.execute = function(message,args,client)
  if args[2] == nil then
    return {success = false, msg = "You must provide a **member to edit** in argument 2."}
  elseif args[3] == nil then
    return {success = false, msg = "You must provide a **role to manage** in argument 3."}
  else
    local user = utils.resolveUser(message,args[2])
    local role = utils.resolveRole(message,table.concat(args," ",3))
    local roleInfo, theirRoleInfo, myRoleInfo, userInfo = cache.getCache("role",message.guild.id,role.id), cache.getCache("roleh",message.guild.id,message.author.id), cache.getCache("roleh",message.guild.id,client.user.id), cache.getCache("user",message.guild.id,user.id)
    if user == false then
      return {success = false, msg = "I couldn't find the member you mentioned."}
    elseif role == false then
      return {success = false, msg = "I couldn't find the role you mentioned."}
    elseif role:getPermissions():has("administrator") or role:getPermissions():has("manageGuild") then
      return {success = false, msg = "I won't manage that role because it's an **admin role**."}
    elseif roleInfo.position > theirRoleInfo.position then
      return {success = false, msg = "The **"..role.name.."** role is above your highest role, you cannot manage it."}
    elseif role.position > myRoleInfo.position then
      return {success = false, msg = "I cannot manage the **"..role.name.."** role."}
    else
      if userInfo.roles[role.id] == nil then
        message.guild:getMember(user.id):removeRole(role)
        message.guild:getMember(user.id):addRole(role)
        return {success = true, msg = "Gave **"..user.username.."** the **"..role.name.."** role."}
      else
        message.guild:getMember(user.id):addRole(role)
        message.guild:getMember(user.id):removeRole(role)
        return {success = true, msg = "Removed the **"..role.name.."** role from **"..user.username.."**."}
      end
    end
  end
end

return command