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
        table.remove(data.modData.actions,a)
        user:removeRole(message.guild:getRole(data.mutedrole))
        data.modData.cases[1+#data.modData.cases] = {type = "Unmute", user = user.id, moderator = message.author.id, reason = reason}
        config.updateConfig(message.guild.id,data)
        message.guild:getChannel(data.modlog):send{embed = {
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
          color = 2067276,
        }}
        return {success = true, msg = "**"..user.username.."** has been unmuted."}
      end
    end
  end
end

return command