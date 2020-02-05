command = {}

local config = require("/app/config.lua")
local utils = require("/app/resolve-user.lua")
local cache = require("/app/server.lua")

command.info = {
  Name = "Unmute",
  Alias = {},
  Usage = "unmute <user> <reason>",
  Description = "Unmutes the specified user.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if args[2] == nil then
    return {success = false, msg = "You must provide **a member to unmute** in argument 2."}
  elseif #data.modData.actions = 0 then
    return {success = false, msg = "There are currently **no muted users**."}
  else
    local user = resolveUser.resolveUser(message,args[2])
    if user == false then
      return {success = false, msg = "I couldn't find the user you mentioned."}
    elseif resolveUser.getPermission(message,client,user.id) >= resolveUser.getPermission(message,client) then
      return {success = false, msg = "You cannot "..command.info.Name:lower().." people with **higher than or equal permissions as you.**"}
    elseif user.id == client.user.id then
      return {success = false, msg = "I cannot "warn" myself."}
end

return command