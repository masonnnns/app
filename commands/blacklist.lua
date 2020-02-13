command = {}

local blacklists = require("/app/blacklist.lua")

command.info = {
  Name = "Blacklist",
  Alias = {},
  Usage = "blacklist <id> <reason>",
  Category = "Private",
  Description = "Blacklist the specified user.",
  PermLvl = 5,
}

command.execute = function(message,args,client)
  if args[2] == nil then
    return {success = false, msg = "You must provide a **user ID to blacklist** in argument 2."}
  elseif tonumber(args[2]) == nil then
    return {success = false, msg = "You must provide a **user ID to blacklist** in argument 2."}
  else
    if args[3] == "get"
    elseif blacklists.getBlacklist(args[2]) == true then
      blacklists.blacklist(args[2],(args[3] == nil and "No Reason Provided" or table.concat(args," ",3)))
      return {success = true, msg = "Blacklisted **"..client:getUser(args[2]).name.."**."}
    else
       blacklists.unblacklist(args[2],(args[3] == nil and "No Reason Provided" or table.concat(args," ",3)))
      return {success = true, msg = "Unblacklisted **"..client:getUser(args[2]).name.."**."}
    end
  end
end

return command