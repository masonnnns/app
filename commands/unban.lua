command = {}

local config = require("/app/config.lua")
local utils = require("/app/resolve-user.lua")
local cache = require("/app/server.lua")

command.info = {
  Name = "Unban",
  Alias = {},
  Usage = "unban <user> <reason>",
  Category = "Moderation",
  Description = "Unbans the specified user.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  if cache.getCache("getperm",message.guild.id,"banMembers") == false and cache.getCache("getperm",message.guild.id,"administrator") == false then return {success = false, msg = "I need the **Ban Members** permission to do this."} end
  local data = config.getConfig(message.guild.id)
  if args[2] == nil then
    return {success = false, msg = "You must provide **a member to unban** in argument 2."}
  else
    local user = client:getUser(args[2])
    if user == nil then
      return {success = false, msg = "I couldn't find the user you mentioned."}
    elseif message.guild:getMember(client.user.id):hasPermission("banMembers") == false then
      return {success = false, msg = "I need the **Ban Members** permission to this."}
    elseif message.guild:getBan(user.id) == nil then
      return {success = false, msg = "**"..user.name.."** isn't banned!"}
    else
      local reason = (args[3] == nil and "No Reason Provided." or table.concat(args," ",3))
      for a,items in pairs(data.modData.actions) do if items.user == user.id and string.lower(items.type) == "ban" then table.remove(data.modData.actions,a) end end
      message.guild:unbanUser(user.id,reason)
      data.modData.cases[1+#data.modData.cases] = {type = "Unban", user = user.id, moderator = message.author.id, reason = reason, id = 0}
      if data.modlog ~= "nil" and message.guild:getChannel(data.modlog) ~= nil then
        local msg = message.guild:getChannel(data.modlog):send{embed = {
          title = "Unban - Case "..#data.modData.cases,
          fields = {
            {
              name = "Member",
              value = user.tag.." (`"..user.id.."`)",
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
           color = 3066993,
        }}
        data.modData.cases[#data.modData.cases].id = msg.id
        return {success = true, msg = "**"..user.username.."** has been unbanned. `[Case #"..#data.modData.cases.."]`"}
      end
    end
  end
end

return command