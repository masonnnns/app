local discordia = require('discordia')

local client = discordia.Client {
	logFile = 'mybot.log',
	cacheAllMembers = false,
	autoReconnect = true,
}

local timer = require('timer')
local json = require('json')
local http = require("coro-http")
local Date = discordia.Date
local statusEnum = {online = 1, idle = 2, dnd = 3, offline = 4}
local statusText = {'Online', 'Idle', 'Do Not Disturb', 'Offline'}
local config = {}

local function getPermission(message,id)
	if id == nil then id = message.author.id end
	if message.guild:getMember(id) == nil then
		return 0
	elseif id == client.owner.id then
		print('owner')
		return 5
	elseif id == message.guild.owner.id then
		print('guild owner')
		return 3
	elseif message.guild:getMember(id):hasPermission("administrator") == true then
		print('admin')
		return 2
	elseif message.guild:getMember(id):hasPermission("manageGuild") == true then
		print('admin')
		return 2
	elseif config[message.guild.id].modrole ~= nil and message.guild:getMember(id):hasRole(config[message.guild.id].modrole) == true then
		print('modrole')
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

local function addConfig(id)
	config[id] = {
		prefix = "a!",
		filter = true,
		terms = {"fuck","ass","cunt","dick","penis","butt","kys","bitch","cock","sex","intercourse","🖕","discordgg.ga"},
		invites = true,
		massmentions = true,
		spoilers = true,
		maxSpoilers = 2,
		maxMentions = 3,
		newline = true,
		maxNewline = 10,
		modlog = "nil",
		modrole = "nil",
		modData = {cases = {}, actions = {}}, -- {type = "mute", reason = "", duration = os.time() / "perm", mod = userID, user = userID}
		deletecmd = true,
		modonly = false,
		mutedRole = "nil"
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
        title = "**CAS3 "..#config[message.guild.id].modData.cases.."** - "..case.type:upper(),
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
	print("[DB]: Guild "..a.."'s data was successfully loaded.")
end
print("[DB]: All guilds have been successfully loaded.")

local function sepMsg(msg)
	local Args = {}
	local Command = msg
	for Match in Command:gmatch("[^%s,]+") do
	table.insert(Args, Match)
	end;
	local Data = {
	["MessageData"] = Message;
	["Args"] = Args;
	}
	return Args
end

local commands = {
	{command = "ping", desc = "Tests the bot's connection to Discord.", usage = "ping", shorthand = {}, execute = function(message,args) 
		return {success = true, msg = "Pong!", emoji = "ping"}
	end};
	{command = "prefix", desc = "Change your server's prefix.", usage = "prefix <new prefix>", shorthand = {}, execute = function(message,args)
		if args[2] == nil then
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
				title = "**WH01S L00KUP R3SULTS**",
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
	{command = "test", desc = "test", usage = "test", shorthand = {}, execute = function(message,args) 
		newNum = tonumber(args[2])
		config[message.guild.id].modData.actions[1+#config[message.guild.id].modData.actions] = {type = "mute", duration = os.time() + newNum, mod = 1, user = message.mentionedUsers[1][1]}
		message.guild:getMember(message.mentionedUsers[1][1]):addRole(config[message.guild.id].mutedRole)
		return {success = true, msg = "result: "..os.time()+newNum, emoji = "thumbs-up"}
	end};
	{command = "mute", desc = "Suspend a user's ability to talk in your server.", usage = "mute <@mention> <duration> <optional reason>", shorthand = {"shutup"}, execute = function(message,args) 
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
				title = "**CAS3 "..args[2].."**",
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
      message.guild.members:get(message.mentionedUsers[1][1]):getPrivateChannel():send("⛔ **You've been warned in "..message.guild.name.."!**\n*Please do not continue to break the rules.*\n\nReason: "..reason)
      return {success = true, msg = "Successfully warned **"..message.guild.members:get(message.mentionedUsers[1][1]).name.."**."}
    end   
  end};
  {command = "config", desc = "Edit your guild's configuration settings.", usage = "config <type> <value>", shorthand = {}, execute = function(message,args) 
		local arg = string.lower(args[2])
    if arg == ""
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
local message = msg
local a, b = string.gsub(message.content,"\n","")
local c, d = string.gsub(message.content,"||","")
if message.author.bot == false then
	if (b + 1 >= tonumber(config[message.guild.id].maxNewline) == true) and config[message.guild.id].newline then
		message:delete()
		local reply = message:reply(message.author.mentionString..", too many lines.")
		--message.author:getPrivateChannel():send("⛔ **You've been warned in "..message.guild.name.."!**\nPlease do not exceed the newline limit of 5 in "..message.guild.name..".\n\nHere's your message if you wish to edit it:```"..message.content.."```")
		timer.sleep(3000)
		reply:delete()
		return false
	elseif checkMany("curse",string.lower(msg.content),message.guild.id) == true and config[message.guild.id].filter == true then
		message:delete()
		local reply = message:reply(message.author.mentionString..", watch your language.")
		if config[message.guild.id].modlog ~= "nil" then
			message.guild:getChannel(config[message.guild.id].modlog):send{embed = {
				title = "**AUT0 M0D3RAT0R - BAD W0RD5**",
				description = "**User:** "..message.author.mentionString.."\n**Message:**\n```"..msg.content.."```",
				footer = {
					text = "xd"
				}
			}
		}
		end
		timer.sleep(3000)
		reply:delete()
		return false
	elseif checkMany("invites",msg.content,msg.guild.id) == true and config[message.guild.id].invites == true or string.match(message.content,"discord.gg") and client:getInvite(xd) and config[message.guild.id].invites == true then
		message:delete()
		local reply = message:reply(message.author.mentionString..", no invites.")
		timer.sleep(3000)
		reply:delete()
		return false
	elseif d/2 >= config[message.guild.id].maxSpoilers and config[message.guild.id].spoilers == true then
		message:delete()
		local reply = message:reply(message.author.mentionString..", too many spoilers.")
		timer.sleep(3000)
		reply:delete()
		return false
	elseif #msg.mentionedRoles + #msg.mentionedUsers >= config[message.guild.id].maxMentions and config[message.guild.id].massmentions == true then
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
for Match in Command:gmatch("[^%s,]+") do
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
	print('Logged in as '.. client.user.username)
	client:setGame("a!help | AA-R0N")
	print('starting temp action loop')
	while true do
		for id,items in pairs(config) do
			for num,itemz in pairs(items.modData.actions) do
				if tonumber(itemz.duration) ~= nil and os.time() >= itemz.duration then
					if itemz.type == "mute" then
						if items.mutedRole ~= "nil" and client:getGuild(id):getMember(itemz.user) then
							if client:getGuild(id):getMember(itemz.user):hasRole(items.mutedRole) then
								client:getGuild(id):getMember(itemz.user):removeRole(items.mutedRole)
							end
						end
					end
          print('[DEBUG] [UNMUTE]: '..itemz.user.." has been unmuted in "..id)
          local case = {type = "Auto-Unmute", duration = "", reason = "Mute duration expired.", user = itemz.user, mod = client.user.id}
          config[id].modData.cases[1+#config[id].modData.cases] = case
          if config[id].modlog ~= nil and client:getGuild(id):getChannel(config[id].modlog) then
            client:getGuild(id):getChannel(config[id].modlog):send{embed = {
              title = "**CAS3 "..#config[id].modData.cases.."** - "..case.type:upper(),
              description = "**User:** "..client:getUser(case.user).name.."#"..client:getUser(case.user).discriminator.." (`"..client:getUser(case.user).id.."`)\n**Moderator:** "..client:getUser(case.mod).name.."#"..client:getUser(case.mod).discriminator.." (`"..client:getUser(case.mod).id.."`)"..(case.duration ~= "" and "\n**Duration:** "..case.duration or "").."\n**Reason:** "..case.reason,
              color = 2067276
            }}
          end
					table.remove(items.modData.actions,num)
				end
			end
		end
		timer.sleep(1000)
	end
end)

client:on('memberUpdate', function(member)
	if config[member.guild.id] == nil then
		addConfig(member.guild.id)
	end
	if member.nickname ~= nil then
		if string.match(string.lower(member.nickname),"discord.gg") and config[message.guild.id].invites == true then
			member:setNickname(nil)
		elseif checkMany("curse",string.lower(member.nickname),member.guild.id) == true and config[member.guild.id].filter == true then
			member:setNickname(nil)
		end
	end
end)

client:on('guildCreate', function(guild)
local hm = guild.members
end)

client:on('guildDelete', function(guild)
local him = guild.members
end)

client:on('memberJoin', function(member)
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

client:on("messageUpdate", function(message)
	if message.guild ~= nil or message.author.bot ~= true then
		autoMod(message)
	end
end)

client:on('messageCreate', function(message)
	if message.guild == nil then return end
	if message.author.bot then return end
	if message.guild ~= nil or message.author.bot ~= true then -- if it's not a guild or its a bot
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
				local emojis = {
					["ok"] = ":ok_hand:",
					["ping"] = ":ping_pong:",
					["tools"] = ":tools:",
					["thumbs-up"] = ":thumbsup:"
 				}
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