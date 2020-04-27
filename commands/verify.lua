command = {}

local utils = require("/app/utils.lua")

command.info = {
  Name = "Verify",
  Alias = {},
}

command.execute = function(message,args,client)
  local config = require("/app/config.lua")
  local verifyUser = utils.verifyUser(message,message.author.id)
  if verifyUser.success == true then
    if message.member.name:lower() ~= verifyUser.msg.name:lower() then
      message.member:setNickname(verifyUser.msg.name)
    end
    if message.guild.roles:get(config.verifiedRole) ~= nil and message.member.roles:get(config.verifiedRole) == nil then
      message.member:addRole(config.verifiedRole)
    end
    return {success = true, msg = "Welcome to the server, **"..verifyUser.msg.name.."**"}
  else
    return {success = false, msg = verifyUser.msg}
  end
end

return command