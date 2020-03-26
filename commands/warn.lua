command = {}

local config = require("/app/config.lua")
local utils = require("/app/utils.lua")

command.info = {
  Name = "Warn",
  Alias = {},
  Usage = "warn <user> <reason>",
  Category = "Moderation",
  Description = "Warn a member of the server.",
  PermLvl = 1,
  Cooldown = 3,
}

command.execute = function(message,args,client)
  local perms = message.guild:getMember("414030463792054282"):getPermissions()
  if perms:has("kickMembers") == false and perms:getPermissions():has("administrator")  == false then return {success = false, msg = "I need the **Kick Members** permission to do this."} end
  if args[2] == nil then return {success = false, msg = "You must provide a **member to "..command.info.Name:lower().."** in argument 2."} end
  local user = utils.resolveUser(message,args[2])
  if user == false then
    return {success = false, msg = "I couldn't find the user you mentioned."}
  elseif utils.Permlvl(message,client,user.id) >= utils.Permlvl(message,client) then
    return {success = false, msg = "You cannot "..command.info.Name:lower().." people with **higher than or equal permissions as you.**"}
  elseif user.highestRole.position >= message.guild:getMember("414030463792054282").highestRole.position then
    return {success = false, msg = "I cannot "..command.info.Name:lower().." "..user.tag.." because their **role is higher than mine**."}
  elseif user.id == client.user.id then
    return {success = false, msg = "I cannot "..command.info.Name:lower().." myself."}
  else
    local reason = (args[3] == nil and "No Reason Provided." or table.concat(args," ",3))
    local data = config.getConfig(message.guild.id)
    local result = user:getPrivateChannel():send("⚠️ **You have been warned in "..message.guild.name.."!**\nPlease do not continue to break the rules.\n\n**Reason:** "..reason)
    if result ~= nil and result ~= false then
      result = true
    else
      result = false
    end
    data.moderation.cases[1+#data.moderation.cases] = {type = "warn", user = user.id, moderator = message.author.id, reason = reason, modlog = "nil"}
    if data.general.modlog ~= "nil" and message.guild:getChannel(data.general.modlog) ~= nil then
      local modlog = message.guild:getChannel(data.general.modlog):send{embed = {
        title = "Warning - Case "..#data.moderation.cases,
        fields = {
          {name = "User", value = user.tag.." (`"..user.id.."`)", inline = false},
          {name = "Moderator", value = message.author.tag.." (`"..message.author.id.."`)",inline = false},
          {name = "Reason", value = reason, inline = false},
        },
        color = 15844367,
      }}
      data.moderation.cases[#data.moderation.cases].modlog = modlog.id    end
    return {success = true, msg = "**"..user.tag.."** has been warned"..(result and "." or ", but I couldn't message them.").." `[Case "..#data.moderation.cases.."]`"}
  end
end

return command