command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")

local function find(message,data,id)
  for _,items in pairs(data) do if items == id then return true end end
  return false
end

command.info = {
  Name = "Delmod",
  Alias = {"unmod"},
  Usage = "delmod <member>",
  Category = "Administration",
  Description = "Take a member's moderator permissions.",
  PermLvl = 2,
} 

command.execute = function(message,args,client)
  if args[2] == nil then return {success = false, msg = "You must provide a **member to remove moderator permissions** from."} end
  local user = utils.resolveUser(message,table.concat(args," ",2))
  if user == false then return {success = false, msg = "I couldn't find the user you mentioned."} end
  if user.id == client.user.id then return {success = false, msg = "I cannot take my moderator permissions."} end
  local data = config.getConfig(message.guild.id)
  if find(message,data.general.mods,user.id) == false then return {success = false, msg = "**"..user.tag.."** doesn't have moderator permissions."} end
  for _,items in pairs(data.general.mods) do if items == user.id then table.remove(data.general.mods,_) end end
  return {success = true, msg = "**"..user.tag.."**'s moderator permissions have been removed."}
end

return command