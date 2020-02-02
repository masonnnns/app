command = {}

local durationTable = {
	["min"] = {60, "Minute"},
	["mi"] = {60, "Minute"},
	["m"] = {60, "Minute"},
	["h"] = {3600, "Hour"},
	["hr"] = {3600, "Hour"},
	["d"] = {86400, "Day"},
	["w"] = {604800, "Week"},
	["mo"] = {2592000, "Month"},
	["mon"] = {2592000, "Month"},
	["y"] = {31536000, "Year"},
}

local function getDuration(Args)
	local argData = {numb = {}, char = {}, num = 0, str = string.lower(Args[3])}
	repeat
		argData.num = argData.num+1
		if tonumber(string.sub(argData.str,argData.num,argData.num)) == nil then
			argData.char[#argData.char + 1] = string.sub(argData.str,argData.num,argData.num)
		else
			argData.numb[#argData.numb + 1] = string.sub(argData.str,argData.num,argData.num)
		end
	until
	argData.num == string.len(argData.str)
	return argData
end

local config = require("/app/config.lua")
local utils = require("/app/resolve-user.lua")


command.info = {
  Name = "Mute",
  Alias = {},
  Usage = "mute <user> <optional duration> <reason>",
  Description = "Suspend a user's ability to talk in your server.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if data.mutedrole == "nil" then
    return {success = false, msg = "**Config Error:** You don't have a muted role setup."}
  elseif message.guild:getRole(data.mutedrole) == nil then
    return {success = false, msg = "**Config Error:** The setup muted role was deleted."}
  elseif message.guild:getRole(data.mutedrole).position > message.guild:getMember(client.user.id).highestRole.position then
    return {success = false, msg = "**Config Error:** The muted role is above my highest role, please move it down so I can manage it."}
  elseif args[2] == nil then
    return {success = false, msg = "You must provide a **member to mute** in argument 2."}
  else
    local user = utils.resolveUser(message,args[2])
    if user == false then
      return {success = false, msg = "I couldn't find the user you mentioned."}
    elseif user.id == client.user.id then
      return {success = false, msg = "I cannot "..command.info.Name:lower().." myself."}
    elseif utils.getPermission(message,client,user.id) >= utils.getPermission(message,client) then
      return {success = false, msg = "You cannot "..command.info.Name:lower().." people with **higher than or equal permissions as you.**"}
    elseif user:hasRole(data.mutedrole) then
      return {success = false, msg = "You cannot mute people who're already muted."}
    elseif message.guild:getMember(client.user.id):hasPermission("manageRoles") ~= true then
			return {success = false, msg = "I need the **Manage Roles** permission to do this."}
    else -- done with the pre-errors
      if args[3] == nil then
        local reason = "No reason provide"
      end
    end
  end
end

return command