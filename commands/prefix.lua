command = {}

local config = require("/app/config.lua")

command.info = {
  Name = "Prefix",
  Alias = {},
  Example = "prefix <new prefix>",
  Description = "Change the server's prefix.",
  PermLvl = 2,
}

command.execute = function(message,args)
  if args[2] == nil then
    return {success = false, msg = "You must provide a **new prefix.**"}
  elseif string.len(args[2]) > 10 or string.len(args[2]) < 1 then
    return {success = false, msg = "The new prefix must be between **1 and 10 characters.**"}
  else
    local data = config.getConfig(message.guild.id)
    data.prefix = args[2]
    config.updateConfig(message.guild.id,data)
    return {success = true, msg = "Changed the prefix to **"..args[2].."**."}
  end
end

return command