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

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")

command.info = {
  Name = "Giveaway",
  Alias = {""},
  Usage = "giveaway <create/reroll/list/end> <time/giveaway ID> <product>",
  Category = "Fun",
  Description = "Host or manage giveaways in your server.",
  PermLvl = 2,
} 

command.execute = function(message,args,client)
  if args[2] == nil then return {success = false, msg = "You must specify create, reroll, list or end."} end
  args[2] = args[2]:lower()
  local data = config.getConfig(message.guild.id)
  if args[2] == "create" then
    if args[3] == nil then return {success = false, msg = "You must provide an expiration for the giveaway."} end
    local duration = getDuration(args[3])
    if durationTable[table.concat(duration.char,"")] == nil then return {success = false, msg = "Invalid duration."} end
    if tonumber(table.concat(duration.numb,"")) * durationTable[table.concat(duration.char,"")][1] <= 0 then return {success = false, msg = "Invalid duration."} end
    if tonumber(table.concat(duration.numb,"")) * durationTable[table.concat(duration.char,"")][1] > 1209600 then return {success = false, msg = "You cannot host giveaways for longer than 2 weeks."} end
    if args[4] == nil then return {success = false, msg = "You must provide a product to giveaway!"} end
    return {success = true, msg = "hosting a giveaway"}
  end
end

command.finishGiveaway = function(guild,data)
  
end

return command