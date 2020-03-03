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
local utils = require("/app/utils.lua")

command.info = {
  Name = "Ban",
  Alias = {"banish"},
  Usage = "ban <user> <optional duration> <reason>",
  Category = "Moderation",
  Description = "Ban a user with the set duration.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
    if message.guild:getMember("414030463792054282"):getPermissions():has("banMembers") == false and message.guild:getMember("414030463792054282"):getPermissions():has("administrator")  == false then return {success = false, msg = "I need the **Ban Members** permission to do this."} end

end

return command