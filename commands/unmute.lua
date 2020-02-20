command = {}

local config = require("/app/config.lua")
local utils = require("/app/resolve-user.lua")
local cache = require("/app/server.lua")

command.info = {
  Name = "Unmute",
  Alias = {},
  Usage = "unmute <user> <reason>",
  Category = "Moderation",
  Description = "Unmutes the specified user.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  if cache.getCache("getperm",message.guild.id,"manageRoles") == false and cache.getCache("getperm",message.guild.id,"administrator") == false then return {success = false, msg = "I need the **Manage Roles** permission to do this."} end
  local data = config.getConfig(message.guild.id)
  if args[2] == nil then
    return {success = false, msg = "You must provide **a member to unmute** in argument 2."}
  else
    local user = utils.resolveUser(message,args[2])
    if user == false then
      return {success = false, msg = "I couldn't find the user you mentioned."}
    elseif utils.getPermission(message,client,user.id) >= utils.getPermission(message,client) then
      return {success = false, msg = "You cannot "..command.info.Name:lower().." people with **higher than or equal permissions as you.**"}
    elseif user.id == client.user.id then
      return {success = false, msg = "I cannot "..command.info.Name:lower().." myself."}
    else
      if cache.getCache("user",message.guild.id,user.id).roles[data.mutedrole] == nil then
        return {success = false, msg = "**"..user.name.."** isn't currently muted."}
      else
        local reason = (args[3] == nil and "No Reason Provided." or table.concat(args," ",3))
        for a,items in pairs(data.modData.actions) do if items.user == user.id and string.lower(items.type) == "mute" then table.remove(data.modData.actions,a) end end
        user:removeRole(message.guild:getRole(data.mutedrole))
        data.modData.cases[1+#data.modData.cases] = {type = "Unmute", user = user.id, moderator = message.author.id, reason = reason, id = 0}
        if data.modlog ~= "nil" and message.guild:getChannel(data.modlog) ~= nil then
          local msg = message.guild:getChannel(data.modlog):send{embed = {
            title = "Unmute - Case "..#data.modData.cases,
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
            color = 3066993,
          }}
        data.modData.cases[#data.modData.cases].id = msg.id
        end
        return {success = true, msg = "**"..user.username.."** has been unmuted. `[Case #"..#data.modData.cases.."]`"}
      end
    end
  end
end

return command