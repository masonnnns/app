command = {}

local utils = require("/app/utils.lua")

command.info = {
  Name = "Setnick",
  Alias = {},
  Usage = "addrole <name>",
  Category = "Utility",
  Description = "Create a role.",
  PermLvl = 2,
}

command.execute = function(message,args,client)
  if message.guild:getMember(client.user.id):hasPermission("manageRoles") == false then return {success = false, msg = "I need the **Manage Roles** permission to do this."} end
  if args[2] == nil then return {success = false, msg = "You must specify a name."} end
  local name = string.sub(table.concat(args," ",2),1,25)
  message.guild:createRole(name)
  return {success = true, msg = "Created the **"..name.."** role."}
end

return command