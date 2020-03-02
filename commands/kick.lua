command = {}

local config = require("/app/config.lua")
local utils = require("/app/utils.lua")

command.info = {
  Name = "Kick",
  Alias = {},
  Usage = "kick <user> <reason>",
  Category = "Moderation",
  Description = "Kick a user from the server.",
  PermLvl = 1,
  Cooldown = 3,
}

command.execute = function(message,args,client)
  if message.guild:getMember("414030463792054282"):getPermissions():has("kickMembers") == false and message.guild:getMember("414030463792054282"):getPermissions():has("administrator")  == false then return {success = false, msg = "I need the **Kick Members** permission to do this."} end
  if args[2] == nil then return {success = false, msg = "You must provide a **member to "..command.info.Name:lower().."** in argument 2."} end
  local user = utils.resolveUser(message,args[2])
  if user == false then
    return {success = false, msg = "I couldn't find the user you mentioned."}
  elseif utils.Permlvl(message,client,user.id) >= utils.Permlvl(message,client) then
    return {success = false, msg = "You cannot "..command.info.Name:lower().." people with **higher than or equal permissions as you.**"}
  elseif user.highestRole.position >= message.guild:getMember("414030463792054282").highestRole.position then
    return {success = false, msg = "I cannot "..command.info.Name:lower().." "..user.tag.." because their **role is higher than mine**."}
  elseif user.id == client.user.id then
    return {success = false, msg = "I cannot "..command.info.Name:lower().." myself."}
  else
    local reason = (args[3] == nil and "No Reason Provided." or table.concat(args," ",3))
    message.guild:kickUser(user.id,reason)
    local data = config.getConfig(message.guild.id)
  end
end

return command