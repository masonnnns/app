command = {}

local config = require("/app/config.lua")
local utils = require("/app/utils.lua")
local discordia = require("discordia")
local Date = discordia.Date

command.info = {
  Name = "Userinfo",
  Alias = {"w","whois","ui"},
  Usage = "userinfo <optional user>",
  Category = "Utility",
  Description = "Views information on a specified user.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if args[2] == nil then args[2] = message.author.id end
  local user = utils.resolveUser(message,table.concat(args," ",2))
  local inGuild = true
  if user == false and tonumber(args[2]) ~= nil then if client:getUser(args[2]) ~= nil then user = client:getUser(args[2]) inGuild = false else user = false end end
  if user == false then
    return {success = false, msg = "I couldn't find the user you mentioned."}
  else
    local embed = {}
    embed.title = user.tag
    embed.thumbnail = {url = (user.avatarURL == nil and "https://cdn.discordapp.com/embed/avatars/"..math.random(1,4)..".png" or user.avatarURL)}
    embed.footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag}
    embed.color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color)
    if inGuild == true then
      embed.fields = {
        {name = "Mention", value = user.mentionString, inline = true},
        {name = "ID", value = user.id, inline = true},
        {name = "Nickname", value = (user.nickname == nil and "None Set." or user.nickname), inline = true},
        {name = "Status", value = "loading...", inline = true},
        {name = "Activity", value = "loading...", inline = true},
        {name = "Server Permission", value = "Member", inline = true},
        {name = "Created At", value = Date.fromSnowflake(user.id):toISO(' ', ''), inline = true},
        {name = "Joined At", value = (user.joinedAt and user.joinedAt:gsub('%..*', ''):gsub('T', ' ') or "ERROR"), inline = true},
        {name = "Roles [0]", value = "None!", inline = false},
        {name = "Permissions", value = "None!", inline = false},
      }
      if user.status == "online" then embed.fields[4].value = "Online" end
      if user.status == "idle" then embed.fields[4].value = "Idle" end
      if user.status == "dnd" then embed.fields[4].value = "Do Not Disturb" end
      if user.status == "offline" then embed.fields[4].value = "Offline" end
    end
    message:reply{embed = embed}
    return {success = "stfu"}
  end
end

return command