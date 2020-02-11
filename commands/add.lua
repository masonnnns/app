command = {}

local cache = require("/app/server.lua")
local utils = require("/app/resolve-user.lua")
local config = require("/app/config.lua")

command.info = {
  Name = "Add",
  Alias = {"create"},
  Usage = "add <reason>",
  Category = "Tickets",
  Description = "Create a ticket with the specified reason. **[DEV]**",
  PermLvl = 3,
}

command.execute = function(message,args,client)
  if message.author.id ~= client.owner.id then return {success = "stfu"} end
  local data = config.getConfig(message.guild.id)
  if data.tickets.enabled == false then return {success = "stfu"} end
  if data.tickets.category == "nil" or message.guild:getChannel(data.tickets.category) == nil then
    return {success = false, msg = "**Config Error:** There is no tickets category setup."}
  end
end

return command