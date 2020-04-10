command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")

command.info = {
  Name = "Softban",
  Alias = {"sb"},
  Usage = "softban <user> <reason>",
  Category = "Moderation",
  Description = "Kick a member from the server and delete all of their messages with the specified reason.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  if message.guild:getMember(client.user.id):hasPermission("banMembers") == false then return {success = false, msg = "I need the **Ban Members** permission to do this."} end
  if args[2] == nil then return {success = false, msg = "You must specify a member."} end
  local user = utils.resolveUser(message,args[2])
  if user == false then 
    return {success = false, msg = "I couldn't find the user you mentioned."}
  elseif utils.Permlvl(message,client,user.id) >= utils.Permlvl(message,client) then
    return {success = false, msg = "You cannot "..command.info.Name:lower().." other **moderators/administrators**."}
  elseif user.highestRole and user.highestRole.position >= message.guild:getMember("414030463792054282").highestRole.position then
    return {success = false, msg = "I cannot "..command.info.Name:lower().." **"..user.tag.."** because their **role is higher than mine**."}
  elseif user.id == client.user.id then
    return {success = false, msg = "I cannot "..command.info.Name:lower().." myself."}
  else
    local data = config.getConfig(message.guild.id)
    local reason = (args[3] == nil and "No Reason Provided." or table.concat(args," ",3))
    message.guild:banUser(user,reason,7)
    data.moderation.cases[1+#data.moderation.cases] = {type = "softban", user = user.id, moderator = message.author.id, reason = reason, modlog = "nil"}
    if data.general.modlog ~= "nil" and message.guild:getChannel(data.general.modlog) ~= nil then
      local modlog = message.guild:getChannel(data.general.modlog):send{embed = {
        title = "Softban - Case "..#data.moderation.cases,
        fields = {
          {name = "User", value = user.tag.." (`"..user.id.."`)", inline = false},
          {name = "Moderator", value = message.author.tag.." (`"..message.author.id.."`)",inline = true},
          {name = "Reason", value = reason, inline = false},
        },
        color = 10038562,
      }}
      data.moderation.cases[#data.moderation.cases].modlog = modlog.id    
    end
    message.guild:unbanUser(user.id,reason)
    return {success = true, msg = "**"..user.tag.."** has been softbanned. `[Case "..#data.moderation.cases.."]`"}
  end
end

return command