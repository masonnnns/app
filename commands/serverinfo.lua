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
  local verification = message.guild.verificationLevel
  if region == "us-east" then
    region = "US East :flag_us:"
  elseif region == "us-central" then
    region = "US Central :flag_us:"
  elseif region == "us-west" then
    region = "US West :flag_us:"
  elseif region == "us-south" then
    region = "US South :flag_us:"
  elseif region == "southafrica" then
    region = "South Africa :flag_za:"
  elseif region == "brazil" then
    region = "Brazil :flag_br:"
  elseif region == "europe" then
    region = "Europe :flag_eu:"
  elseif region == "hongkong" then
    region = "Hong Kong :flag_hk:"
  elseif region == "india" then
    region = "India :flag_in:"
  elseif region == "japan" then
    region = "Japan :flag_jp:"
  elseif region == "russia" then
    region = "Russia :flag_ru:"
  elseif region == "sydney" then
    region = "Sydney :flag_hm:"
  end
  if verifica
  message:reply{embed = {
      title = message.guild.name,
      fields = {
        {name = "Owner", value = message.guild.owner.mentionString, inline = true},
        {name = "ID", value = message.guild.id, inline = true},
        {name = "Region", value = region, inline = true},
        {name = "Verification Level", value = verification, inline = true},
      },
      thumbnail = {url = (message.guild.iconURL == nil and "https://cdn.discordapp.com/embed/avatars/"..math.random(1,4)..".png" or message.guild.iconURL)},
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