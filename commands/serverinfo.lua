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
  local emotes = {0,{},""}
  local roles = {0,{},""}
  local members = {0,{online = 0, dnd = 0, idle = 0, offline = 0, bots = 0}}
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
  elseif region == "eu-central" then
    region = "EU Central"
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
  for a,items in pairs(cache.getCache("users",message.guild.id)) do
    members[1] = members[1] + 1
    if items.bot then
      members[2].bots = members[2].bots+1
    end
    members[2][items.status] = members[2][items.status]+1
  end
  local hold = 0
  for a,b in pairs(message.guild.emojis) do
    emotes[1] = emotes[1] + 1
    if #emotes[2] <= 25 then
      emotes[2][1+#emotes[2]] = b.mentionString
    else
      hold = hold + 1
      emotes[3] = "...and "..hold.." more."
    end
  end
  hold = 0
  for a,b in pairs(message.guild.roles) do
    if a == message.guild.id then else
      roles[1] = roles[1] + 1
      if #roles[2] <= 25 then
        roles[2][b.position] = b.mentionString
      else
        hold = hold + 1
        roles[3] = "...and "..hold.." more."
      end
    end
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
        --{name = "I Joined At", value = message.guild:getMember(client.user.id).joinedAt:gsub('%..*', ''):gsub('T', ' '),inline = true},
        {name = "Members ["..members[1].."]", value = ">>> **Online:** "..members[2]["online"].."\n**Do not Disturb:** "..members[2]["dnd"].."\n**Idle:** "..members[2]["idle"].."\n**Offline:** "..members[2]["offline"].."\n**Bots:** "..members[2].bots,inline = true},
        {name = "Channels ["..#message.guild.voiceChannels + #message.guild.textChannels + #message.guild.categories.."]", value = ">>> **Categories:** "..(#message.guild.categories == 0 and "None!" or #message.guild.categories).."\n**Text Channels:** "..(#message.guild.textChannels == 0 and "None!" or #message.guild.textChannels).."\n**Voice Channels:** "..(#message.guild.voiceChannels == 0 and "None!" or #message.guild.voiceChannels), inline = true},
        {name = "Emotes ["..emotes[1].."]", value = ">>> "..(emotes[1] == 0 and "No emotes, go make some! <a:dboatsSharkDance:575397354635657227>" or table.concat(emotes[2]," ").."\n"..emotes[3])},
        {name = "Roles ["..roles[1].."]", value = ">>> "..(roles[1] == 0 and "No roles, go make some!" or table.concat(roles[2]," ").."\n"..roles[3])},
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