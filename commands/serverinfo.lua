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
  local filter = message.guild.explicitContentSetting
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
  if verification == 0 then
    verification = "( ͡° ͜ʖ ͡°) (None)"
  elseif verification == 1 then
    verification = "(#^.^#) (Low)"
  elseif verification == 2 then
    verification = 'ఠ ͟ಠ (Medium)'
  elseif verification == 3 then
    verification = "(╯°□°）╯︵ ┻━┻ (High)"
  elseif verification == 4 then
    verification = "┻━┻ ﾐヽ(ಠ益ಠ)ノ彡┻━┻ (Very High)"
  else
    verification = "Error."
  end
  if filter == 0 then
    filter = "None"
  elseif filter == 1 then
    filter = "Scan content from members with no roles."
  elseif filter == 2 then
    filter = "Scan content from all members."
  else
    filter = "Error."
  end
  message:reply{embed = {
      title = message.guild.name,
      fields = {
        {name = "Owner", value = message.guild.owner.mentionString, inline = true},
        {name = "ID", value = message.guild.id, inline = true},
        {name = "Region", value = region, inline = true},
        {name = "Verification Level", value = verification, inline = true},
        {name = "Explicit Content Filter", value = filter, inline = true},
        {name = "Created At", value = Date.fromSnowflake(message.guild.id):toISO(' ', ''), inline = true},
        {name = "Channels ["..#message.guild.voiceChannels + #message.guild.textChannels + #message.guild.categories.."]", value = ">>> **Categories:** "..(#message.guild.categories == 0 and "None!" or #message.guild.categories).."\n**Text Channels:** "..(#message.guild.textChannels == 0 and "None!" or #message.guild.textChannels).."\n**Voice Channels:** "..(#message.guild.voiceChannels == 0 and "None!" or #message.guild.voiceChannels), inline = false}
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