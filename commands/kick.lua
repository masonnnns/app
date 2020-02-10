command = {}

local config = require("/app/config.lua")
local resolveUser = require("/app/resolve-user.lua")

command.info = {
  Name = "Kick",
  Alias = {},
  Usage = "kick <user> <reason>",
  Category = "Moderation",
  Description = "Kick a user from the server.",
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
    return {success = false, msg = "I cannot "..command.info.Name:lower().." myself."}
  elseif message.guild:getMember(client.user.id):hasPermission("kickMembers") ~= true then
			return {success = false, msg = "I need the **Kick Members** permission to do this."}
  else
    local reason = (args[3] == nil and "No Reason Provided." or table.concat(args," ",3))
    --user:getPrivateChannel():send("⛔ **You've been kicked from "..message.guild.name.."!**\n\n**Reason:** "..reason)
    message.guild:kickUser(user.id,reason)
    local data = config.getConfig(message.guild.id)
    data.modData.cases[1+#data.modData.cases] = {type = "Kick", user = user.id, moderator = message.author.id, reason = reason}
    config.updateConfig(message.guild.id,data)
    if data.modlog ~= "nil" and message.guild:getChannel(data.modlog) ~= nil then
      message.guild:getChannel(data.modlog):send{embed = {
        title = "Kick - Case "..#data.modData.cases,
        fields = {
          {
            name = "Member",
            value = user.mentionString.." (`"..user.id.."`)",
            inline = false,
          },
          {
            name = "Reason",
            value = reason,
            inline = false,
          },
          {
            name = "Responsible Moderator",
            value = message.author.mentionString.." (`"..message.author.id.."`)",
            inline = false,
          },
        },
        color = 15105570,
        }}
    end 
    return {success = true, msg = "**"..user.username.."** has been kicked."}
  end
end

return command