command = {}

local config = require("/app/config.lua")

command.info = {
  Name = "Purge",
  Alias = {},
  Usage = "purge <amount of messages 1-100>",
  Description = "Bulk Delete messages from a channel.",
  PermLvl = 2,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if tonumber(args[2]) == nil then
    return {success = false, msg = "You must provide a **number of messages to delete** in argument 2."}
  elseif tonumber(args[2]) > 100 or tonumber(args[2]) < 1 then
    return {success = false, msg = "The number of messages must be between **1 and 100**."}
  else
    local num = 0
    for a,items in pairs(msgs) do if math.floor(items.createdAt) + 1209600 >= os.time() then config[message.guild.id].purgeignore[message.channel.id] = config[message.guild.id].purgeignore[message.channel.id] + 1 else table.remove(msgs,a) end end

  end
end

return command