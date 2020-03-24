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
  if user.highestRole.position >= message.guild:getMember("414030463792054282").highestRole.position then return {success = false, msg = "**"..user.tag.."** has a "}
  local role = utils.resolveRole(message,table.concat(args,3))
  if user == false then return {success = false, msg = "I couldn't find the user you mentioned."} end
  if role == false then return {success = false, msg - "I couldn't find the role you mentioned."} end
  local found
  for _,items in pairs(user.roles) do if items.id == role.id then found = true break end end
  if found then
    user:removeRole(role.id)
    return {success = true, msg = }
  end
end

return command