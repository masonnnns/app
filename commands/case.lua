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
  if args[2] == nil then return {success = false, msg = "You must provide a **case to view** in argument 2."} end
  if tonumber(args[2]) == nil then return {success = false, msg = "**Invalid argument** - Argument 2 must be a number. ```"..config.getConfig(message.guild.id).general.prefix..command.info.Usage.."```"} end
  local data = config.getConfig(message.guild.id)
  if data.moderation.cases[tonumber(args[2])] == nil then return {success = false, msg = "**Case "..args[2].."** doesn't exist."} end
  local case = data.moderation.cases[tonumber(args[2])]
  local type = (case.moderator == client.user.id and "Automatic " or "")..""..string.sub(case.type,1,1):upper()..string.sub(case.type,2)
  local embed = {
    title = type.." Case "..args[2],
    fields = {},
    footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
  }
  embed.fields[1+#embed.fields] = {name = "User", value = client:getUser(case.user).tag.." (`"..case.user.."`)", inline = false}
  embed.fields[1+#embed.fields] = {name = "Moderator", value = client:getUser(case.moderator).tag.." (`"..case.moderator.."`)", inline = false}
  if case.duration then embed.fields[#embed.fields].inline = true embed.fields[1+#embed.fields] = {name = "Duration", value = case.duration, inline = true} end
  embed.fields[1+#embed.fields] = {name = "Reason", value = case.reason, inline = false}
  message:reply{embed = embed}
  return {success = "stfu"}
end

return command