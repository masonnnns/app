command = {}

local config = require("/app/config.lua")

command.info = {
  Name = "Case",
  Alias = {},
  Usage = "case <case number>",
  Description = "View information on a specific case.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if args[2] == nil then
    return {success = false, msg = "You must provide a **case number** in argument 2."}
  elseif tonumber(args[2]) == nil then
    return {success = false, msg = "Argument 2 must be a **number**."}
  elseif data.modData.cases[tonumber(args[2])] == nil then
    return {success = false, msg = "**Case "..args[2].."** doesn't exist."}
  else
    local case = data.modData.cases[tonumber(args[2])]
    if string.lower(case.type) == "warn" then
      message:reply{embed = {
        title = "Warning - Case "..args[2],
        description = "**Username:** "..client:getUser(case.user).tag.." (`"..case.user.."`)\n**Moderator:** "..client:getUser(case.moderator).tag.." (`"..case.moderator.."`)\n**Reason:** "..case.reason,
        color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
      }}
      return {success = "stfu", message = ""}
    else
      return {success = false, msg = "**Case "..args[2].."** couldn't be displayed."}
    end
  end
end

return command