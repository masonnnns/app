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
  elseif data.modData.cases[]
  end
end

return command