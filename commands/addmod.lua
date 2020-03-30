command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")

command.info = {
  Name = "Addmod",
  Alias = {"mod"},
  Usage = "addmod <member>",
  Category = "Administration",
  Description = "Give a member moderator permissions.",
  PermLvl = 2,
} 

command.execute = function(message,args,client)
  if args[2] == nil then return {success = false, msg = "You must specify a member."} end
  local user = utils.resolveUser(message,table.concat(args," ",2))
  if user == false then return {success = false, msg = "I couldn't find the user you mentioned."} end
  if user.id == client.user.id then return {success = false, msg = "I cannot give myself moderator permissions."} end
  if utils.Permlvl(message,client,user.id) >= 1 then return {success = false, msg = "**"..user.tag.."** already has moderator permissions."} end
  local data = config.getConfig(message.guild.id)
  data.general.mods[1+#data.general.mods] = user.id
  return {success = true, msg = "**"..user.tag.."** has been given moderator permissions."}
end

return command