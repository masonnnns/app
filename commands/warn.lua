command = {}

local config = require("/app/config.lua")
local resolveUser = require("/app/resolve-user.lua")

command.info = {
  Name = "Warn",
  Alias = {},
  Usage = "warn <user> <reason>",
  Category = "Moderation",
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
    local data = config.getConfig(message.guild.id)
    local result = user:getPrivateChannel():send("⚠️ **You have been warned in "..message.guild.name.."!**\nPlease do not continue to break the rules.\n\n**Reason:** "..reason)
    if result ~= nil and result ~= false then
      result = true
    else
      result = false
    end
    local case = {type = "Warn", user = user.id, moderator = message.author.id, reason = reason, id = 0}
    if data.modlog ~= "nil" and message.guild:getChannel(data.modlog) then
      local msg = message.guild:getChannel(data.modlog):send{embed = {
        title = "__Warning__ - Case "..(#data.modData.cases + 1),
        fields = {
          {name = "Member", value = user.mentionString.." (`"..user.id.."`)", inline = false},
          {name = "Reason", value = reason, inline = false},
          {name = "Moderator", value = message.author.mentionString.." (`"..message.author.id.."`)", inline = false},
        },
        color = 15105570
      }}
      case.id = msg.id
    end
    data.modData.cases[1+#data.modData.cases] = case
    config.updateConfig(message.guild.id,data)
    return {success = true, msg = "**"..user.username.."** has been warned"..(result == true and "." or ", but I couldn't message them.").." `[Case "..#data.modData.cases.."]`"}
  end
end

return command