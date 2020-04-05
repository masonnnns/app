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
    if blacklist.getBlacklist("guilds_"..args[3]) ~= false then return {success = false, msg = "**"..guild.name.."** is already blacklisted."} end
    local reason = (args[4] == nil and "No Reason Provided." or table.concat(args," ",4))
    blacklist.blacklist("guilds_"..args[3],reason)
    require("/app/config.lua").delConfig(message.guild.id)
    return {success = true, msg = "**"..guild.name.."** has been blacklisted."}
  end
  return {success = "stfu"}
end

return command