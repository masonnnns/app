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
  local region = message.guild.region
  if region == "us-east" then
    region = "US East :flag_us:"
  elseif region == "us-central" then
    region = "US Central :flag_us:"
  elseif region == "us-west" then
    region = "US West :flag_us:"
  elseif region == "us-south" then
    region = "US South :flag_us:"u
  end
  message:reply{embed = {
      title = message.guild.name,
      fields = {
        {name = "Owner", value = message.guild.owner.mentionString, inline = true},
        {name = "ID", value = message.guild.id, inline = true},
        {name = "Region", value = region, inline = true},
      },
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
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