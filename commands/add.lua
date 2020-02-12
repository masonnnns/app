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
    return {success = false, msg = "**Config Error:** There is no "..(data.tickets.category == "nil" and "" or "valid ").."tickets category setup."}
  else
    local found = 0 for _,items in pairs(data.tickets.channels) do if items.user == message.author.id then found = found + 1 end end
    if found + 1 > data.tickets.max then
      return {success = false, msg = "You already have **"..found.." ticket"..(found == 1 and "" or "s").."** open, you cannot open anymore."}
    else
      local channel = message.guild:getChannel(data.tickets.category):createTextChannel("ticket-"..data.tickets.ticket+1)
      if channel == nil or channel == false then return {success = false, msg = "**Config Error:** I couldn't create the ticket, make sure I have permissions!"} end
      channel:setTopic('test')
      channel:setPermissions({readMessages = true})
    end
  end
end

return command