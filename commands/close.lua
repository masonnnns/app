command = {}

local cache = require("/app/server.lua")
local utils = require("/app/resolve-user.lua")
local config = require("/app/config.lua")

command.info = {
  Name = "Close",
  Alias = {},
  Usage = "close <reason>",
  Category = "Tickets",
  Description = "Close an open ticket.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if data.tickets.enabled == false then return {success = "stfu"} end
  local found = false
  for items,_ in pairs(data.tickets.channels) do if items.id == message.channel.id then found = items break end end
  if not found then return {success = "stfu", msg = "This is not a **ticket channel.**"} else
    if message.guild:getMember(message.author.id):getPermissions(message.channel) then
      message.channel:delete()
      
      return {success = "stfu"}
    else
      return {success = false, msg = "You don't have permissions to do this."}
    end
  end
end

return command