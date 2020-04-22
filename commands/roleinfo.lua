command = {}

local config = require("/app/config.lua")
local utils = require("/app/utils.lua")
local discordia = require("discordia")
local Date = discordia.Date

command.info = {
  Name = "Roleinfo",
  Alias = {"ri"},
  Usage = "roleinfo <role>",
  Category = "Utility",
  Description = "Gets information on the specified role.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if args[2] == nil then return {success = false, msg = "You must specify a role."} end
  local role = utils.resolveRole(message,table.concat(args," ",2))
  if role == false then return {success = false, msg = "I couldn't find the role you mentioned."} end
  local perms = {}
  for a,items in pairs(role:getPermissions():toTable()) do
    if items == true then
      perms[1+#perms] = string.sub(a,1,1):upper()..string.sub(a,2)
    end
  end
  message:reply{embed = {
    title = role.name,
    fields = {
      {name = "Mention", value = role.mentionString, inline = true},
      {name = "ID", value = role.id, inline = true},
      {name = "Color", value = role:getColor():toHex(), inline = true},
      {name = "Members", value = (#role.members == 0 and "None!" or #role.members), inline = true},
      {name = "Position", value = role.position.."/"..#message.guild.roles, inline = true},
      {name = "Created At", value = utils.parseDateString(Date.fromSnowflake(role.id):toString(),1), inline = true},
      {name = "Hoisted", value = (role.hoisted and "Yes." or "No."), inline = true},
      {name = "Managed", value = (role.managed and "Yes." or "No."), inline = true},
      {name = "Mentionable", value = (role.mentionable and "Yes." or "No."), inline = true},
      {name = "Permissions", value = (#perms == 0 and "No Permissions!" or table.concat(perms,", ")), inline = false},
    },
    footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
    color = (message.member:getColor() == 0 and 3066993 or message.member:getColor().value),
  }}
  return {success = "stfu", msg = ""}
end

return command