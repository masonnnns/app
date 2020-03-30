command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")

command.info = {
  Name = "Reason",
  Alias = {},
  Usage = "reason <case> <new reason>",
  Category = "Moderation",
  Description = "Change the reason of a case.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if args[2] == nil or tonumber(args[2]) == nil then
    return {success = false, msg = "You must specify a case number."}
  elseif args[3] == nil then
    return {success = false, msg = "You must provide a new reason."}
  elseif data.moderation.cases[tonumber(args[2])] == nil then
      return {success = false, msg = "**Case "..args[2].."** doesn't exist."}
  else
    local case = data.moderation.cases[tonumber(args[2])]
    if case.moderator == client.user.id then return {success = false, msg = "You cannot edit the reason on an **automatic case**."} end
    if string.lower(case.reason) == string.lower(table.concat(args," ",3)) then return {success = true, msg = "Changed the reason for **Case "..args[2].."**."} end
    case.reason = table.concat(args," ",3)
    if case.modlog ~= nil and case.modlog ~= "nil" and data.general.modlog ~= nil and message.guild:getChannel(data.general.modlog) ~= nil and message.guild:getChannel(data.general.modlog):getMessage(case.modlog) ~= nil then
      local embeds = message.guild:getChannel(data.general.modlog):getMessage(case.modlog).embed
      local found
      for a,items in pairs(embeds.fields) do if items.name == "Reason" then found = a break end end
      embeds.fields[found].value = table.concat(args," ",3)
      message.guild:getChannel(data.general.modlog):getMessage(case.modlog):setEmbed(embeds)
    end
    return {success = true, msg = "Changed the reason for **Case "..args[2].."**."}    
  end
end

return command