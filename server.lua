local discordia = require('discordia')

local client = discordia.Client {
	logFile = 'mybot.log',
	cacheAllMembers = false,
	autoReconnect = true,
}

local uptimeOS 
local timer = require('timer')
local json = require('json')
local http = require("coro-http")
local Date = discordia.Date
local statusEnum = {online = 1, idle = 2, dnd = 3, offline = 4}
local statusText = {'Online', 'Idle', 'Do Not Disturb', 'Offline'}
local loggingCache = {members = {}, channels = {},}
local config = {}

local function getPermission(message,id)
	if id == nil then id = message.author.id end
	if message.guild:getMember(id) == nil then
		return 0
	elseif id == client.owner.id then
		--print('owner')
		return 5
	elseif id == message.guild.owner.id then
		--print('guild owner')
		return 3
	elseif message.guild:getMember(id):hasPermission("administrator") == true then
		--print('admin')
		return 2
	elseif message.guild:getMember(id):hasPermission("manageGuild") == true then
		--print('admin')
		return 2
	elseif config[message.guild.id].modrole ~= nil and message.guild:getMember(id):hasRole(config[message.guild.id].modrole) == true then
		--print('modrole')
		return 1
	else 
		return 0
 	end
end	

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

local function plural(num)
  return num == 1 and "" or "s"
end

local function getTimeString(seconds)
	local minutes = math.floor(seconds / 60)
	seconds = seconds % 60
	local hours = math.floor(minutes / 60)
	minutes = minutes % 60
	local days = math.floor(hours / 24)
	hours = hours % 24
	local s
	if days > 0 then
		s = days .. " day" .. plural(days)
		if hours > 0 then
			s = s .. ", " .. hours .. " hour" .. plural(hours)
		end
	elseif hours > 0 then
		s = hours .. " hour" .. plural(hours)
		if minutes > 0 then
			s = s .. ", " .. minutes .. " minute" .. plural(minutes)
		end
	elseif minutes > 0 then
		s = minutes .. " minute" .. plural(minutes)
		if seconds > 0 then
			s = s .. ", " .. seconds .. " second" .. plural(seconds)
		end
	else
		s = seconds .. " second" .. plural(seconds)
	end
	return days.." day"..plural(days)..", "..hours.." hour"..plural(hours)..", "..minutes.." minute"..plural(minutes)..", "..seconds.." second"..plural(seconds)
end

local function addConfig(id)
	config[id] = {
		prefix = "!!",
    automod = {enabled = false, types = {invites = {false,0}, mentions = {false,3}, spoilers = {false,2}, newline = {false,10}, filter = {false,0}}},
    tags = {enabled = false, tags = {}, delete = false},
    terms = {"fuck","ass","cunt","dick","penis","butt","kys","bitch","cock","sex","intercourse",":middle_finger:","discordgg.ga"},
    modlog = "nil",
		modrole = "nil",
    auditlog = "nil",
		modData = {cases = {}, actions = {}}, -- {type = "mute", reason = "", duration = os.time() / "perm", mod = userID, user = userID}
		deletecmd = true,
		modonly = false,
		mutedRole = "nil",
    auditignore = {},
    --memberCache = {},
    purgeignore = {["551794917584666625"] = 1000}
	}
	
end

local function addModlog(message,table)
config[message.guild.id].modData.cases[1+#config[message.guild.id].modData.cases] = table
 if config[message.guild.id].modlog == "nil" or message.guild:getChannel(config[message.guild.id].modlog) == nil then else
      local case = table
      local color 
      if string.lower(case.type) == "ban" then
        color = 15158332
      elseif string.lower(case.type) == "kick" then
        color = 15105570
      elseif string.lower(case.type) == "mute" then
        color = 10038562
      elseif string.lower(case.type) == "warn" then
        color = 11027200
      else
        color = 2067276
      end
      local reply = message.guild:getChannel(config[message.guild.id].modlog):send{embed = {
        title = "**Case "..#config[message.guild.id].modData.cases.."** - "..case.type:upper(),
        description = "**User:** "..client:getUser(case.user).name.."#"..client:getUser(case.user).discriminator.." (`"..client:getUser(case.user).id.."`)\n**Moderator:** "..client:getUser(case.mod).name.."#"..client:getUser(case.mod).discriminator.." (`"..client:getUser(case.mod).id.."`)"..(case.duration ~= "" and "\n**Duration:** "..case.duration or "").."\n**Reason:** "..case.reason,
        color = color
      }}
  end
end

print("[DB]: Starting Data Loading Process.")
local decode = json.decode(io.open("./data.txt","r"):read())
for a,b in pairs(decode) do
	addConfig(a)
	for c,d in pairs(b) do
		if config[a][c] ~= nil then
			config[a][c] = d
		else
			print("[DB]: Guild "..a.." doesn't have the "..c.." value in it, so it is using defualt settings.")
		end
	end
	--config[a] = b
  config[a].purgeignore = {}
	print("[DB]: Guild "..a.."'s data was successfully loaded.")
end
print("[DB]: All guilds have been successfully loaded.")

local function sepMsg(msg)
	local Args = {}
	local Command = msg
	for Match in Command:gmatch("[^%s]+") do
	table.insert(Args, Match)
	end;
	local Data = {
	["MessageData"] = Message;
	["Args"] = Args;
	}
	return Args
end

local commands = {
  --[[
  {command = "ping", desc = "Tests the bot's connection to Discord.", usage = "ping", shorthand = {}, execute = function(message,args) 
	end};
  --]]
	{command = "test", desc = "x.", usage = "test", shorthand = {}, execute = function(message,args) 
    local xd = http.request("POST","https://pastebin.com/api/api_post",{api_dev_key = "13791d55520a8b1d687fab4d679f6540", api_option = "psate", api_paste_code = "xdd"})
    for a,b in pairs(xd) do print(a,b) if type(b) == "table" then for c,d in pairs(b) do print(c,d) end end end
	end};
  {command = "ping", desc = "Tests the bot's connection to Discord.", usage = "ping", shorthand = {}, execute = function(message,args) 
		--print(discordia.Client.ping)
    local m = message:reply(":ping_pong: Ping?")
    local latency = m.createdAt - message.createdAt
    m:setContent(":ping_pong: Pong! `"..math.max(latency).."ms`")
    return {success = "stfu", msg = "Pong!", emoji = "ping"}
	end};
  {command = "purge", desc = "Bulk delete messages from a channel.", usage = "purge <number of messages>", shorthand = {}, execute = function(message,args) 
	  if getPermission(message) < 2 then
      return {success = false, msg = "You don't have permissions to run this command.", timer = 3000}
    elseif args[2] == nil then
      return {success = false, msg = "You must specify how many messages to delete."}
    elseif tonumber(args[2]) == nil then 
      return {success = false, msg = "Argument 2 must be a number."}
    elseif tonumber(args[2]) > 100 or tonumber(args[2]) < 2 then
      return {success = false, msg = "Argument 2 must be between 2 and 100."}
    elseif message.guild:getMember(client.user.id):hasPermission("manageMessages") ~= true then
      return {success = false, msg = "I need the **Manage Messages** permission to do this."}
    else
      local num = 0
      message:delete()
      local msgs = message.channel:getMessages(tonumber(args[2]))
      config[message.guild.id].purgeignore[message.channel.id] = 0
      for a,items in pairs(msgs) do if math.floor(items.createdAt) + 1209600 >= os.time() then config[message.guild.id].purgeignore[message.channel.id] = config[message.guild.id].purgeignore[message.channel.id] + 1 else table.remove(msgs,a) end end
      num = config[message.guild.id].purgeignore[message.channel.id]
      if config[message.guild.id].purgeignore[message.channel.id] <= 1 then config[message.guild.id].purgeignore[message.channel.id] = 0 end
      local purge = message.channel:bulkDelete(msgs)
      if purge then
        if config[message.guild.id] and config[message.guild.id].auditlog ~= "nil" and message.guild:getChannel(config[message.guild.id].auditlog) then
        message.guild:getChannel(config[message.guild.id].auditlog):send{embed = {title = "**Bulk Message Deletion**", fields = {{name = "Amount of Messages", value = (num).." message"..(num == 1 and "" or "s"), inline = true},{name = "Message Location", value = message.channel.mentionString, inline = true}}, color = 3447003 }}
        end
        return {success = true, msg = "Purged **"..(num).."** message"..(num == 1 and "" or "s").."."}
      else
        config[message.guild.id].purgeignore[message.channel.id] = 0
        return {success = false, msg = "Failed to purge messages."}
      end
    end
  end};
  {command = "uptime", desc = "Sees how long the bot has been online.", usage = "uptime", shorthand = {"up"}, execute = function(message,args) 
		message:reply{embed = {
      title = "**Uptime**",
      description = getTimeString(os.time() - uptimeOS)..".",
      footer = {text = "Responding to "..message.author.name},
      color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
    }}
    return {success = "stfu", msg = "Pong!", emoji = "ping"}
	end};
	{command = "prefix", desc = "Change your server's prefix.", usage = "prefix <new prefix>", shorthand = {}, execute = function(message,args)
		if getPermission(message) < 2 then
      return {success = false, msg = "You don't have permissions to run this command.", timer = 3000}
    elseif args[2] == nil then
			return {success = false, msg = "You must provide a new prefix."}
		elseif string.len(args[2]) > 15 then
			return {success = false, msg = "Your prefix must be less than 15 characters."}
		else
			config[message.guild.id].prefix = args[2]
			return {success = true, msg = "The prefix has been changed."}
		end
	end};
	{command = "dicksize", desc = "Tells you how long your dick is.", usage = "dicksize <optional mention>", shorthand = {"ppsize","penissize",}, execute = function(message,args) 
		local size = math.max(math.random(13.5,1.6)).." inches"
		if #message.mentionedUsers >= 1 then
			return {success = true, msg = message.guild.members:get(message.mentionedUsers[1][1]).name.." measures to **"..size.."**."}
		else
			return {success = true, msg = "You measure **"..size.."**."}
		end
	end};
	{command = "kick", desc = "Kicks a user from the Discord server.", usage = "kick <@user> <optional reason>", shorthand = {"boot","begon"}, execute = function(message,args) 
		if getPermission(message) < 1 then
			return {success = false, msg = "You don't have permissions to run this command.", timer = 3000}
		elseif #message.mentionedUsers == 0 or not args[2] == "<@!"..tostring(message.mentionedUsers[1][1])..">" or not args[2] == "<@"..tostring(message.mentionedUsers [1][1])..">" then
			return {success = false, msg = "You must mention a user in argument 2."}
		elseif message.guild.members:get(message.mentionedUsers[1][1]).id == client.user.id then
			return {success = false, msg = "I cannot kick myself!"}
		elseif getPermission(message,message.guild.members:get(message.mentionedUsers[1][1]).id) >= getPermission(message) then
			return {success = false, msg = "You cannot kick people with a higher permission level than you."}
		elseif message.guild:getMember(client.user.id):hasPermission("kickMembers") ~= true then
			return {success = false, msg = "I need the **Kick Members** permission to do this."}
		else
			local user
      local reason
			local success,msg = pcall(function()
				reason = (args[3] == nil and "No Reason Provided" or table.concat(args," ",3))
				user = message.guild.members:get(message.mentionedUsers[1][1])
				message.guild:getMember((message.mentionedUsers[1][1])):kick(reason)
			end)
			if success then
        addModlog(message,{type = "Kick", duration = "", reason = reason, user = message.mentionedUsers[1][1], mod = message.author.id})
				return {success = true, msg = "Successfully kicked **"..user.name.."**!"}
			else
				return {success = false, msg = "An unexpected error occured, **please report this to our support team!**```"..msg.."```"}
			end		
		end
	 end};
	 {command = "whois", desc = "Gets information on a specified user or yourself.", usage = "whois <optional user>", shorthand = {"w"}, execute = function(message,args) 
		local user
		if args[2] == nil or #message.mentionedUsers <= 0 then
			user = message.author
		elseif args[2] == "<@!"..message.mentionedUsers[1][1]..">" or args[2] == "<@"..message.mentionedUsers[1][1]..">" then
			user = message.guild.members:get(message.mentionedUsers[1][1])
		else
			user = message.author
		end
		if getPermission(message) < 1 then
			return {success = false, msg = "You don't have permissions to run this command.", timer = 3000}
		elseif user == nil or user == "" then
			return {success = false, msg = "No user found."}
		else
			local roles = {}
			for _,items in pairs(message.guild:getMember(user.id).roles) do roles[1 + #roles] = message.guild:getRole(items).mentionString end
			message:reply{embed = {
				title = "**Whois Lookup Results**",
				description = "**Mention:** "..user.mentionString.."\n**Username:** "..user.username.."#"..user.discriminator.." (`"..user.id.."`)"..(message.guild:getMember(user.id).nickname ~= nil and "\n**Nickname:** "..message.guild:getMember(user.id).nickname or "").."\n**Created At:** "..Date.fromSnowflake(user.id):toISO(' ', '').."\n**Joined At:** "..(message.guild:getMember(user.id).joinedAt and message.guild:getMember(user.id).joinedAt:gsub('%..*', ''):gsub('T', ' ') or "ERROR").."\n**Status:** "..message.guild:getMember(user.id).status.."\n**Roles ["..#message.guild:getMember(user.id).roles.."]:** "..(#message.guild:getMember(user.id).roles == 0 and "No roles to list!" or table.concat(roles,", ")),
				thumbnail = {
					url = user:getAvatarURL()
				},
				footer = {
					text = "Responding to "..message.author.name
				},
				color = (message.guild:getMember(user.id).highestRole.color == 0 and 3066993 or message.guild:getMember(user.id).highestRole.color),
			}}
			return {success = "stfu", msg = user.name}
		end
	end};
	{command = "yesno", desc = "Have AA-R0N make a yes, no choice for you.", usage = "yesno", shorthand = {"yn"}, execute = function(message,args) 
		local num = math.random(1,2)
		if config[message.guild.id].modonly and getPermission(message) < 1 then
			return {success = false, msg = "You don't have permissions to run this command.", timer = 3000}
		elseif num == 1 then
			return {success = true, msg = "I choose **yes!**"}
		else
			return {success = true, msg = "I choose **no!**"}
		end
	end};
	{command = "restart", desc = "restart the bot", usage = "restart", shorthand = {}, execute = function(message,args) 
		if getPermission(message) >= 5 then
      if args[2] ~= nil then client:stop() return {success = "stfu", msg = ""} end
      message:reply(":ok_hand: restarting bot!")
      os.exit()
      os.exit()
      os.exit()
      return {success = true, msg = "restart", emoji = "thumbs-up"}
    else
      return {success = "stfu", msg = "xd"}
    end
	end};
	{command = "mute", desc = "Suspend a user's ability to talk in your server.", usage = "mute <@mention> <optional duration> <optional reason>", shorthand = {"shutup"}, execute = function(message,args) 
		if getPermission(message) < 1 then
			return {success = false, msg = "You don't have permissions to run this command.", timer = 3000}
		elseif config[message.guild.id].mutedRole == "nil" or message.guild:getRole(config[message.guild.id].mutedRole) == nil then
			return {success = false, msg = "**Config Error:** You don't have a muted role setup, or the one setup was deleted."}
		elseif #message.mentionedUsers == 0 or not args[2] == "<@!"..tostring(message.mentionedUsers[1][1])..">" or not args[2] == "<@"..tostring(message.mentionedUsers [1][1])..">" then
			return {success = false, msg = "You must mention a user in argument 2."}
		elseif message.guild.members:get(message.mentionedUsers[1][1]).id == client.user.id then
			return {success = false, msg = "I cannot mute myself!"}
		elseif getPermission(message,message.guild.members:get(message.mentionedUsers[1][1]).id) >= getPermission(message) then
			return {success = false, msg = "You cannot mute people with a higher permission level than you."}
		elseif message.guild:getMember(message.mentionedUsers[1][1]):hasRole(config[message.guild.id].mutedRole) then
			return {success = false, msg = "You cannot mute people who're already muted."}
		elseif message.guild:getMember(client.user.id):hasPermission("manageRoles") ~= true then
			return {success = false, msg = "I need the **Manage Roles** permission to do this."}
		else
			if args[3] == nil then
				local reason = "No Reason Provided."
				config[message.guild.id].modData.actions[1+#config[message.guild.id].modData.actions] = {type = "mute", duration = "permanent", mod = message.author.id, user = message.mentionedUsers[1][1]}
				message.guild:getMember(message.mentionedUsers[1][1]):addRole(config[message.guild.id].mutedRole)
        addModlog(message,{type = "Mute", duration = "permanent", mod = message.author.id, user = message.mentionedUsers[1][1], reason = reason})
				return {success = true, msg = "Successfully muted **"..message.guild:getMember(message.mentionedUsers[1][1]).name.."**!"}
			end
			local duration = getDuration(args)
			if durationTable[table.concat(duration.char,"")] == nil then
				local reason = (table.concat(args," ",3))
				config[message.guild.id].modData.actions[1+#config[message.guild.id].modData.actions] = {type = "mute", duration = "permanent", mod = message.author.id, user = message.mentionedUsers[1][1]}
				message.guild:getMember(message.mentionedUsers[1][1]):addRole(config[message.guild.id].mutedRole)
        addModlog(message,{type = "Mute", duration = "permanent", mod = message.author.id, user = message.mentionedUsers[1][1], reason = reason})
        return {success = true, msg = "Successfully muted **"..message.guild:getMember(message.mentionedUsers[1][1]).name.."**!"}
			else
				if tonumber(table.concat(duration.numb,"")) * durationTable[table.concat(duration.char,"")][1] <= 0 then
          return {success = false, msg = "Invalid duration."}
        else
          local reason = (args[4] == nil and "No Reason Provided." or table.concat(args," ",4))
          config[message.guild.id].modData.actions[1+#config[message.guild.id].modData.actions] = {type = "mute", duration = os.time() + tonumber(table.concat(duration.numb,"")) * durationTable[table.concat(duration.char,"")][1], mod = message.author.id, user = message.mentionedUsers[1][1]}
          message.guild:getMember(message.mentionedUsers[1][1]):addRole(config[message.guild.id].mutedRole)
          addModlog(message,{type = "Mute", duration = table.concat(duration.numb,"").." "..durationTable[table.concat(duration.char,"")][2]..(tonumber(table.concat(duration.numb,"")) == 1 and "" or "s"), mod = message.author.id, user = message.mentionedUsers[1][1], reason = reason})
          return {success = true, msg = "Successfully muted **"..message.guild:getMember(message.mentionedUsers[1][1]).name.."** for **"..table.concat(duration.numb,"").." "..durationTable[table.concat(duration.char,"")][2]..(tonumber(table.concat(duration.numb,"")) == 1 and "" or "s").."**!"}
			  end
      end
		end
	end};
{command = "case", desc = "View a specific modlog.", usage = "case <number>", shorthand = {}, execute = function(message,args) 
		if getPermission(message) < 1 then
			return {success = false, msg = "You don't have permissions to run this command.", timer = 3000}
    elseif args[2] == nil or tonumber(args[2]) == nil then
      return {success = false, msg = "Argument 2 must be a case number."}
    elseif config[message.guild.id].modData.cases[tonumber(args[2])] == nil then
      return {success = false, msg = "Invalid case number provided."}
    else
      local case = config[message.guild.id].modData.cases[tonumber(args[2])] 
      if case.type == "warn" then action = "Warning" elseif string.lower(case.type) == "kick" then action = "Kick" elseif string.lower(case.duration) == "permanent" then action = "Permanent "..case.type.."" else action = case.type..(case.duration ~= "" and " for "..case.duration or "") end
      message:reply{embed = {
				title = "**Case "..args[2].."**",
        description = "**Action:** "..action.."\n**User:** "..client:getUser(case.user).name.."#"..client:getUser(case.user).discriminator.." (`"..client:getUser(case.user).id.."`)\n**Moderator:** "..client:getUser(case.mod).name.."#"..client:getUser(case.mod).discriminator.." (`"..client:getUser(case.mod).id.."`)\n**Reason:** "..case.reason,
				footer = {
					text = "Responding to "..message.author.name,
				},
				color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
			}}
        return {success = "stfu", msg = "xd"}
    end
	end};
  {command = "warn", desc = "Warn a user.", usage = "warn <@mention> <reason>", shorthand = {}, execute = function(message,args)
    if getPermission(message) < 1 then
			return {success = false, msg = "You don't have permissions to run this command.", timer = 3000}
		elseif #message.mentionedUsers == 0 or not args[2] == "<@!"..tostring(message.mentionedUsers[1][1])..">" or not args[2] == "<@"..tostring(message.mentionedUsers [1][1])..">" then
			return {success = false, msg = "You must mention a user in argument 2."}
		elseif message.guild.members:get(message.mentionedUsers[1][1]).id == client.user.id then
			return {success = false, msg = "I cannot warn myself!"}
		elseif getPermission(message,message.guild.members:get(message.mentionedUsers[1][1]).id) >= getPermission(message) then
			return {success = false, msg = "You cannot warn people with a higher permission level than you."}
		else
      local reason = (args[3] == nil and "No Reason Provided." or table.concat(args," ",3))
      addModlog(message,{type = "Warn", duration = "", mod = message.author.id, user = message.mentionedUsers[1][1], reason = reason})
      message.guild.members:get(message.mentionedUsers[1][1]):getPrivateChannel():send("⛔ **You've been warned in "..message.guild.name.."!**\n*Please do not continue to break the rules.*\n\n**Reason:** "..reason)
      return {success = true, msg = "Successfully warned **"..message.guild.members:get(message.mentionedUsers[1][1]).name.."**."}
    end   
  end};
  {command = "config", desc = "Edit your guild's configuration settings.", usage = "config <type> <value>", shorthand = {}, execute = function(message,args) 
		local arg = (args[2] == nil and "7BBED07D913F65BACA2E07D1498AD3280559D30C87A7DA56AC7E8C6D33BE1E60" or string.lower(args[2]))
    local serverData = config[message.guild.id]
    if getPermission(message) < 2 then
      return {success = false, msg = "You don't have permissions to run this command.", timer = 3000}
    elseif arg == "modonly" then
      serverData.modonly = not serverData.modonly
      return {success = true, msg = "**"..(serverData.modonly and "Enabled" or "Disabled").."** the **mod-only** setting."}
    elseif arg == "delmsg" then
      serverData.deletecmd = not serverData.deletecmd
      return {success = true, msg = "**"..(serverData.deletecmd and "Enabled" or "Disabled").."** the **delete invocation message** setting."}
    elseif arg == "modlog" then 
      if #message.mentionedChannels == 0 then
        if serverData.modlog == "nil" then
          return {success = false, msg = "You must mention a new modlog channel."}
        else
          serverData.modlog = "nil"
          return {success = true, msg = "**Disabled** the **modlog**."}
        end
      else
        serverData.modlog = message.mentionedChannels[1][1]
        return {success = true, msg = "Set the **modlog channel** to **"..message.guild:getChannel(message.mentionedChannels[1][1]).name.."**."}
      end
    elseif arg == "auditlog" then 
      if #message.mentionedChannels == 0 then
        if serverData.auditlog == "nil" then
          return {success = false, msg = "You must mention a new auditlog channel."}
        else
          serverData.auditlog = "nil"
          return {success = true, msg = "**Disabled** the **auditlog**."}
        end
      else
        serverData.auditlog = message.mentionedChannels[1][1]
        return {success = true, msg = "Set the **audit channel** to **"..message.guild:getChannel(message.mentionedChannels[1][1]).name.."**."}
      end
    elseif arg == "mutedrole" then
      if #message.mentionedRoles == 0 then
        return {success = false, msg = "You must mention a new muted role."}
      else
        serverData.mutedRole = message.mentionedRoles[1][1]
        return {success = true, msg = "Set the **muted role** to **"..message.guild:getRole(message.mentionedRoles[1][1]).name.."**."}
      end
    elseif arg == "modrole" then
      if #message.mentionedRoles == 0 then
        return {success = false, msg = "You must mention a new mod role."}
      else
        serverData.modrole = message.mentionedRoles[1][1]
        return {success = true, msg = "Set the **mod role** to **"..message.guild:getRole(message.mentionedRoles[1][1]).name.."**."}
      end
    elseif arg == "automod" then
      if args[3] ~= nil then string.lower(args[3]) end
      if args[3] == nil then 
        serverData.automod.enabled = not serverData.automod.enabled
        return {success = true, msg = "**"..(serverData.automod.enabled and "Enabled" or "Disabled").."** the **automod** plugin."}
      elseif args[3] == "filter" then
        if args[4] == nil then
          serverData.automod.types.filter[1] = not serverData.automod.types.filter[1]
          return {success = true, msg = "**"..(serverData.automod.types.filter[1] and "Enabled" or "Disabled").."** the **words filter**."}
        elseif string.lower(args[4]) == "view" then
          local result
          local success, error = pcall(function() result = message.author:getPrivateChannel():send{embed = {title = "**Filtered Words in "..message.guild.name.."**", description = "The following could contain sensitive content. Click to view.\n||"..table.concat(serverData.terms,", ").."||", footer = {text = "From "..message.guild.name}, color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color)}} end)
            if success and result ~= nil then
              return {success = true, msg = "I DMed you the list of filtered words.", "thumbs_up"}
            else
              return {success = false, msg = "I couldn't DM you. Adjust your privacy settings and try again."}    
            end  
      else
          local found
          for a,items in pairs(serverData.terms) do if string.lower(items) == string.lower(table.concat(args," ",4)) then found = items table.remove(serverData.terms,a) end end
          if found == nil or found == "" then
            serverData.terms[1+#serverData.terms] = string.lower(table.concat(args," ",4))
            message:delete()
            return {success = true, msg = 'Added that term to the **words filter**.'} 
          else
            return {success = true, msg = 'Removed that term from the **words filter**.'}
          end
        end
    elseif args[3] == "newline" then
      if args[4] == nil then
        serverData.automod.types.newline[1] = not serverData.automod.types.newline[1]
        return {success = true, msg = "**"..(serverData.automod.types.newline[1] and "Enabled" or "Disabled").."** the **newline filter**."}
      elseif tonumber(args[4]) == nil then
        return {success = false, msg = "The **newline limit** must be a **number**."}
      else
        serverData.automod.types.newline[2] = (tonumber(args[4]) <= 1 and 2 or tonumber(args[4]))
        return {success = true, msg = "Set the **newline limit** to **"..tostring(serverData.automod.types.newline[2]).."**."}
      end
    elseif args[3] == "spoilers" then
      if args[4] == nil then
        serverData.automod.types.spoilers[1] = not serverData.automod.types.spoilers[1]
        return {success = true, msg = "**"..(serverData.automod.types.spoilers[1] and "Enabled" or "Disabled").."** the **spoiler filter**."}
      elseif tonumber(args[4]) == nil then
        return {success = false, msg = "The **spoiler limit** must be a **number**."}
      else
        serverData.automod.types.spoilers[2] = (tonumber(args[4]) <= 1 and 2 or tonumber(args[4]))
        return {success = true, msg = "Set the **spoiler limit** to **"..tostring(serverData.automod.types.spoilers[2]).."**."}
      end
    elseif args[3] == "mentions" then
      if args[4] == nil then
        serverData.automod.types.mentions[1] = not serverData.automod.types.mentions[1]
        return {success = true, msg = "**"..(serverData.automod.types.mentions[1] and "Enabled" or "Disabled").."** the **mentions filter**."}
      elseif tonumber(args[4]) == nil then
        return {success = false, msg = "The **mention limit** must be a **number**."}
      else
        serverData.automod.types.mentions[2] = (tonumber(args[4]) <= 0 and 1 or tonumber(args[4]))
        return {success = true, msg = "Set the **mention limit** to **"..tostring(serverData.automod.types.mentions[2]).."**."}
      end
    elseif args[3] == "invites" then
       serverData.automod.types.invites[1] = not serverData.automod.types.invites[1]
       return {success = true, msg = "**"..(serverData.automod.types.invites[1] and "Enabled" or "Disabled").."** the **invites filter**."}
    else
       return {success = false, msg = "Invalid **second argument**."}
    end
  elseif arg == "tags" then
    if args[3] ~= nil then args[3] = string.lower(args[3]) end
    if args[3] == nil then
      serverData.tags.enabled = not serverData.tags.enabled
      return {success = true, msg = "**"..(serverData.tags.enabled and "Enabled" or "Disabled").."** the **tags** plugin."}
    elseif args[3] == "add" then
      for _,items in pairs(serverData.tags.tags) do if string.lower(items.term) == string.lower(args[4]) then return {success = false, msg = "A tag already exists with that name, try editing it."} end end
      if args[5] == nil then return {success = false, msg = "You must provide content for the tag."} end
      serverData.tags.tags[1+#serverData.tags.tags] = {term = string.lower(args[4]), response = string.sub(message.content,(string.len(args[1])+string.len(args[2])+string.len(args[3])+string.len(args[4])+6))}
      return {success = true, msg = "Added the **"..args[4].."** tag."}
    elseif args[3] == "view" then
      if #serverData.tags.tags == 0 then return {success = false, msg = "There are no tags to display."} end
      if args[4] == nil then
        local txt = ""
        for _,items in pairs(serverData.tags.tags) do txt = txt.."\n**"..items.term.."** - "..(string.len(items.response) >= 50 and string.sub(items.response,1,47).."..." or items.response) end
        message:reply{embed = {
          title = "**Tags**",
          description = (#serverData.tags.tags == 0 and "None set!" or "View a tag's complete content with "..serverData.prefix.."config tags view <name>\n"..txt),
          footer = {text = "Responding to "..message.author.name},
          color =  (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
        }}
      else
          local found
          for _,items in pairs(serverData.tags.tags) do if string.lower(args[4]) == string.lower(items.term) then found = items break end end
          if found == nil or found == "" then
            return {success = false, msg = "No tag exists with that name."}
          else
              message:reply{embed = {
              title = "**Tag: "..found.term.."**",
              description = "```\n"..found.response.."\n```",
              footer = {text = "Responding to "..message.author.name},
              color =  (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
            }}
          end
      end
      return {success = "stfu", msg = ""}
    elseif args[3] == "delmsg" then
      serverData.tags.delete = not serverData.tags.delete
      return {success = true, msg = "**"..(serverData.tags.delete and "Enabled" or "Disabled").."** tag **invocation deletion**."}
    elseif args[3] == "edit" then
      if args[5] == nil then return {success = false, msg = "You must provide content for the tag."} end
      local found
      for _,items in pairs(serverData.tags.tags) do if string.lower(args[4]) == string.lower(items.term) then found = items break end end
      if found == nil or found == "" then
        return {success = false, msg = "No tag exists with that name."}
      else
        found.response = string.sub(message.content,(string.len(args[1])+string.len(args[2])+string.len(args[3])+string.len(args[4])+6)) --table.concat(args," ",5)
        for _,items in pairs(serverData.tags.tags) do if string.lower(args[4]) == string.lower(items.term) then items = found break end end
        return {success = true, msg = "Edited the **"..found.term.."** tag."}
      end
    elseif args[3] == "delete" then
      local found
      for a,items in pairs(serverData.tags.tags) do if string.lower(args[4]) == string.lower(items.term) then found = a break end end
      if found == nil or found == "" then
        return {success = false, msg = "No tag exists with that name."}
      else
        table.remove(serverData.tags.tags,found)
        return {success = true, msg = "Deleted the **"..args[4].."** tag."}
      end
    else
      return {success = false, msg = "Invalid **second argument**."}
    end
  else
      local configs = config[message.guild.id]
      message:reply{embed = {
        title = "**Configuration Settings**",
        fields = { -- array of fields
					{
						name = "General Settings",
						value = "**Command Prefix:** "..configs.prefix.."\n**Delete Invocation Message:** "..tostring(configs.deletecmd).."\n**Mod-Only Commands:** "..tostring(configs.modonly).."\n**Moderator Role:** "..(configs.modrole == "nil" and "None Set!" or message.guild:getRole(configs.modrole).mentionString).."\n**Muted Role:** "..(configs.mutedRole == "nil" and "None Set!" or message.guild:getRole(configs.mutedRole).mentionString).."\n**Audit Log:** "..(configs.auditlog == "nil" and "None Set!" or message.guild:getChannel(configs.auditlog).mentionString).."\n**Mod Log:** "..(configs.modlog == "nil" and "None Set!" or message.guild:getChannel(configs.modlog).mentionString),
						inline = false,
					},
          {
            name = "Automod Settings",
            value = "**Enabled:** "..tostring(configs.automod.enabled).."\n**Words Filter:** "..(configs.automod.types.filter[1] and "Enabled. (Terms: "..#configs.terms..")" or "Disabled.").."\n**Newline Filter:** "..(configs.automod.types.newline[1] and "Enabled. (Limit: "..configs.automod.types.newline[2]..")" or "Disabled.").."\n**Spoiler Filter:** "..(configs.automod.types.spoilers[1] and "Enabled (Limit: "..configs.automod.types.spoilers[2]..")" or "Disabled.").."\n**Mentions Filter:** "..(configs.automod.types.mentions[1] and "Enabled (Limit: "..configs.automod.types.mentions[2]..")" or "Disabled.").."\n**Invites Filter:** "..(configs.automod.types.invites[1] and "Enabled." or "Disabled."),
            inline = true,
          },
          {
            name = "Tag Settings",
            value = "**Enabled:** "..tostring(configs.tags.enabled).."\n**Delete Invocation:** "..tostring(configs.tags.delete).."\n**Tags:** "..#configs.tags.tags,
            inline = true      
          },
        },
        color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
        footer = {text = "Responding to "..message.author.name}  
      }}
      return {success="stfu",msg="xd"}
    end    
	end};
  {command = "tag", desc = "Sends a predefined message in response to a keyword.", usage = "tag <tag name>", shorthand = {}, execute = function(message,args) 
	  if config[message.guild.id].tags.enabled == false then
        return {success = "stfu", msg = ""}
    elseif getPermission(message) < 1 then
        return {success = false, msg = "You don't have permissions to run this command.", timer = 3000}	
    elseif args[2] == nil then
        return {success = false, msg = "You must provide a tag."}
    elseif #config[message.guild.id].tags.tags == 0 then
        return {success = false, msg = "There are currently no tags setup."}
    else
        for _,items in pairs(config[message.guild.id].tags.tags) do
          if string.lower(items.term) == string.lower(args[2]) then
            message:reply(items.response)
            if config[message.guild.id].tags.delete and not config[message.guild.id].tags.deletecmd then message:delete() end
            return {success = "stfu", msg = "xd"}
          end
        end
        return {success = false, msg = "There is no tag with that name."}
    end
	end};
  {command = "moderations", desc = "Views all active moderations in the server.", usage = "moderations", shorthand = {}, execute = function(message,args) 
		if getPermission(message) < 1 then return {success = false, msg = "You don't have permissions to run this command.", timer = 3000} end
    local moderations = ""
    local num  = 0
    for _,items in pairs(config[message.guild.id].modData.actions) do 
        if items.duration == "permanent" or tonumber(items.duration) ~= nil and os.time() <= items.duration then
            num = num + 1
            moderations = moderations.."\n**"..client:getUser(items.user).tag.."** (`"..client:getUser(items.user).id.."`) `["..string.upper(items.type).."]` - "..(items.duration == "permanent" and "Permanent" or getTimeString(items.duration - os.time())) 
        end 
    end
    if moderations == "" then return {success = false, msg = "There are no active moderations in the server."} end
	  message:reply{embed = {
      title = "**Moderations** - "..tostring(num),
      description = moderations,
      color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
      footer = {text = "Responding to "..message.author.name}        
    }}
    return {success = "stfu", msg = ""}
  end};
  {command = "ban", desc = "Ban a user from your server.", usage = "mute <@mention> <optional duration> <optional reason>", shorthand = {"banish"}, execute = function(message,args) 
		if getPermission(message) < 1 then
			return {success = false, msg = "You don't have permissions to run this command.", timer = 3000}
		elseif #message.mentionedUsers == 0 or not args[2] == "<@!"..tostring(message.mentionedUsers[1][1])..">" or not args[2] == "<@"..tostring(message.mentionedUsers [1][1])..">" then
			return {success = false, msg = "You must mention a user in argument 2."}
		elseif message.guild.members:get(message.mentionedUsers[1][1]).id == client.user.id then
			return {success = false, msg = "I cannot ban myself!"}
		elseif getPermission(message,message.guild.members:get(message.mentionedUsers[1][1]).id) >= getPermission(message) then
			return {success = false, msg = "You cannot ban people with a higher permission level than you."}
		elseif message.guild:getMember(client.user.id):hasPermission("kickMembers") ~= true then
			return {success = false, msg = "I need the **Ban Members** permission to do this."}
		else
			if args[3] == nil then
				local reason = "No Reason Provided."
				config[message.guild.id].modData.actions[1+#config[message.guild.id].modData.actions] = {type = "ban", duration = "permanent", mod = message.author.id, user = message.mentionedUsers[1][1]}
				local member = message.guild:getMember(message.mentionedUsers[1][1])
        member:getPrivateChannel():send("⛔ **You've been permanently banned in "..message.guild.name.."!**\n\n**Reason:** "..reason)
        message.guild:banUser(message.mentionedUsers[1][1],reason,7)
        addModlog(message,{type = "Ban", duration = "permanent", mod = message.author.id, user = message.mentionedUsers[1][1], reason = reason})
				return {success = true, msg = "Successfully banned **"..member.name.."**!"}
			end
			local duration = getDuration(args)
			if durationTable[table.concat(duration.char,"")] == nil then
				local reason = (table.concat(args," ",3))
				config[message.guild.id].modData.actions[1+#config[message.guild.id].modData.actions] = {type = "ban", duration = "permanent", mod = message.author.id, user = message.mentionedUsers[1][1]}
				local member = message.guild:getMember(message.mentionedUsers[1][1])
        member:getPrivateChannel():send("⛔ **You've been permanently banned in "..message.guild.name.."!**\n\n**Reason:** "..reason)
        message.guild:banUser(message.mentionedUsers[1][1],reason,7)
        addModlog(message,{type = "Ban", duration = "permanent", mod = message.author.id, user = message.mentionedUsers[1][1], reason = reason})
        return {success = true, msg = "Successfully banned **"..member.name.."**!"}
			else
				if tonumber(table.concat(duration.numb,"")) * durationTable[table.concat(duration.char,"")][1] <= 0 then
          return {success = false, msg = "Invalid duration."}
        else
          local reason = (args[4] == nil and "No Reason Provided." or table.concat(args," ",4))
          config[message.guild.id].modData.actions[1+#config[message.guild.id].modData.actions] = {type = "ban", duration = os.time() + tonumber(table.concat(duration.numb,"")) * durationTable[table.concat(duration.char,"")][1], mod = message.author.id, user = message.mentionedUsers[1][1]}
          local member = message.guild:getMember(message.mentionedUsers[1][1])
          member:getPrivateChannel():send("⛔ **You've been temporarily banned in "..message.guild.name.."!**\n*You will be unbanned automatically when the duration expires.*\n\n**Reason:** "..reason.."\n**Duration:** "..table.concat(duration.numb,"").." "..durationTable[table.concat(duration.char,"")][2]..(tonumber(table.concat(duration.numb,"")) == 1 and "" or "s"))
          message.guild:banUser(message.mentionedUsers[1][1],reason,7)
          addModlog(message,{type = "Ban", duration = table.concat(duration.numb,"").." "..durationTable[table.concat(duration.char,"")][2]..(tonumber(table.concat(duration.numb,"")) == 1 and "" or "s"), mod = message.author.id, user = message.mentionedUsers[1][1], reason = reason})
          return {success = true, msg = "Successfully banned **"..member.name.."** for **"..table.concat(duration.numb,"").." "..durationTable[table.concat(duration.char,"")][2]..(tonumber(table.concat(duration.numb,"")) == 1 and "" or "s").."**!"}
			  end
      end
		end
	end};
}

function checkMany(check,content,id)
local detect = false
	if check == "curse" then
		for _,items in pairs(config[id].terms) do
			if string.match(content,items) then
				detect = true
			end
		end
	elseif check == "role" then
		local n = 0
		for _,items in pairs(content) do
			n = n + 1
			if n >= 3 then
				detect = true
			end
		end
	elseif check == "invites" then
		local msg = sepMsg(content)
		for _,items in pairs(msg) do
			items = string.lower(items)
			if string.match(items,"discord.gg") then
				return true
			elseif string.match(items,"discordapp.com/invite") then
				return true
			end
		end
		return false
	end
	return detect
end

function autoMod(msg)
--if "x" == "x" then return end
local message = msg
local a, b = string.gsub(message.content,"\n","")
local c, d = string.gsub(message.content,"||","")
if message.author.bot == false  then
	if (b + 1 >= tonumber(config[message.guild.id].automod.types.newline[2]) == true) and config[message.guild.id].automod.types.newline[1] and config[message.guild.id].automod.enabled then
		message:delete()
		local reply = message:reply(message.author.mentionString..", too many lines.")
		--message.author:getPrivateChannel():send("⛔ **You've been warned in "..message.guild.name.."!**\nPlease do not exceed the newline limit of 5 in "..message.guild.name..".\n\nHere's your message if you wish to edit it:```"..message.content.."```")
		timer.sleep(3000)
		reply:delete()
		return false
	elseif checkMany("curse",string.lower(msg.content),message.guild.id) == true and config[message.guild.id].automod.types.filter[1] and config[message.guild.id].automod.enabled then
		message:delete()
		local reply = message:reply(message.author.mentionString..", watch your language.")
		--[[if config[message.guild.id].modlog ~= "nil" then
			message.guild:getChannel(config[message.guild.id].modlog):send{embed = {
				title = "**AUT0 M0D3RAT0R - BAD W0RD5**",
				description = "**User:** "..message.author.mentionString.."\n**Message:**\n```"..msg.content.."```",
				footer = {
					text = "xd"
				}
			}
		}
		end--]]
		timer.sleep(3000)
		reply:delete()
		return false
	elseif checkMany("invites",msg.content,msg.guild.id) == true and config[message.guild.id].automod.types.invites[1] and config[message.guild.id].automod.enabled or string.match(message.content,"discord.gg") and client:getInvite(xd) and config[message.guild.id].automod.types.invites[1] and config[message.guild.id].automod.enabled then
		message:delete()
		local reply = message:reply(message.author.mentionString..", no invites.")
		timer.sleep(3000)
		reply:delete()
		return false
	elseif d/2 >= config[message.guild.id].automod.types.spoilers[2] and config[message.guild.id].automod.types.spoilers[1] and config[message.guild.id].automod.enabled then
		message:delete()
		local reply = message:reply(message.author.mentionString..", too many spoilers.")
		timer.sleep(3000)
		reply:delete()
		return false
	elseif #msg.mentionedRoles + #msg.mentionedUsers >= config[message.guild.id].automod.types.mentions[2] and config[message.guild.id].automod.types.mentions[1] and config[message.guild.id].automod.enabled  then
		message:delete()
		local reply = message:reply(message.author.mentionString..", no mass-mentioning.")
		timer.sleep(3000)
		reply:delete()
		return false
	else
		print("[NEW MESSAGE] [AUTHOR: "..string.upper(message.author.username).."] [GUILD: "..string.upper(message.guild.name).."] [CHANNEL: "..string.upper(message.channel.name).."]: "..message.content)
    return true
	end
end
end

local function test(prefix,msg)
local Command = string.sub(msg, string.len(tostring(prefix))+1, string.len(msg))
local Args = {}
for Match in Command:gmatch("[^%s]+") do
table.insert(Args, Match)
end;
local Data = {
["MessageData"] = Message;
["Args"] = Args;
}
if string.sub(msg, 0, string.len(tostring(prefix))) ~= prefix then
return "notCommand"
else
return Args
end
end

local sandbox = setmetatable({
	os = { }
}, { __index = _G })
local function code(str)
    return string.format('```\n%s```', str)
end

local function printLine(...)
    local ret = {}
    for i = 1, select('#', ...) do
        local arg = tostring(select(i, ...))
        table.insert(ret, arg)
	end
    return table.concat(ret, '\t')
end

local function exec(arg, msg)

    if not arg then return end
    if msg.author ~= msg.client.owner then return false end

    arg = arg:gsub('```\n?', '') -- strip markdown codeblocks

    local lines = {}

    sandbox.message = msg

    sandbox.print = function(...)
        table.insert(lines, printLine(...))
    end

    sandbox.p = function(...)
        table.insert(lines, prettyLine(...))
    end

    local fn, syntaxError = load(arg, 'DiscordBot', 't', sandbox)
    if not fn then return syntaxError end

    local success, runtimeError = pcall(fn)
    if not success then return runtimeError end

    lines = table.concat(lines, '\n')

    if #lines > 1990 then -- truncate long messages
        lines = lines:sub(1, 1990)
    end

    return lines
        
end 

client:on('ready', function()
  print("[DEBUG]: Starting Bot.")
  uptimeOS = os.time()
	print("[DEBUG]: Logged in as "..client.user.name..".")
	client:setGame("booting... please wait")
  print("[DEBUG]: Starting cache loading / loop.")
  for _,guilds in pairs(client.guilds) do
    for _,member in pairs(guilds.members) do
      print("[DEBUG] [CACHE] [USER]: "..member.name.." ("..member.id..") in "..guilds.name.." ("..guilds.id..") has loaded.")
      if loggingCache.members[member.guild.id] == nil then loggingCache.members[member.guild.id] = {} end
      if loggingCache.members[member.guild.id][member.id] == nil then loggingCache.members[member.guild.id][member.id] = {} end 
      if loggingCache.members[member.guild.id][member.id].roles == nil then loggingCache.members[member.guild.id][member.id].roles = {} for _,items in pairs(member.roles) do loggingCache.members[member.guild.id][member.id].roles[1+#loggingCache.members[member.guild.id][member.id].roles] = items.id end end
      if loggingCache.members[member.guild.id][member.id].nickname == nil then loggingCache.members[member.guild.id][member.id].nickname = (member.nickname ~= nil and member.nickname or "nil")  end
      --timer.sleep(100)
    end
    for _,channel in pairs(guilds.textChannels) do
      print("[DEBUG] [CACHE] [CHANNEL]: "..channel.name.." ("..channel.id..") in "..channel.guild.name.." ("..channel.guild.id..") has loaded.")
      if loggingCache.channels[channel.guild.id] == nil then loggingCache.channels[channel.guild.id] = {} end
      if loggingCache.channels[channel.guild.id][channel.id] == nil then loggingCache.channels[channel.guild.id][channel.id] = {} end
      if loggingCache.channels[channel.guild.id][channel.id].name == nil then loggingCache.channels[channel.guild.id][channel.id].name = channel.name end
    end
    --timer.sleep(500)
  end
  print("[DEBUG]: Done.")
  client:setGame("!!help | AA-R0N")
	print("[DEBUG]: Starting timed-actions loop.")
  print("[DEBUG]: Done.")
  print("[DEBUG]: Bot processes completed, serving on "..#client.guilds.." guilds.")
	while true do
		for id,items in pairs(config) do
      if client:getGuild(id) == nil or config[id] == nil then
        --//print('not in guild')
      else
        for num,itemz in pairs(items.modData.actions) do
          if tonumber(itemz.duration) ~= nil and os.time() >= itemz.duration then
            if itemz.type == "mute" then
              if items.mutedRole ~= "nil" and client:getGuild(id):getMember(itemz.user) then
                if client:getGuild(id):getMember(itemz.user):hasRole(items.mutedRole) then
                  client:getGuild(id):getMember(itemz.user):removeRole(items.mutedRole)
                end
              end
              print('[DEBUG] [UNMUTE]: '..itemz.user.." has been unmuted in "..id)
              local case = {type = "Auto-Unmute", duration = "", reason = "Mute duration expired.", user = itemz.user, mod = client.user.id}
              config[id].modData.cases[1+#config[id].modData.cases] = case
              if config[id].modlog ~= "nil" and client:getGuild(id):getChannel(config[id].modlog) then
                client:getGuild(id):getChannel(config[id].modlog):send{embed = {
                  title = "**Case "..#config[id].modData.cases.."** - "..case.type:upper(),
                  description = "**User:** "..client:getUser(case.user).name.."#"..client:getUser(case.user).discriminator.." (`"..client:getUser(case.user).id.."`)\n**Moderator:** "..client:getUser(case.mod).name.."#"..client:getUser(case.mod).discriminator.." (`"..client:getUser(case.mod).id.."`)"..(case.duration ~= "" and "\n**Duration:** "..case.duration or "").."\n**Reason:** "..case.reason,
                  color = 2067276
                }}
              end
            elseif itemz.type == "ban" then
              print('[DEBUG] [UNBAN]: '..itemz.user.." has been unbanned in "..id)
              if client:getGuild(id):getBan(itemz.user) ~= nil then client:getGuild(id):unbanUser(itemz.user,"Ban duration expired.") end
              local case = {type = "Auto-Unban", duration = "", reason = "Ban duration expired.", user = itemz.user, mod = client.user.id}
              config[id].modData.cases[1+#config[id].modData.cases] = case
              if config[id].modlog ~= "nil" and client:getGuild(id):getChannel(config[id].modlog) then
                client:getGuild(id):getChannel(config[id].modlog):send{embed = {
                  title = "**Case "..#config[id].modData.cases.."** - "..case.type:upper(),
                  description = "**User:** "..client:getUser(case.user).name.."#"..client:getUser(case.user).discriminator.." (`"..client:getUser(case.user).id.."`)\n**Moderator:** "..client:getUser(case.mod).name.."#"..client:getUser(case.mod).discriminator.." (`"..client:getUser(case.mod).id.."`)"..(case.duration ~= "" and "\n**Duration:** "..case.duration or "").."\n**Reason:** "..case.reason,
                  color = 2067276
                }}
              end
            end
            table.remove(items.modData.actions,num)
          end
        end
      end
    end
		timer.sleep(1000)
	end
end)

client:on('memberUpdate', function(member)
  --if member.guild == nil then return end
  if loggingCache.members[member.guild.id] == nil then loggingCache.members[member.guild.id] = {} end
  if loggingCache.members[member.guild.id][member.id] == nil then loggingCache.members[member.guild.id][member.id] = {} end 
  if loggingCache.members[member.guild.id][member.id].roles == nil then loggingCache.members[member.guild.id][member.id].roles = {} for _,items in pairs(member.roles) do loggingCache.members[member.guild.id][member.id].roles[1+#loggingCache.members[member.guild.id][member.id].roles] = items.id end return end
  if loggingCache.members[member.guild.id][member.id].nickname == nil then loggingCache.members[member.guild.id][member.id].nickname = (member.nickname ~= nil and member.nickname or "nil") return end
  if config[member.guild.id] == nil or config[member.guild.id].auditlog == "nil" or member.guild:getChannel(config[member.guild.id].auditlog) == nil then return end
  local auditLog
  for a,items in pairs(member.guild:getAuditLogs()) do if math.floor(items.createdAt) == os.time() or math.floor(items.createdAt) == os.time() - 1 or math.floor(items.createdAt) == os.time() + 1 or math.floor(items.createdAt) == os.time() + 2 and items.guild.id == member.guild.id then auditLog = items break end end
  if auditLog == nil then print('no log found?') return end
  if auditLog.actionType == 25 then
    local newRoles = {}
    loggingCache.members[member.guild.id][member.id].roles = {}
    for _,items in pairs(member.roles) do  loggingCache.members[member.guild.id][member.id].roles[1+#loggingCache.members[member.guild.id][member.id].roles] = items.id end
  elseif loggingCache.members[member.guild.id][member.id].nickname ~= member.nickname then
    member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "**Nickname Changed**", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = true, }, { name = "Old Nickname", value = (loggingCache.members[member.guild.id][member.id].nickname == "nil" and member.username or loggingCache.members[member.guild.id][member.id].nickname), inline = false, }, { name = "New Nickname", value = (member.nickname == nil and member.username or member.nickname), inline = true, }, }, color = 15844367, }}
    loggingCache.members[member.guild.id][member.id].nickname = (member.nickname == nil and "nil" or member.nickname)
  end
end)

client:on("messageDelete",function(message)
  if message.guild == nil then return end
  if config[message.guild.id].purgeignore[message.channel.id] ~= nil and config[message.guild.id].purgeignore[message.channel.id] >= 1 then config[message.guild.id].purgeignore[message.channel.id] = config[message.guild.id].purgeignore[message.channel.id] - 1 return end
  if message.author.bot then return end
  if config[message.guild.id] and config[message.guild.id].auditlog ~= "nil" and message.guild:getChannel(config[message.guild.id].auditlog) then
    message.guild:getChannel(config[message.guild.id].auditlog):send{embed ={
      title = "**Message Deleted**",
      fields = {
        {
					name = "Message Author",
					value = message.author.mentionString.." (`"..message.author.id.."`)",
					inline = true,
				},
        {
					name = "Message Location",
					value = message.channel.mentionString,
					inline = true,
				},
        {
					name = "Message Content",
					value = message.content,
					inline = false,
				},
      },
      color = 3447003,
    }}
  end
end)

client:on('guildCreate', function(guild)
local hm = guild.members
end)

client:on('guildDelete', function(guild)
local him = guild.members
end)

client:on('channelCreate', function(channel)
  if channel.guild == nil then return end
  if config[channel.guild.id] == nil then return end
  local auditLog
  for a,items in pairs(channel.guild:getAuditLogs()) do if math.floor(items.createdAt) == os.time() or math.floor(items.createdAt) == os.time() - 1 or math.floor(items.createdAt) == os.time() + 1 or math.floor(items.createdAt) == os.time() + 2 and items.guild.id == channel.guild.id then auditLog = items break end end
  if auditLog == nil or auditLog:getMember() == nil or auditLog.actionType ~= 10 then
    if config[channel.guild.id] and config[channel.guild.id].auditlog ~= "nil" and channel.guild:getChannel(config[channel.guild.id].auditlog) then
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = "**Channel Created**", fields = { { name = "Channel", value = channel.mentionString, inline = true, }, { name = "Channel Location", value = (channel.category == nil and "Not in a category" or channel.category.name), inline = true, }, }, color = 11027200, }}
    end
  else
    if config[channel.guild.id] and config[channel.guild.id].auditlog ~= "nil" and channel.guild:getChannel(config[channel.guild.id].auditlog) then
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = "**Channel Created**", fields = { { name = "Channel", value = channel.mentionString, inline = true, }, { name = "Channel Location", value = (channel.category == nil and "Not in a category" or channel.category.name), inline = true, }, { name = "Responsible Member", value = auditLog:getMember().mentionString.." (`"..auditLog:getMember().id.."`)", inline = false, }, }, color = 11027200, }}
    end
  end
end)

client:on('channelDelete', function(channel)
  if config[channel.guild.id] == nil then return end
  local auditLog
  for a,items in pairs(channel.guild:getAuditLogs()) do if math.floor(items.createdAt) == os.time() or math.floor(items.createdAt) == os.time() - 1 or math.floor(items.createdAt) == os.time() + 1 or math.floor(items.createdAt) == os.time() + 2 and items.guild.id == channel.guild.id then auditLog = items break end end
  if auditLog == nil or auditLog:getMember() == nil or auditLog.actionType ~= 12 then
    if config[channel.guild.id] and config[channel.guild.id].auditlog ~= "nil" and channel.guild:getChannel(config[channel.guild.id].auditlog) then
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = "**Channel Deleted**", fields = { { name = "Channel", value = "#"..channel.name, inline = true, }, { name = "Channel Location", value = (channel.category == nil and "Wasn't in a category" or channel.category.name), inline = true, }, }, color = 10038562, }}
    end
  else
    if config[channel.guild.id] and config[channel.guild.id].auditlog ~= "nil" and channel.guild:getChannel(config[channel.guild.id].auditlog) then
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = "**Channel Deleted**", fields = { { name = "Channel", value = "#"..channel.name, inline = true, }, { name = "Channel Location", value = (channel.category == nil and "Wasn't in a category" or channel.category.name), inline = true, }, { name = "Responsible Member", value = auditLog:getMember().mentionString.." (`"..auditLog:getMember().id.."`)", inline = false, }, }, color = 10038562, }}
    end
  end
end)

client:on('roleCreate', function(channel)
  if config[channel.guild.id] == nil then return end
  local auditLog
  for a,items in pairs(channel.guild:getAuditLogs()) do if math.floor(items.createdAt) == os.time() or math.floor(items.createdAt) == os.time() - 1 or math.floor(items.createdAt) == os.time() + 1 or math.floor(items.createdAt) == os.time() + 2 and items.guild.id == channel.guild.id then auditLog = items break end end
  if auditLog == nil or auditLog:getMember() == nil or auditLog.actionType ~= 30 then
    if config[channel.guild.id] and config[channel.guild.id].auditlog ~= "nil" and channel.guild:getChannel(config[channel.guild.id].auditlog) then
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = "**Role Created**", fields = { { name = "Role", value = channel.mentionString, inline = true,}, }, color = 10181046, }}
    end
  else
    if config[channel.guild.id] and config[channel.guild.id].auditlog ~= "nil" and channel.guild:getChannel(config[channel.guild.id].auditlog) then
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = "**Role Created**", fields = { { name = "Role", value = channel.mentionString, inline = true, }, { name = "Responsible Member", value = auditLog:getMember().mentionString.." (`"..auditLog:getMember().id.."`)", inline = false, }, }, color = 10181046, }}
    end
  end
end)

client:on('roleDelete', function(channel)
  if config[channel.guild.id] == nil then return end
  local auditLog
  for a,items in pairs(channel.guild:getAuditLogs()) do if math.floor(items.createdAt) == os.time() or math.floor(items.createdAt) == os.time() - 1 or math.floor(items.createdAt) == os.time() + 1 or math.floor(items.createdAt) == os.time() + 2 and items.guild.id == channel.guild.id then auditLog = items break end end
  if auditLog == nil or auditLog:getMember() == nil or auditLog.actionType ~= 32 then
    if config[channel.guild.id] and config[channel.guild.id].auditlog ~= "nil" and channel.guild:getChannel(config[channel.guild.id].auditlog) then
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = "**Role Deleted**", fields = { { name = "Role", value = channel.name, inline = true,}, }, color = 7419530, }}
    end
  else
    if config[channel.guild.id] and config[channel.guild.id].auditlog ~= "nil" and channel.guild:getChannel(config[channel.guild.id].auditlog) then
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = "**Role Deleted**", fields = { { name = "Role", value = channel.name, inline = true, }, { name = "Responsible Member", value = auditLog:getMember().mentionString.." (`"..auditLog:getMember().id.."`)", inline = false, }, }, color = 7419530, }}
    end
  end
end)

client:on('memberJoin', function(member)
if loggingCache.members[member.guild.id] == nil then loggingCache.members[member.guild.id] = {} end
if loggingCache.members[member.guild.id][member.id] == nil then loggingCache.members[member.guild.id][member.id] = {} end 
if loggingCache.members[member.guild.id][member.id].roles == nil then loggingCache.members[member.guild.id][member.id].roles = {} for _,items in pairs(member.roles) do loggingCache.members[member.guild.id][member.id].roles[1+#loggingCache.members[member.guild.id][member.id].roles] = items.id end end
if loggingCache.members[member.guild.id][member.id].nickname == nil then loggingCache.members[member.guild.id][member.id].nickname = (member.nickname ~= nil and member.nickname or "nil") end
if config[member.guild.id] and config[member.guild.id].auditlog ~= "nil" and member.guild:getChannel(config[member.guild.id].auditlog) then
  member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "**Member Joined**", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = true, }, { name = "Created At", value = Date.fromSnowflake(member.id):toISO(' ', ''), inline = true, }, }, color = 3066993, }}
end
if member.bot then return end
	if config[member.guild.id] then
		for _,items in pairs(config[member.guild.id].modData.actions) do
			if items.user == member.id then
				if items.type == "mute" then
					member:addRole(config[member.guild.id].mutedRole)
				end
			end 
		end
	end
end)

client:on('memberLeave', function(member)
if config[member.guild.id] and config[member.guild.id].auditlog ~= "nil" and member.guild:getChannel(config[member.guild.id].auditlog) then
  local roles = {}
  for _,items in pairs(member.roles) do roles[1+#roles] = items.mentionString end
  member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "**Member Left**", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = true, }, { name = "Roles", value = (#roles == 0 and "No Roles!" or table.concat(roles,", ")), inline = true, }, }, color = 15158332, }}
end
end)

client:on("messageUpdate", function(message)
    if message.guild == nil or message.author.bot then return end
	  if config[message.guild.id] and config[message.guild.id].auditlog ~= "nil" and message.guild:getChannel(config[message.guild.id].auditlog) then
    if message.channel:getMessage(message.id) == nil or message.channel:getMessage(message.id).oldContent == nil then return end
    local oldMsg
    for a,items in pairs(message.channel:getMessage(message.id).oldContent) do oldMsg = items end
    message.guild:getChannel(config[message.guild.id].auditlog):send{embed ={
      title = "**Message Edited**",
      fields = {
        {
					name = "Message Author",
					value = message.author.mentionString.." (`"..message.author.id.."`)",
					inline = true,
				},
        {
					name = "Message Location",
					value = message.channel.mentionString,
					inline = true,
				},
        {
					name = "Old Message Content",
					value = oldMsg,
					inline = false,
				},
        {
					name = "New Message Content",
					value = message.content,
					inline = false,
				},
      },
      color = 15105570,
    }}
  end
  if message.guild ~= nil or message.author.bot ~= true then
		autoMod(message)
	end
end)

client:on('messageCreate', function(message)
	if message.guild == nil then return end
  if config[message.guild.id] == nil then
			addConfig(message.guild.id)
		end
		local configForSaving = {
			guilds = {},
		}
		for a,b in pairs(config) do
			configForSaving.guilds[a] = b
		end
		file = io.open("./data.txt", "w+") 
		file:write(json.encode(configForSaving.guilds))
		file:close()
	if message.author.bot then return end
  if loggingCache.members[message.guild.id] == nil then loggingCache.members[message.guild.id] = {} end
  if loggingCache.members[message.guild.id][message.author.id] == nil then loggingCache.members[message.guild.id][message.author.id] = {} end 
  if loggingCache.members[message.guild.id][message.author.id].roles == nil then loggingCache.members[message.guild.id][message.author.id].roles = {} for _,items in pairs(message.guild:getMember(message.author.id).roles) do loggingCache.members[message.guild.id][message.author.id].roles[1+#loggingCache.members[message.guild.id][message.author.id].roles] = items.id end end
  if loggingCache.members[message.guild.id][message.author.id].nickname == nil then loggingCache.members[message.guild.id][message.author.id].nickname = (message.guild:getMember(message.author.id).nickname ~= nil and message.guild:getMember(message.author.id).nickname or "nil") end
	if message.guild ~= nil or message.author.bot ~= true then -- if it's not a guild or its a bot
		--print("all guild data was saved because "..message.author.username.." sent a message")
		--if string.match("discordgg.ga",string.lower(message.content)) then message:delete() end
		if string.lower(message.content) == "!!prefix?" then message:reply("The prefix for **"..message.guild.name.."** is **"..config[message.guild.id].prefix.."**") end
		local isCommand = test(config[message.guild.id].prefix,message.content)
    if isCommand == "notCommand" or isCommand[1] == nil then
			autoMod(message)
		else
			local cmd 
			for _,items in pairs(commands) do
				if string.lower(items.command) == string.lower(isCommand[1]) then
					cmd = items
					break
				elseif #items.shorthand ~= 0 then
					for _,itemz in pairs(items.shorthand) do
						if string.lower(itemz) == string.lower(isCommand[1]) then
							cmd = items 
							break
						end
					end
				end
			end
			if cmd == nil or cmd == "" then
				autoMod(message)
			else
        print("[DEBUG] [COMMAND EXECUTED]: "..message.author.name.." ("..message.author.id..") in "..message.guild.name.." ("..message.guild.id..") ran the "..cmd.command.." command.")
				local emojis = {
					["ok"] = ":ok_hand:",
					["ping"] = ":ping_pong:",
					["tools"] = ":tools:",
					["thumbs-up"] = ":thumbsup:"
 				}
				if config[message.guild.id].modonly and getPermission(message) < 1 then return end
        local commandExecute = cmd.execute(message,isCommand)
				if config[message.guild.id].deletecmd then message:delete() end
				if commandExecute == nil or type(commandExecute) ~= "table" then message:reply(":no_entry: An unkown error occured!") return end
				if commandExecute.emoji == nil or emojis[commandExecute.emoji] == nil then commandExecute.emoji = "ok" end
				if commandExecute.success == "stfu" then return end
				if commandExecute.success then
					message:reply(emojis[commandExecute.emoji].." "..commandExecute.msg)
				else
					local reply = message:reply(":no_entry: "..commandExecute.msg)
					if commandExecute.timer ~= nil then
						timer.sleep(commandExecute.timer)
						reply:delete()
					end
				end
			end 
		end
	end
end)



client:run('Bot NDE0MDMwNDYzNzkyMDU0Mjgy.D1SnRg.p9ghEI5njoksY0UkFGHCAnV1glQ')