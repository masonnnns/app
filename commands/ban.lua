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
  if message.guild:getMember(client.user.id):hasPermission("banMembers") == false then return {success = false, msg = "I need the **Ban Members** permission to do this."} end
  if args[2] == nil then return {success = false, msg = "You must specify a member."} end
  local user = utils.resolveUser(message,args[2])
  if user == false and tonumber(args[2]) ~= nil and client:getUser(args[2]) ~= nil then user = client:getUser(args[2]) end
  if user == false then 
    return {success = false, msg = "I couldn't find the user you mentioned."}
  elseif utils.Permlvl(message,client,user.id) >= utils.Permlvl(message,client) then
    return {success = false, msg = "You cannot "..command.info.Name:lower().." other **moderators/administrators**."}
  elseif user.highestRole and user.highestRole.position >= message.guild:getMember("414030463792054282").highestRole.position then
    return {success = false, msg = "I cannot "..command.info.Name:lower().." **"..user.tag.."** because their **role is higher than mine**."}
  elseif user.id == client.user.id then
    return {success = false, msg = "I cannot "..command.info.Name:lower().." myself."}
  elseif message.guild:getBans():get(user.id) ~= nil then
    return {success = false, msg = "**"..user.tag.."** is already banned."}
  else
    local duration = getDuration({args[1], args[2], (args[3] == nil and "NO_ARG_3" or args[3])})
    local data = config.getConfig(message.guild.id)
    if args[3] == nil or durationTable[table.concat(duration.char,"")] == nil then
      local reason = "No Reason Provided."
      if args[3] == nil then 
        reason = "No Reason Provided."
      elseif durationTable[table.concat(duration.char,"")] == nil then
        reason = table.concat(args," ",3)
      end
      message.guild:banUser(user,reason,7)
      data.moderation.cases[1+#data.moderation.cases] = {type = "ban", user = user.id, moderator = message.author.id, reason = reason, duration = "Permanent", modlog = "nil"}
      if data.general.modlog ~= "nil" and message.guild:getChannel(data.general.modlog) ~= nil then
        local modlog = message.guild:getChannel(data.general.modlog):send{embed = {
          title = "Ban - Case "..#data.moderation.cases,
          fields = {
            {name = "User", value = user.tag.." (`"..user.id.."`)", inline = false},
            {name = "Moderator", value = message.author.tag.." (`"..message.author.id.."`)",inline = true},
            {name = "Duration", value = "Permanent", inline = true},
            {name = "Reason", value = reason, inline = false},
          },
          color = 15158332,
        }}
        data.moderation.cases[#data.moderation.cases].modlog = modlog.id    
      end
      return {success = true, msg = "**"..user.tag.."** has been permanently banned. `[Case "..#data.moderation.cases.."]`"}
    else
      if tonumber(table.concat(duration.numb,"")) * durationTable[table.concat(duration.char,"")][1] <= 0 then
        return {success = false, msg = "Invalid duration."}
      else
        local reason = (args[4] == nil and "No Reason Provided." or table.concat(args," ",4))
        local durationString = table.concat(duration.numb,"").." "..durationTable[table.concat(duration.char,"")][2]..(tonumber(table.concat(duration.numb,"")) == 1 and "" or "s")
        data.moderation.cases[1+#data.moderation.cases] = {type = "ban", user = user.id, moderator = message.author.id, reason = reason, duration = durationString, modlog = "nil"}
        data.moderation.actions[1+#data.moderation.actions] = {type = "ban", duration = os.time() + tonumber(table.concat(duration.numb,"")) * durationTable[table.concat(duration.char,"")][1], moderator = message.author.id, case = #data.moderation.cases, id = user.id}
        message.guild:banUser(user,reason,7)
        if data.general.modlog ~= "nil" and message.guild:getChannel(data.general.modlog) ~= nil then
          local modlog = message.guild:getChannel(data.general.modlog):send{embed = {
            title = "Ban - Case "..#data.moderation.cases,
            fields = {
              {name = "User", value = user.tag.." (`"..user.id.."`)", inline = false},
              {name = "Moderator", value = message.author.tag.." (`"..message.author.id.."`)",inline = true},
              {name = "Duration", value = durationString, inline = true},
              {name = "Reason", value = reason, inline = false},
            },
            color = 15158332,
          }}
          data.moderation.cases[#data.moderation.cases].modlog = modlog.id    
        end
        return {success = true, msg = "**"..user.tag.."** has been banned for **"..durationString:lower().."**. `[Case "..#data.moderation.cases.."]`"}
      end
    end
  end
end

return command