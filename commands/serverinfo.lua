command = {}

local cache = require("/app/server.lua")
local utils = require("/app/resolve-user.lua")
local discordia = require("discordia")
local Date = discordia.Date

command.info = {
  Name = "Serverinfo",
  Alias = {"si"},
  Usage = "serverinfo",
  Category = "Utility",
  Description = "Get information on the server.",
  PermLvl = 5,
}

command.execute = function(message,args,client)
  message:reply{embed = {
      title = (user.id == message.author.id and "Your" or user.name.."'s").." Avatar",
      description = "[Click here]("..user:getAvatarURL()..") to download.",
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
      image = {url = user:getAvatarURL().."?size=256"},
      timestamp = Date(),
      color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
  }}
  return {success = "stfu", msg = ""}
end

return command

--[[

message:reply{embed = {
      title = (user.id == message.author.id and "Your" or user.name.."'s").." Avatar",
      description = "[Click here]("..user:getAvatarURL()..") to download.",
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
      image = {url = user:getAvatarURL().."?size=256"},
      color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
  }}

]]--