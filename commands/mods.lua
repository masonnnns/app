command = {}

local config = require("/app/config.lua")

command.info = {
  Name = "Mods",
  Alias = {"moderators"},
  Usage = "mods",
  Category = "Utility",
  Description = "View a list of all the moderators in the server.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  local users, roles = {}, {}
  for _,items in pairs(data.general.mods) do
    local user = message.guild:getMember(items)
    if user ~= nil then
      users[1+#users] = user.mentionString
    end
  end
  for _,items in pairs(data.general.modroles) do
    local role = message.guild:getRole(items)
    if role ~= nil then
      roles[1+#roles] = role.mentionString
    end
  end
  local data = {embed = {
    title = "Server Moderators",
    fields = {},
    footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
    color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
  }}
  if #users >= 1 then
    data.embed.fields[1+#data.embed.fields] = {name = "Moderators", value = table.concat(users," "), inline = true}
  end
  if #roles >= 1 then
    data.embed.fields[1+#data.embed.fields] = {name = "Mod Roles", value = table.concat(roles," "), inline = false}
  end
  if #data.embed.fields == 0 then return {success = false, msg = "There are no configured staff."} end
  message:reply{embed = data.embed}
  return {success = "stfu"}
end

return command