command = {}

command.info = {
  Name = "Blacklist",
  Alias = {"bl"},
  Usage = "blacklist <guild/user/view> <ID> <reason>",
  Category = "Private",
  Description = "Blacklist a guild or a user from using AA-R0N.",
  PermLvl = 5,
}

local blacklist = require("/app/blacklist.lua")

command.execute = function(message,args,client)
  if args[2] == nil then return {success = false, msg = "You must specify 'guild' or 'user' or 'view'."} end
  if args[2]:lower() ~= "guild" and args[2]:lower() ~= "user" and args[2]:lower() ~= "view" then return {success = false, msg = "You must specify 'guild' or 'user' or 'view'."} end
  if args[2]:lower() == "guild" then
    local guild = client:getGuild(args[3])
    if guild == nil then return {success = false, msg = "That guild doesn't exist."} end
    if blacklist.getBlacklist("guilds_"..args[3]) ~= false then
      blacklist.unblacklist("guilds_"..args[3])
      return {success = true, msg = "Unblacklisted **"..guild.name.."**."}
    else
      local reason = (args[4] == nil and "No Reason Provided." or table.concat(args," ",4))
      blacklist.blacklist("guilds_"..args[3],reason)
      if client.guilds:get(args[3]) ~= nil then guild:leave() end
      require("/app/config.lua").delConfig(message.guild.id)
      return {success = true, msg = "**"..guild.name.."** has been blacklisted."}
    end
  elseif args[2]:lower() == "user" then
    local user = client:getUser(args[3])
    if user == nil then return {success = false, msg = "That user doesn't exist."} end
    if blacklist.getBlacklist("users_"..args[3]) ~= false then
      blacklist.unblacklist("users_"..args[3])
      return {success = true, msg = "Unblacklisted **"..user.tag.."**."}
    else 
      local reason = (args[4] == nil and "No Reason Provided." or table.concat(args," ",4))
      blacklist.blacklist("users_"..args[3],reason)
      return {success = true, msg = "**"..user.tag.."** has been blacklisted."}
    end
  else
    return {success = true, msg = "later smh"}
  end
  return {success = "stfu"}
end

return command