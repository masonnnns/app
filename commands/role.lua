command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")

command.info = {
  Name = "Role",
  Alias = {},
  Usage = "role <user> <role>",
  Category = "Administration",
  Description = "Give or take a role from a user.",
  PermLvl = 2,
}

command.execute = function(message,args,client)
  if message.guild:getMember("414030463792054282"):getPermissions():has("manageRoles") == false and message.guild:getMember("414030463792054282"):getPermissions():has("administrator")  == false then return {success = false, msg = "I need the **Manage Roles** permission to do this."} end
  if args[2] == nil then return {success = false, msg = "You must provide a user to role."} end
  if args[3] == nil then return {success = false, msg = "You must provide a role to give or take."} end
  local data = config.getConfig(message.guild.id)
  local user = utils.resolveUser(message,args[2])
  local role = utils.resolveRole(message,table.concat(args," ",3))
  if user == false then return {success = false, msg = "I couldn't find the user you mentioned."} end
  if role == false then return {success = false, msg = "I couldn't find the role you mentioned."} end
  if user.highestRole.position >= message.guild:getMember("414030463792054282").highestRole.position then return {success = false, msg = "**"..user.tag.."** has a higher role than I do, I cannot manage their roles."} end
  if role:getPermissions():has("administrator") or role:getPermissions():has("manageGuild") then return {success = false, msg = "I cannot manage the **"..role.name.."** role because it's an admin role."} end
  if role.position > message.guild:getMember(message.author.id).highestRole.position then return {success = false, msg = "You cannot manage the **"..role.name.."** role because it's higher than your highest role."} end
  if role.managed then return {success = false, msg = "I cannot manage the **"..role.name.."** role."} end
  local found
  for _,items in pairs(user.roles) do if items.id == role.id then found = true break end end
  if found then
    user:removeRole(role.id)
    return {success = true, msg = "Removed the **"..role.name.."** role from **"..user.tag.."**."}
  else
    user:addRole(role.id)
    return {success = true, msg = "Added the **"..role.name.."** role to **"..user.tag.."**."}
  end
end

return command