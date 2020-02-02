command = {}

local utils = require("/app/resolve-user.lua")

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
    if user == false then
      return {success = false, msg = "I couldn't find the member you mentioned."}
    elseif 
  end
end

return command