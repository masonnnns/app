command = {}

local utils = require("/app/utils.lua")

command.info = {
  Name = "Slowmode",
  Alias = {},
  Usage = "slowmode <clear/1-120>",
  Category = "Moderation",
  Description = "Set the channel's slowmode.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  if message.guild:getMember("414030463792054282"):getPermissions():has("manageChannels") == false and message.guild:getMember("414030463792054282"):getPermissions():has("administrator") == false then
		return {success = false, msg = "I need the **Manage Channels** permission to do this."}
  elseif args[2] == nil then
    return {success = false, msg = "You must provide a **duration** in argument 2."}
  else
    local channel = message.guild:getChannel(message.channel.id)
    if args[2]:lower() == "clear" then
      channel:setRateLimit(0)
      return {success = true, msg = "**Cleared** this channel's slowmode."}
    elseif tonumber(args[2]) == nil then
      return {success = false, msg = "Argument 2 must be a **number** or **\"clear\"**."}
    elseif tonumber(args[2]) > 21600 or tonumber(args[2]) < 0 then
      return {success = false, msg = "Argument 2 must be between **0 and 21600**."}
    else
      channel:setRateLimit(tonumber(args[2]))
      if tonumber(args[2]) == 0 then
        return {success = true, msg = "**Cleared** this channel's slowmode."}
      else
        return {success = true, msg = "Set this channel's slowmode to **"..channel.rateLimit.." second"..(channel.rateLimit == 1 and "" or "s").." per message**."}
      end
    end
  end
end

return command