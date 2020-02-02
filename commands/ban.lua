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
  Name = "Ban",
  Alias = {},
  Usage = "ban <user> <optional duration> <reason>",
  Description = "Ban a user from the server with a set duration.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if args[2] == nil then
    return {success = false, msg = "You must provide a **member to ban** in argument 2."}
  else
    local user = utils.resolveUser(message,args[2])
    if user == false and tonumber(args[2]) ~= nil then if client:getUser(args[2]) ~= nil then user = client:getUser(args[2]) else user = false end end
    if user == false then
      return {success = false, msg = "I couldn't find the user you mentioned."}
    elseif user.id == client.user.id then
      return {success = false, msg = "I cannot "..command.info.Name:lower().." myself."}
    elseif utils.getPermission(message,client,user.id) >= utils.getPermission(message,client) then
      return {success = false, msg = "You cannot "..command.info.Name:lower().." people with **higher than or equal permissions as you.**"}
    elseif message.guild:getMember(client.user.id):hasPermission("banMembers") ~= true then
			return {success = false, msg = "I need the **Ban Members** permission to do this."}
    else -- done with the pre-errors
      local duration = getDuration({args[1], args[2], (args[3] == nil and "FBBBB6DE2AA74C3C9570D2D8DB1DE31EADB66113C96034A7ADB21243754D7683" or args[3])})
      if args[3] == nil then
        local reason = "No Reason Provided."
        message.guild:banUser(user,reason,7)
        data.modData.cases[1+#data.modData.cases] = {type = "ban", reason = reason, moderator = message.author.id, user = user.id, duration = "Permanent"}
        config.updateConfig(message.guild.id,data)
        if data.modlog ~= "nil" and message.guild:getChannel(data.modlog) ~= nil then
         message.guild:getChannel(data.modlog):send{embed = { title = "Ban - Case "..#data.modData.cases, fields = { { name = "Member", value = user.mentionString.." (`"..user.id.."`)", inline = true, }, { name = "Duration", value = "Permanent", inline = true, }, { name = "Reason", value = reason, inline = false, }, { name = "Responsible Moderator", value = message.author.mentionString.." (`"..message.author.id.."`)", inline = false, }, }, color = 15158332, }}
        end
        return {success = true, msg = "**"..user.username.."** has been banned."}
      elseif durationTable[table.concat(duration.char,"")] == nil then
        local reason = (table.concat(args," ",3))
        message.guild:banUser(user,reason,7)
        data.modData.cases[1+#data.modData.cases] = {type = "ban", reason = reason, moderator = message.author.id, user = user.id, duration = "Permanent"}
        config.updateConfig(message.guild.id,data)
        if data.modlog ~= "nil" and message.guild:getChannel(data.modlog) ~= nil then
         message.guild:getChannel(data.modlog):send{embed = { title = "Ban - Case "..#data.modData.cases, fields = { { name = "Member", value = user.mentionString.." (`"..user.id.."`)", inline = true, }, { name = "Duration", value = "Permanent", inline = true, }, { name = "Reason", value = reason, inline = false, }, { name = "Responsible Moderator", value = message.author.mentionString.." (`"..message.author.id.."`)", inline = false, }, }, color = 15158332, }}
        end
        return {success = true, msg = "**"..user.username.."** has been banned."}
      else
        if tonumber(table.concat(duration.numb,"")) * durationTable[table.concat(duration.char,"")][1] <= 0 then
          return {success = false, msg = "Invalid duration."}
        else
          local reason = (args[4] == nil and "No Reason Provided." or table.concat(args," ",4))
          data.modData.actions[1+#data.modData.actions] = {type = "ban", duration = os.time() + tonumber(table.concat(duration.numb,"")) * durationTable[table.concat(duration.char,"")][1], moderator = message.author.id, user = user.id}
          message.guild:banUser(user,reason,7)
          data.modData.cases[1+#data.modData.cases] = {type = "ban", reason = reason, moderator = message.author.id, user = user.id, duration = table.concat(duration.numb,"").." "..durationTable[table.concat(duration.char,"")][2]..(tonumber(table.concat(duration.numb,"")) == 1 and "" or "s")}
          config.updateConfig(message.guild.id,data)
          if data.modlog ~= "nil" and message.guild:getChannel(data.modlog) ~= nil then
            message.guild:getChannel(data.modlog):send{embed = { title = "Ban - Case "..#data.modData.cases, fields = { { name = "Member", value = user.mentionString.." (`"..user.id.."`)", inline = true, }, { name = "Duration", value = table.concat(duration.numb,"").." "..durationTable[table.concat(duration.char,"")][2]..(tonumber(table.concat(duration.numb,"")) == 1 and "" or "s"), inline = true, }, { name = "Reason", value = reason, inline = false, }, { name = "Responsible Moderator", value = message.author.mentionString.." (`"..message.author.id.."`)", inline = false, }, }, color = 15158332, }}
          end
          return {success = true, msg = "**"..user.username.."** has been banned."}
        end
      end
    end
  end
end

return command