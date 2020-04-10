command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")

command.info = {
  Name = "Unban",
  Alias = {"pardon"},
  Usage = "unban <ID> <reason>",
  Category = "Moderation",
  Description = "Unbans the specified user from the server.",
  PermLvl = 1,
} 

command.execute = function(message,args,client)
  --if message.guild:getMember(client.user.id):hasPermission("banMembers") == false then return {success = false, msg = "I need the **Ban Members** permission to do this."} end
  if tonumber(args[2]) == nil then return {success = false, msg = "I couldn't find the user you mentioned."} end
  local user = client:getUser(args[2])
  if user == nil then return {success = false, msg = "I couldn't find the user you mentioned."} end
  if message.guild:getBans() == nil then return {success = false, msg = "I need the **Ban Members** permission to do this."} end
  if message.guild:getBans():get(user.id) == nil then return {success = false, msg = "**"..user.tag.."** isn't banned."} end
  local data = config.getConfig(message.guild.id)
  local reason = (args[3] == nil and "No Reason Provided." or table.concat(args," ",3))
  for a, items in pairs(data.moderation.actions) do
    if items.id == user.id and items.type == "ban" then
      table.remove(data.moderation.actions,a)
    end
  end
  message.guild:unbanUser(user.id,reason)
  data.moderation.cases[1+#data.moderation.cases] = {type = "unban", user = user.id, moderator = message.author.id, reason = reason, modlog = "nil"}
  if data.general.modlog ~= "nil" and message.guild:getChannel(data.general.modlog) ~= nil then
    local modlog = message.guild:getChannel(data.general.modlog):send{embed = {
      title = "Unban - Case "..#data.moderation.cases,
      fields = {
        {name = "User", value = user.tag.." (`"..user.id.."`)", inline = false},
        {name = "Moderator", value = message.author.tag.." (`"..message.author.id.."`)",inline = true},
        {name = "Reason", value = reason, inline = false},
      },
      color = 3066993,
    }}
    data.moderation.cases[#data.moderation.cases].modlog = modlog.id    
  end
    return {success = true, msg = "**"..user.tag.."** has been unbanned. `[Case "..#data.moderation.cases.."]`"}
end

return command