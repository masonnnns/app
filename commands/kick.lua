command = {}

local config = require("/app/config.lua")
local resolveUser = require("/app/resolve-user.lua")

command.info = {
  Name = "Warn",
  Alias = {},
  Usage = "warn <user> <reason>",
  Description = "Issue a warning to a specified user.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  if args[2] == nil then return {success = false, msg = "You must provide a **member to "..command.info.Name:lower().."** in argument 2."} end
  local user = resolveUser.resolveUser(message,args[2])
  if user == false then
    return {success = false, msg = "I couldn't find the user you mentioned."}
  elseif resolveUser.getPermission(message,client,user.id) >= resolveUser.getPermission(message,client) then
    return {success = false, msg = "You cannot "..command.info.Name:lower().." people with **higher than or equal permissions as you.**"}
  elseif user.id == client.user.id then
    return {success = false, msg = "I cannot warn myself."}
  else
    local reason = (args[3] == nil and "No Reason Provided." or table.concat(args," ",3))
    user:getPrivateChannel():send("⛔ **You've been warned in "..message.guild.name.."!**\nPlease do not continue to break the rules.\n\n**Reason:** "..reason)
    local data = config.getConfig(message.guild.id)
    data.modData.cases[1+#data.modData.cases] = {type = "Warn", user = user.id, moderator = message.author.id, reason = reason}
    config.updateConfig(message.guild.id,data)
    if data.modlog ~= "nil" and message.guild:getChannel(data.modlog) ~= nil then
      message.guild:getChannel(data.modlog):send{embed = {
        title = "Warning - Case "..#data.modData.cases,
        description = "**User:** "..user.mentionString.." (`"..user.id.."`)\n**Moderator:** "..message.author.mentionString.." (`"..message.author.id.."`)\n**Reason:** "..reason,
        color = 11027200,
        }}
    end 
    return {success = true, msg = "**"..user.name.."** has been warned."}
  end
end

return command