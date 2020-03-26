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
        
      }
    end
    message:reply{embed = embed}
    return {success = "stfu"}
  end
end

return command