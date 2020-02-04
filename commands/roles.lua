command = {}

local cache = require("/app/server.lua")

command.info = {
  Name = "Roles",
  Alias = {},
  Usage = "roles",
  Description = "Displays a list of all the roles in the guild.",
  PermLvl = 2,
}

command.execute = function(message,args,client)
  local roles = {}  for _,items in pairs(message.guild.roles) do if items.id ~= message.guild.id then roles[1+#roles] = items.mentionString end end
  if #roles == 0 then return {success = false, msg = "There are **no roles** to display."} end
  message:reply{embed = {
    title = "Roles ["..#roles.."]",
    description = table.concat(roles,", "),
    footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
    color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
  }}
  return {success = "stfu", msg = ""}
end

return command