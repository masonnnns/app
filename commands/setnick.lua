command = {}

local utils = require("/app/utils.lua")

command.info = {
  Name = "Setnick",
  Alias = {"nick","setnickname"},
  Usage = "setnick <user> <new name>",
  Category = "Utility",
  Description = "Change a member's nickname.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  if args[2] == nil then return {success = false, msg = "You must specify a member."} end
  local user = utils.resolveUser(message,args[2])
  if user == false then return {success = false, msg = "I couldn't find the user you mentioned."} end
  if user.highestRole and user.highestRole.position >= message.guild:getMember("414030463792054282").highestRole.position then
    return {success = false, msg = "I cannot "..command.info.Name:lower().." **"..user.tag.."** because their **role is higher than mine**."}
  end
  local name = (args[3] == nil and "" or table.concat(args," ",3))
  if string.len(name) > 32 then return {success = false, msg = "Nicknames must be less than 32 characters."} end
  local success, msg = user:setNickname(name)
  if type(success) == "boolean" and success == false then
    if msg == "HTTP Error 50013 : Missing Permissions" then
      return {success = false, msg = "I need the **Manage Nicknames** permission to do this."}
    else
      return {success = false, msg = "Request failed! Try again?```"..msg.."```"}
    end
  end
  if name ~= "" then
    return {success = true, msg = "Changed **"..user.tag.."**'s nickname."}
  else
    return {success = true, msg = "Reset **"..user.tag.."**'s nickname."}
  end
end

return command