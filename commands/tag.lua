command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")

command.info = {
  Name = "tag",
  Alias = {},
  Usage = "addmod <name>",
  Category = "Utility",
  Description = "Have the bot reply with the specified tag name.",
  PermLvl = 1,
} 

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if data.tags.enabled == false then return {success = false, msg = "This command is disabled. Say **"..data.general.prefix.."config tags toggle** to enable it."} end
  if args[2] == nil then return {success = false, msg = "You must specify a tag."} end
  for a,b in pairs(data.tags.tags) do
    if b.name:lower() == args[2]:lower() then
      message:reply(b.content)
      if data.tags.delete then
        message:delete()
      end
      return {success = "stfu"}
    end
  end
  return {success = false, msg = "No tag was found by that name."}
end

return command