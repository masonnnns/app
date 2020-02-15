command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")
local cache = require("/app/server.lua")

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
    return {success = false, msg = "You must provide a **case number** in argument 2."}
  elseif args[3] == nil then
    return {success = false, msg = "You must provide a **new reason**."}
  elseif data.modData.cases[tonumber(args[2])] == nil then
      return {success = false, msg = "**Case "..args[2].."** doesn't exist."}
  else
    local case = data.modData.cases[tonumber(args[2])]
    case.reason = table.concat(args," ",3)
    if case.id ~= nil and case.id ~= 0 and data.modlog ~= nil and message.guild:getChannel(data.modlog) ~= nil and message.guild:getChannel(data.modlog):getMessage(case.id) ~= nil then
      local embed = message.guild:getChannel(data.modlog):getMessage(case.id).embeds
      embed.fields[3].value = reason
      message.guild:getChannel(data.modlog):getMessage(case.id):setContent(embed)
    end    
  end
end

return command