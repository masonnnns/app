command = {}

local utils = require("/app/utils.lua")

command.info = {
  Name = "Delrole",
  Alias = {},
  Usage = "delrole <name>",
  Category = "Utility",
  Description = "Delete a role.",
  PermLvl = 2,
}

command.execute = function(message,args,client)
  if message.guild:getMember(client.user.id):hasPermission("manageRoles") == false then return {success = false, msg = "I need the **Manage Roles** permission to do this."} end
  if args[2] == nil then return {success = false, msg = "You must specify a name."} end
  local name = utils.resolveRole(message,table.concat(args," ",2))
  if name == false then return {success = false, msg = "I couldn't find the role you mentioned."} end
  name:delete()
  return {success = true, msg = "Deleted the **"..name.name.."** role."}
end

return command