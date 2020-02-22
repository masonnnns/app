command = {}

local cache = require("/app/server.lua")
local utils = require("/app/resolve-user.lua")

command.info = {
  Name = "Slowmode",
  Alias = {},
  Usage = "slowmode <clear/1-120>",
  Category = "Moderation",
  Description = "Set the channel's slowmode.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  if cache.getCache("getperm",message.guild.id,"manageChannels") == false and cache.getCache("getperm",message.guild.id,"administrator") == false then
		return {success = false, msg = "I need the **Manage Channels** permission to do this."}
  elseif args[2] == nil then
    return {success = false, msg = "You must provide a **duration** in argument 2."}
  else
    if args[2]:lower() == "clear" then
      message.channel:setRateLimit(0)
      return {success = true, msg = "**Cleared** this channel's slowmode."}
    elseif tonumber(args[2]) == nil then
      return {success = false, msg = "Argument 2 must be a **number** or **\"clear\"**."}
    elseif tonumber(args[2]) > 120 or tonumber(args[2]) < 0 then
      return {success = false, msg = "Argument 2 must be between **0 and 120**."}
    else
      message.channel:setRateLimit(tonumber(args[2]))
      if tonumber(args[2]) == 0 then
        return {success = true, msg = "**Cleared** this channel's slowmode."}
      else
        return {success = true, msg = "Set this channel's slowmode to **"..args[2].." second"..(tonumber(args[2]) == 1 and "" or "s").." per message**."}
      end
    end
  end
end

return command