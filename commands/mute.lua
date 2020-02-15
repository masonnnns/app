command = {}

local durationTable = {
	--["s"] = {1, "Second"},
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
local cache = require("/app/server.lua")

command.info = {
  Name = "Mute",
  Alias = {},
  Usage = "mute <user> <optional duration> <reason>",
  Category = "Moderation",
  Description = "Suspend a user's ability to talk in your server.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  local mutedRole, botRole = cache.getCache("role",message.guild.id,data.mutedrole), cache.getCache("roleh",message.guild.id,client.user.id)
  if data.mutedrole == "nil" then
    return {success = false, msg = "**Config Error:** You don't have a muted role setup."}
  elseif message.guild:getRole(data.mutedrole) == nil then
    return {success = false, msg = "**Config Error:** The setup muted role was deleted."}
  elseif mutedRole.position >= botRole.position then
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
    elseif cache.getCache("user",message.guild.id,user.id).roles[data.mutedrole] ~= nil then
      return {success = false, msg = "You cannot mute people who're already muted."}
    else -- done with the pre-errors
      local duration = getDuration({args[1], args[2], (args[3] == nil and "FBBBB6DE2AA74C3C9570D2D8DB1DE31EADB66113C96034A7ADB21243754D7683" or args[3])})
      if args[3] == nil then
        local reason = "No Reason Provided."
        user:addRole(message.guild:getRole(data.mutedrole))
        data.modData.actions[1+#data.modData.actions] = {type = "mute", duration = "Permanent", moderator = message.author.id, user = user.id, case = 1+#data.modData.cases}
        data.modData.cases[1+#data.modData.cases] = {type = "mute", reason = reason, moderator = message.author.id, user = user.id, duration = "Permanent", id = 0}
        if data.modlog ~= "nil" and message.guild:getChannel(data.modlog) ~= nil then
          local msg = message.guild:getChannel(data.modlog):send{embed = { title = "Mute - Case "..#data.modData.cases, fields = { { name = "Member", value = user.mentionString.." (`"..user.id.."`)", inline = true, }, { name = "Duration", value = "Permanent", inline = true, }, { name = "Reason", value = reason, inline = false, }, { name = "Responsible Moderator", value = message.author.mentionString.." (`"..message.author.id.."`)", inline = false, }, }, color = 10038562, }}
          data.modData.cases[#data.modData.cases].id = msg.id
        end
        return {success = true, msg = "**"..user.username.."** has been muted. `[Case #"..#data.modData.cases.."]`"}
      elseif durationTable[table.concat(duration.char,"")] == nil then
        local reason = (table.concat(args," ",3))
        user:addRole(message.guild:getRole(data.mutedrole))
        data.modData.actions[1+#data.modData.actions] = {type = "mute", duration = "Permanent", moderator = message.author.id, user = user.id, case = 1+#data.modData.cases}
        data.modData.cases[1+#data.modData.cases] = {type = "mute", reason = reason, moderator = message.author.id, user = user.id, duration = "Permanent", id = 0}
        config.updateConfig(message.guild.id,data)
        if data.modlog ~= "nil" and message.guild:getChannel(data.modlog) ~= nil then
          local msg = message.guild:getChannel(data.modlog):send{embed = { title = "Mute - Case "..#data.modData.cases, fields = { { name = "Member", value = user.mentionString.." (`"..user.id.."`)", inline = true, }, { name = "Duration", value = "Permanent", inline = true, }, { name = "Reason", value = reason, inline = false, }, { name = "Responsible Moderator", value = message.author.mentionString.." (`"..message.author.id.."`)", inline = false, }, }, color = 10038562, }}
          data.modData.cases[#data.modData.cases].id = msg.id
        end
        return {success = true, msg = "**"..user.username.."** has been muted. `[Case #"..#data.modData.cases.."]`"}
      else
        if tonumber(table.concat(duration.numb,"")) * durationTable[table.concat(duration.char,"")][1] <= 0 then
          return {success = false, msg = "Invalid duration."}
        else
          local reason = (args[4] == nil and "No Reason Provided." or table.concat(args," ",4))
          data.modData.actions[1+#data.modData.actions] = {type = "mute", duration = os.time() + tonumber(table.concat(duration.numb,"")) * durationTable[table.concat(duration.char,"")][1], moderator = message.author.id, user = user.id, case = 1+#data.modData.cases}
          user:addRole(message.guild:getRole(data.mutedrole))
          data.modData.cases[1+#data.modData.cases] = {type = "mute", reason = reason, moderator = message.author.id, user = user.id, duration = table.concat(duration.numb,"").." "..durationTable[table.concat(duration.char,"")][2]..(tonumber(table.concat(duration.numb,"")) == 1 and "" or "s"), id = 0}
          config.updateConfig(message.guild.id,data)
          if data.modlog ~= "nil" and message.guild:getChannel(data.modlog) ~= nil then
            local msg = message.guild:getChannel(data.modlog):send{embed = { title = "Mute - Case "..#data.modData.cases, fields = { { name = "Member", value = user.mentionString.." (`"..user.id.."`)", inline = true, }, { name = "Duration", value = table.concat(duration.numb,"").." "..durationTable[table.concat(duration.char,"")][2]..(tonumber(table.concat(duration.numb,"")) == 1 and "" or "s"), inline = true, }, { name = "Reason", value = reason, inline = false, }, { name = "Responsible Moderator", value = message.author.mentionString.." (`"..message.author.id.."`)", inline = false, }, }, color = 10038562, }}
            data.modData.cases[#data.modData.cases].id = msg.id
          end
          return {success = true, msg = "**"..user.username.."** has been muted. `[Case #"..#data.modData.cases.."]`"}
        end
      end
    end
  end
end

return command