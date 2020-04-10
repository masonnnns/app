command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")

command.info = {
  Name = "Case",
  Alias = {},
  Usage = "case <number>",
  Category = "Moderation",
  Description = "View a moderation case.",
  PermLvl = 1,
} 

command.execute = function(message,args,client)
  if args[2] == nil then return {success = false, msg = "You must specify a case number."} end
  if tonumber(args[2]) == nil then return {success = false, msg = "You must specify a case number."} end
  local data = config.getConfig(message.guild.id)
  if data.moderation.cases[tonumber(args[2])] == nil then return {success = false, msg = "**Case "..args[2].."** doesn't exist."} end
  local case = data.moderation.cases[tonumber(args[2])]
  local type = (case.moderator == client.user.id and "Automatic " or "")..""..string.sub(case.type,1,1):upper()..string.sub(case.type,2)
  local embed = {
    title = type.." - Case "..args[2],
    fields = {},
    footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
    color = 3066993,
  }
  embed.fields[1+#embed.fields] = {name = "User", value = client:getUser(case.user).tag.." (`"..case.user.."`)", inline = false}
  embed.fields[1+#embed.fields] = {name = "Moderator", value = client:getUser(case.moderator).tag.." (`"..case.moderator.."`)", inline = false}
  if case.duration then embed.fields[#embed.fields].inline = true embed.fields[1+#embed.fields] = {name = "Duration", value = case.duration, inline = true} end
  embed.fields[1+#embed.fields] = {name = "Reason", value = case.reason, inline = false}
  if case.type:lower() == "ban" then embed.color = 15158332 end
  if case.type:lower() == "kick" then embed.color = 15105570 end
  if case.type:lower() == "mute" then embed.color = 15105570 end
  if case.type:lower() == "warn" then embed.color = 15844367 end
  if case.type:lower() == "softban" then embed.color = 10038562 end
  if data.general.modlog ~= "nil" and case.modlog ~= "nil" and message.guild:getChannel(data.general.modlog) and message.guild:getChannel(data.general.modlog):getMessage(case.modlog) then
    embed.description = "[Jump to Modlog](https://discordapp.com/channels/"..message.guild.id.."/"..data.general.modlog.."/"..case.modlog..")"
  end
  message:reply{embed = embed}
  return {success = "stfu"}
end

return command