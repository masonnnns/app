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

command.info = {
  Name = "Mute",
  Alias = {},
  Usage = "mute <user> <optional duration> <reason>",
  Description = "Suspend a user's ability to talk in your server.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  
end

return command