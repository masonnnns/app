command = {}

local config = require("/app/config.lua")

command.info = {
  Name = "Staff",
  Alias = {"moderators","mods",},
  Usage = "staff",
  Category = "Utility",
  Description = "View a list of all the moderators and admins in the server.",
  PermLvl = 1,
  Cooldown = 3,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  local users, roles, admins = {}, {}, {}
  for _,items in pairs(data.general.mods) do
    local user = message.guild.members:get(items)
    if user ~= nil and users.bot == false then
      users[1+#users] = user.mentionString
    end
  end
  for _,items in pairs(data.general.modroles) do
    local role = message.guild.roles:get(items)
    if role ~= nil then
      roles[1+#roles] = role.mentionString
    end
  end
  for _,items in pairs(message.guild.members) do
    local permLvl = require('/app/utils.lua').Permlvl(message,client,items.id)
    if permLvl >= 2 and items.bot == false then
      admins[1+#admins] = items.mentionString
    end
  end
  local data = {embed = {
    title = "Server Staff",
    fields = {},
    footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
    color = (message.member:getColor() == 0 and 3066993 or message.member:getColor().value),
  }}
  if #users >= 1 then
    data.embed.fields[1+#data.embed.fields] = {name = "Moderators ["..#users.."]", value = table.concat(users," "), inline = true}
  end
  if #admins >= 1 then
    data.embed.fields[1+#data.embed.fields] = {name = "Admins ["..#admins.."]", value = table.concat(admins," "), inline = true}
  end
  if #roles >= 1 then
    data.embed.fields[1+#data.embed.fields] = {name = "Mod Roles ["..#roles.."]", value = table.concat(roles," "), inline = false}
  end
  if #data.embed.fields == 0 then return {success = false, msg = "There are no configured staff."} end
  message:reply{embed = data.embed}
  return {success = "stfu"}
end

return command