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
local fs = require("fs")
local Date = discordia.Date
local config = {}
local cache = {} -- ["1"] = {users = {}, textchannels = {}, voicechannels = {}, }

local configuration = require("/app/config.lua")
local configSetup = configuration.setupConfigs('xddd')
for a,b in pairs(configSetup) do config[a] = b end
for a,b in pairs(client.guilds) do config[b.id] = configuration.getConfig(b.id) end 


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

client:on("ready", function()
  client:setGame("?help | AA-R0N")
  for _,guilds in pairs(client.guilds) do
    cache[guilds.id] = {users = {}, channels = {}, roles = {}}
    for _,users in pairs(guilds.members) do
       cache[guilds.id].users[users.id] = {roles = {}, nickname = (users.nickname == nil and "5FFA914BBF6B3D6149B228E8ED0AA2F1789C62227D4CEF4D9FE61D5E0F10597D" or users.nickname)}
       for _,items in pairs(users.roles) do cache[guilds.id].users[users.id].roles[items.id] = true end
       --print("[USER CACHED]: "..users.name.." has been cached in "..guilds.name..".")
    end
    for _,channels in pairs(guilds.textChannels) do
      cache[guilds.id].channels[channels.id] = {name = channels.name, nsfw = channels.nsfw, ratelimit = channels.rateLimit, topic = (channels.topic ~= nil and channels.topic or "5FFA914BBF6B3D6149B228E8ED0AA2F1789C62227D4CEF4D9FE61D5E0F10597D"), permissions = channels.permissionOverwrites, position = channels.position, category = (channels.category == nil and "nil" or channels.category.id)}
      --print("[CHANNEL CACHED]: "..channels.name.." has been cached in "..guilds.name..".")
    end
    for _,channels in pairs(guilds.categories) do
      cache[guilds.id].channels[channels.id] = {name = channels.name, permissions = channels.permissionOverwrites, position = channels.position}
      --print('[CATEGORY CACHED]: '..channels.name.." has been cached in "..guilds.name..".")
    end
    for _,channels in pairs(guilds.voiceChannels) do
      cache[guilds.id].channels[channels.id] = {name = channels.name, userlimit = channels.userLimit, bitrate = channels.bitrate, permissions = channels.permissionOverwrites, category = (channels.category == nil and "nil" or channels.category.id)}
     -- print("[VOICE CHANNEL CACHED]: "..channels.name.." has been cached in "..guilds.name..".")
    end
    for _,roles in pairs(guilds.roles) do
      cache[guilds.id].roles[roles.id] = {name = roles.name, hoisted = roles.hoisted, mentionable = roles.mentionable, color = roles.color, position = roles.position}
      --print("[ROLE CACHED]: "..roles.name.." has been cached in "..guilds.name..".")
    end
  end
  print("[TEMP-ACTION LOOP]: Starting timed-actions loop.")
  while true do
    for id,configData in pairs(config) do
      config[id] = configuration.getConfig(id)
      if client:getGuild(id) == nil or config[id] == nil then
        --// not in guild, we won't do their math >:*(
      else
        for num,action in pairs(configData.modData.actions) do
          if tonumber(action.duration) ~= nil and os.time() >= action.duration then --// the duration isn't permanent and it's expired.
            table.remove(configData.modData.actions,num)
            configuration.updateConfig(id,configData)
            if action.type == "mute" then
              if client:getGuild(id):getMember(action.user) ~= nil and configData.mutedrole ~= "nil" and client:getGuild(id):getRole(configData.mutedrole) ~= nil and cache[id].users[action.user].roles[configData.mutedrole] ~= nil then
                repeat
                  client:getGuild(id):getMember(action.user):addRole(configData.mutedrole)
                  client:getGuild(id):getMember(action.user):removeRole(configData.mutedrole)
                  timer.sleep(1000)
                until
                cache[id].users[action.user].roles[configData.mutedrole] == nil
              end
              configData.modData.cases[1+#configData.modData.cases] = {type = "Auto Unmute", user = action.user, moderator = client.user.id, reason = "Mute duration expired."}
              configuration.updateConfig(id,configData)
              if configData.modlog ~= "nil" and client:getGuild(id):getChannel(configData.modlog) then
                client:getGuild(id):getChannel(configData.modlog):send{embed = { title = "Auto Unmute - Case "..#configData.modData.cases, fields = { { name = "Member", value = client:getUser(action.user).tag.." (`"..action.user.."`)", inline = true, }, { name = "Reason", value = "Mute duration expired.", inline = false, }, { name = "Responsible Moderator", value = client.user.mentionString.." (`"..client.user.id.."`)", inline = false, }, }, color = 2067276, }} 
              end
            elseif action.type == "ban" then
              if client:getGuild(id):getBan(action.user) ~= nil then client:getGuild(id):unbanUser(action.user,"Ban duration expired.") end
              configData.modData.cases[1+#configData.modData.cases] = {type = "Auto Unban", user = action.user, moderator = client.user.id, reason = "Ban duration expired."}
              configuration.updateConfig(id,configData)
              if configData.modlog ~= "nil" and client:getGuild(id):getChannel(configData.modlog) then
                client:getGuild(id):getChannel(configData.modlog):send{embed = { title = "Auto Unban - Case "..#configData.modData.cases, fields = { { name = "Member", value = client:getUser(action.user).tag.." (`"..action.user.."`)", inline = true, }, { name = "Reason", value = "Ban duration expired.", inline = false, }, { name = "Responsible Moderator", value = client.user.mentionString.." (`"..client.user.id.."`)", inline = false, }, }, color = 2067276, }} 
              end
            end
          end
        end
      end
    end
  timer.sleep(1000)
  end
end)

client:on("messageCreate",function(message)
  if message.guild == nil then return end
  config[message.guild.id] = configuration.getConfig(message.guild.id)
  local args = sepMsg(message.content)
  if args[1] == nil then return end
  if string.lower(args[1]) == "!!prefix?" then message:reply("The prefix for **"..message.guild.name.."** is **"..config[message.guild.id].prefix.."**") return end
  if args[1] == "<@!"..client.user.id..">" or args[1] == "<@"..client.user.id..">" then
    table.remove(args,1)
    args[1] = config[message.guild.id].prefix..args[1]
  end
  local found
  for file, _type in fs.scandirSync("./commands") do
	  if _type ~= "directory" then
      local cmd = require("./commands/" .. file)
      if string.lower(config[message.guild.id].prefix..cmd.info.Name) == string.lower(args[1]) or args[1] == client.user.mentionString then
        found = cmd
        break
      elseif #cmd.info.Alias >= 1 then
        for _,items in pairs(cmd.info.Alias) do
          if string.lower(config[message.guild.id].prefix..items) == string.lower(args[1]) then
            found = cmd
            break
          end
        end
      end
	  end
  end
  if found == nil or getPermission(message) < 1 and config[message.guild.id].modonly then
    autoMod(message)
  else
    if config[message.guild.id].modonly and getPermission(message) < 1 then return end
    if config[message.guild.id].deletecmd then message:delete() end
    if found.info.PermLvl <= getPermission(message) then
      local execute = found.execute(message,args,client)
      if execute == nil or type(execute) ~= "table" then
        message:reply(":no_entry: An **unknown error** occured.")
      elseif execute.success == false then
        message:reply(":no_entry: "..execute.msg)
      elseif tostring(execute.success):lower() == "stfu" then
        -- stfu literally
      else
        message:reply((execute.emote == nil and ":ok_hand:" or execute.emote).." "..execute.msg)
      end
    else
      autoMod(message)
      local m = message:reply(":no_entry: You **don't have permissions** to use this command!")
      timer.sleep(5000)
      m:delete()
    end
  end
end)

-- AUDIT LOGGING

client:on("guildCreate",function(guild)
  config[guild.id] = configuration.getConfig(guild.id)
  local guilds = guild
  cache[guilds.id] = {users = {}, channels = {}, roles = {}}
  for _,users in pairs(guilds.members) do
     cache[guilds.id].users[users.id] = {roles = {}, nickname = (users.nickname == nil and "5FFA914BBF6B3D6149B228E8ED0AA2F1789C62227D4CEF4D9FE61D5E0F10597D" or users.nickname)}
     for _,items in pairs(users.roles) do cache[guilds.id].users[users.id].roles[items.id] = true end
  end
  for _,channels in pairs(guilds.textChannels) do
    cache[guilds.id].channels[channels.id] = {name = channels.name, nsfw = channels.nsfw, ratelimit = channels.rateLimit, topic = (channels.topic ~= nil and channels.topic or "5FFA914BBF6B3D6149B228E8ED0AA2F1789C62227D4CEF4D9FE61D5E0F10597D"), permissions = channels.permissionOverwrites, position = channels.position, category = (channels.category == nil and "nil" or channels.category.id)}
  end
  for _,channels in pairs(guilds.categories) do
    cache[guilds.id].channels[channels.id] = {name = channels.name, permissions = channels.permissionOverwrites, position = channels.position}
  end
  for _,channels in pairs(guilds.voiceChannels) do
    cache[guilds.id].channels[channels.id] = {name = channels.name, userlimit = channels.userLimit, bitrate = channels.bitrate, permissions = channels.permissionOverwrites, category = (channels.category == nil and "nil" or channels.category.id)}
  end
  for _,roles in pairs(guilds.roles) do
    cache[guilds.id].roles[roles.id] = {name = roles.name, hoisted = roles.hoisted, mentionable = roles.mentionable, color = roles.color, position = roles.position}
  end
  print("[NEW GUILD]: "..guild.name.." owned by "..guild.owner.name.." with "..#guild.members.." members.")
  client:getGuild("551017079797579795"):getChannel("551758183274905600"):send{embed ={
    title = "Guild Added",
    description = "I've just been added to a new guild.",
    thumbnail = {
		  url = (guild.iconURL == nil and "https://cdn.discordapp.com/avatars/414030463792054282/1480299878553601b74f094273647589.png" or guild.iconURL)
	  },
    fields = {
      {
        name = "Guild",
        value = guild.name.." (`"..guild.id.."`)",
        inline = true,
      },
      {
        name = "Members",
        value = #guild.members,
        inline = true,
      },
      {
        name = "Guild Owner",
        value = guild.owner.mentionString.." (`"..guild.ownerId.."`)",
        inline = true,
      },
    },
    footer = {text = "I'm now in "..#client.guilds.." servers"},
    color = 2067276,
  }}
end)

client:on("guildDelete", function(guild)
  client:getGuild("551017079797579795"):getChannel("551758183274905600"):send{embed ={
      title = "Guild Removed",
      description = "I've just been kicked from a guild.",
      thumbnail = {
        url = (guild.iconURL == nil and "https://cdn.discordapp.com/avatars/414030463792054282/1480299878553601b74f094273647589.png" or guild.iconURL)
      },
      fields = {
        {
          name = "Guild",
          value = guild.name.." (`"..guild.id.."`)",
          inline = true,
        },
        {
          name = "Members",
          value = #guild.members,
          inline = true,
        },
        {
          name = "Guild Owner",
          value = guild.owner.mentionString.." (`"..guild.ownerId.."`)",
          inline = true,
        },
      },
      footer = {text = "I'm now in "..#client.guilds.." servers"},
      color = 10038562,
  }}
end)

client:on("memberJoin", function(member)
  if member.guild == nil then return end
  config[member.guild.id] = configuration.getConfig(member.guild.id)
  cache[member.guild.id].users[member.id] = {roles = {}, nickname = (member.nickname == nil and "5FFA914BBF6B3D6149B228E8ED0AA2F1789C62227D4CEF4D9FE61D5E0F10597D" or member.nickname)}
  for _,items in pairs(member.roles) do cache[member.guild.id].users[member.id].roles[items.id] = true end
  if config[member.guild.id].auditlog ~= "nil" and member.guild:getChannel(config[member.guild.id].auditlog) ~= nil then
    member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "Member Joined", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = true, }, { name = "Created At", value = Date.fromSnowflake(member.id):toISO(' ', ''), inline = true, }, }, color = 3066993, }}
  end
  if config[member.guild.id].welcome.enabled and config[member.guild.id].welcome.joinchannel ~= "nil" and config[member.guild.id].welcome.joinmsg ~= "nil" then
    local msg = config[member.guild.id].welcome.joinmsg
    msg = string.gsub(msg, "{user}", member.mentionString)
    msg = string.gsub(msg, "{tag}", member.tag)
    msg = string.gsub(msg, "{username}", member.username)
    msg = string.gsub(msg, "{discrim}", member.discriminator)
    msg = string.gsub(msg, "{server}", member.guild.name)
    msg = string.gsub(msg, "{members}", #member.guild.members)
    if config[member.guild.id].welcome.joinchannel == "dm" then
      member:getPrivateChannel():send(msg)
    elseif member.guild:getChannel(config[member.guild.id].welcome.joinchannel) ~= nil then
      member.guild:getChannel(config[member.guild.id].welcome.joinchannel):send(msg)
    end
  end
  if config[member.guild.id].welcome.enabled and config[member.guild.id].welcome.autorole ~= "nil" then
    if member.guild:getRole(config[member.guild.id].welcome.autorole) ~= nil then
      if member.guild:getRole(config[member.guild.id].welcome.autorole).position < member.guild:getMember(client.user.id).highestRole.position then
        member:addRole(config[member.guild.id].welcome.autorole)
      end
    end
  end
  for _,actions in pairs(config[member.guild.id].modData.actions) do 
    if actions.user == member.id and actions.type == "mute" then
      member:addRole(config[member.guild.id].mutedrole)
      break
    end
  end
end)

client:on("memberLeave", function(member)
  timer.sleep(100)
  if member.guild == nil then return end
  config[member.guild.id] = configuration.getConfig(member.guild.id)
  if config[member.guild.id].auditlog ~= "nil" and member.guild:getChannel(config[member.guild.id].auditlog) ~= nil then
    local roles = {}
    for _,items in pairs(member.roles) do roles[1+#roles] = items.mentionString end
    member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "Member Left", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = true, }, { name = "Roles", value = (#roles == 0 and "No Roles!" or table.concat(roles,", ")), inline = true, }, }, color = 15158332, }}
  end
  if config[member.guild.id].welcome.enabled and config[member.guild.id].welcome.leavechannel ~= "nil" and config[member.guild.id].welcome.leavemsg ~= "nil" then
    local msg = config[member.guild.id].welcome.leavemsg
    msg = string.gsub(msg, "{user}", member.mentionString)
    msg = string.gsub(msg, "{tag}", member.tag)
    msg = string.gsub(msg, "{username}", member.username)
    msg = string.gsub(msg, "{discrim}", member.discriminator)
    msg = string.gsub(msg, "{server}", member.guild.name)
    msg = string.gsub(msg, "{members}", #member.guild.members)
    if config[member.guild.id].welcome.leavechannel == "dm" then
      member:getPrivateChannel():send(msg)
    elseif member.guild:getChannel(config[member.guild.id].welcome.leavechannel) ~= nil then
      member.guild:getChannel(config[member.guild.id].welcome.leavechannel):send(msg)
    end
  end
end)

client:on("memberUpdate", function(member)
  timer.sleep(100)
  if member.guild == nil then return end
  if client:getGuild(member.guild.id) == nil then return end
  config[member.guild.id] = configuration.getConfig(member.guild.id)
  if cache[member.guild.id] == nil then return end
  if cache[member.guild.id].users[member.id] == nil then return end
  local auditLog
  for a,items in pairs(member.guild:getAuditLogs()) do if math.floor(items.createdAt) == os.time() or math.floor(items.createdAt) == os.time() - 1 or math.floor(items.createdAt) == os.time() + 1 or math.floor(items.createdAt) == os.time() + 2 and items.guild.id == member.guild.id then auditLog = items break end end
  if auditLog == nil then print("no log found for action.") return end
  if auditLog.actionType == 25 then
    local theirRoles = {} for _,items in pairs(member.roles) do table.insert(theirRoles,#theirRoles+1,items.id) end
    local roles = {added = {}, removed = {}}
    for _,items in pairs(member.roles) do
      if cache[member.guild.id].users[member.id].roles[items.id] == nil then -- has a role but wasnt cached
          --print(items.id,"was added!")
          roles.added[1+#roles.added] = items.id
      end
    end
    for items,_ in pairs(cache[member.guild.id].users[member.id].roles) do
      if member.guild:getRole(items) and member:hasRole(items) == false then -- don't have a role that was cached
        --print(items,"was removed")
        roles.removed[1+#roles.removed] = items
      end
    end
    cache[member.guild.id].users[member.id].roles = {} for _,items in pairs(member.roles) do cache[member.guild.id].users[member.id].roles[items.id] = true end
    if config[member.guild.id].auditlog ~= "nil" and member.guild:getChannel(config[member.guild.id].auditlog) ~= nil then
      local list = {}
      if #roles.added == 0 and #roles.removed >= 1 then
        for _,items in pairs(roles.removed) do list[1+#list] = member.guild:getRole(items).mentionString end
        for num,dupe in pairs(list) do for num2,dupe2 in pairs(list) do if dupe == dupe2 and num ~= num2 then table.remove(list,num) end end end
        for num,crazy in pairs(list) do for _,roles in pairs(member.guild.roles) do if member:hasRole(roles.id) == true and crazy == roles.mentionString then table.remove(list,num) end end end
        if auditLog:getMember().id == member.id then
          member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "Role"..(#list == 1 and "" or "s").." Removed", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = true, }, { name = "Role"..(#list == 1 and "" or "s"), value = table.concat(list,", "), inline = true, }, }, color = 10038562, }} 
        else
          member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "Role"..(#list == 1 and "" or "s").." Removed", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = true, }, { name = "Role"..(#list == 1 and "" or "s"), value = table.concat(list,", "), inline = true, }, { name = "Responsible Member", value = auditLog:getMember().mentionString.." (`"..auditLog:getMember().id.."`)", inline = false, }, }, color = 10038562, }}
        end
      elseif #roles.added >= 1 and #roles.removed == 0 then
        for _,items in pairs(roles.added) do list[1+#list] = member.guild:getRole(items).mentionString end
        for num,dupe in pairs(list) do for num2,dupe2 in pairs(list) do if dupe == dupe2 and num ~= num2 then table.remove(list,num) end end end
        for num,crazy in pairs(list) do for _,roles in pairs(member.guild.roles) do if member:hasRole(roles.id) == false and crazy == roles.mentionString then table.remove(list,num) end end end
        if auditLog:getMember().id == member.id then
          member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "Role"..(#list == 1 and "" or "s").." Added", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = true, }, { name = "Role"..(#list == 1 and "" or "s"), value = table.concat(list,", "), inline = true, }, }, color = 2067276, }}
        else
          member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "Role"..(#list == 1 and "" or "s").." Added", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = true, }, { name = "Role"..(#list == 1 and "" or "s"), value = table.concat(list,", "), inline = true, }, { name = "Responsible Member", value = auditLog:getMember().mentionString.." (`"..auditLog:getMember().id.."`)", inline = false, }, }, color = 2067276, }}
        end
      else
        local lists = {added = {}, removed = {}}
        for _,items in pairs(roles.added) do lists.added[1+#lists.added] = member.guild:getRole(items).mentionString end
        for _,items in pairs(roles.removed) do lists.removed[1+#lists.removed] = member.guild:getRole(items).mentionString end
        if auditLog:getMember().id == member.id then
          member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "Roles Changed", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = false, }, { name = "Role"..(#roles.added == 1 and "" or "s").." Added", value = table.concat(lists.added,", "), inline = true, }, { name = "Role"..(#roles.removed == 1 and "" or "s").." Removed", value = table.concat(lists.removed,", "), inline = true, }, }, color = 15105570, }}
        else
          member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "Roles Changed", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = false, }, { name = "Role"..(#roles.added == 1 and "" or "s").." Added", value = table.concat(lists.added,", "), inline = true, }, { name = "Role"..(#roles.removed == 1 and "" or "s").." Removed", value = table.concat(lists.removed,", "), inline = true, }, { name = "Responsible Member", value = auditLog:getMember().mentionString.." (`"..auditLog:getMember().id.."`)", inline = false, }, }, color = 15105570, }}
        end
      end
    end
  elseif (member.nickname == nil and "5FFA914BBF6B3D6149B228E8ED0AA2F1789C62227D4CEF4D9FE61D5E0F10597D" or member.nickname) ~= cache[member.guild.id].users[member.id].nickname then
    if config[member.guild.id].auditlog ~= "nil" and member.guild:getChannel(config[member.guild.id].auditlog) ~= nil then
      if member.nickname == nil then
        if auditLog:getMember().id == member.id then
          member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "Nickname Removed", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = true, }, { name = "Old Nickname", value = cache[member.guild.id].users[member.id].nickname, inline = true, }, }, color = 10038562, }}
        else
          member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "Nickname Removed", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = true, }, { name = "Old Nickname", value = cache[member.guild.id].users[member.id].nickname, inline = true, }, { name = "Responsible Member", value = auditLog:getMember().mentionString.." (`"..auditLog:getMember().id.."`)", inline = false, }, }, color = 10038562, }}
        end
      elseif cache[member.guild.id].users[member.id].nickname == "5FFA914BBF6B3D6149B228E8ED0AA2F1789C62227D4CEF4D9FE61D5E0F10597D" then
        if auditLog:getMember().id == member.id then
          member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "Nickname Added", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = true, }, { name = "New Nickname", value = member.nickname, inline = true, }, }, color = 2067276, }}
        else
          member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "Nickname Added", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = true, }, { name = "New Nickname", value = member.nickname, inline = true, }, { name = "Responsible Member", value = auditLog:getMember().mentionString.." (`"..auditLog:getMember().id.."`)", inline = false, }, }, color = 2067276, }}
        end
      else
        if auditLog:getMember().id == member.id then
          member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "Nickname Edited", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = false, }, { name = "New Nickname", value = member.nickname, inline = true, }, { name = "Old Nickname", value = cache[member.guild.id].users[member.id].nickname, inline = true, }, }, color = 15105570, }}
        else
          member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "Nickname Edited", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = false, }, { name = "New Nickname", value = member.nickname, inline = true, }, { name = "Old Nickname", value = cache[member.guild.id].users[member.id].nickname, inline = true, }, { name = "Responsible Member", value = auditLog:getMember().mentionString.." (`"..auditLog:getMember().id.."`)", inline = false, }, }, color = 15105570, }}
        end
      end
    end
  cache[member.guild.id].users[member.id].nickname = (member.nickname == nil and "5FFA914BBF6B3D6149B228E8ED0AA2F1789C62227D4CEF4D9FE61D5E0F10597D" or member.nickname)
  end
end)

client:on("messageDelete", function(message)
  if message.guild == nil then return end
  if message.author.bot then return end
  config[message.guild.id] = configuration.getConfig(message.guild.id)
  if config[message.guild.id].auditlog == "nil" and message.guild:getChannel(config[message.guild.id].auditlog) == nil then return end
  local auditLog
  for a,items in pairs(message.guild:getAuditLogs()) do if math.floor(items.createdAt) == os.time() or math.floor(items.createdAt) == os.time() - 1 or math.floor(items.createdAt) == os.time() + 1 or math.floor(items.createdAt) == os.time() + 2 and items.guild.id == member.guild.id and items.actionType == 72 then auditLog = items break end end
  if auditLog == nil or auditLog:getMember().id == message.author.id then
    message.guild:getChannel(config[message.guild.id].auditlog):send{embed ={ title = "Message Deleted", fields = { { name = "Message Author", value = message.author.mentionString.." (`"..message.author.id.."`)", inline = true, }, { name = "Message Location", value = message.channel.mentionString, inline = true, }, { name = "Message Content", value = message.content, inline = false, }, }, color = 3447003, }}
  else
    message.guild:getChannel(config[message.guild.id].auditlog):send{embed ={ title = "Message Deleted", fields = { { name = "Message Author", value = message.author.mentionString.." (`"..message.author.id.."`)", inline = true, }, { name = "Message Location", value = message.channel.mentionString, inline = true, }, { name = "Message Content", value = message.content, inline = false, }, { name = "Responsible Member", value = auditLog:getMember().mentionString.." (`"..auditLog:getMember().id.."`)", inline = false, }, }, color = 3447003, }}
  end
end)

client:on("channelCreate", function(channel)
  if channel.guild == nil then return end
  config[channel.guild.id] = configuration.getConfig(channel.guild.id)
  local channels = channel
  if channel.type == 0 then cache[channel.guild.id].channels[channels.id] = {name = channels.name, nsfw = channels.nsfw, ratelimit = channels.rateLimit, topic = (channels.topic ~= nil and channels.topic or "5FFA914BBF6B3D6149B228E8ED0AA2F1789C62227D4CEF4D9FE61D5E0F10597D"), permissions = channels.permissionOverwrites, position = channels.position, category = (channels.category == nil and "nil" or channels.category.id)} end
  if channel.type == 4 then cache[channel.guild.id].channels[channels.id] = {name = channels.name, permissions = channels.permissionOverwrites, position = channel.position} end
  if channel.type == 2 then cache[channel.guild.id].channels[channels.id] = {name = channels.name, userlimit = channels.userLimit, bitrate = channels.bitrate, permissions = channels.permissionOverwrites, category = (channels.category == nil and "nil" or channels.category.id)} end
  if config[channel.guild.id].auditlog == "nil" and channel.guild:getChannel(config[channel.guild.id].auditlog) == nil then return end
  local auditLog
  for a,items in pairs(channel.guild:getAuditLogs()) do if math.floor(items.createdAt) == os.time() or math.floor(items.createdAt) == os.time() - 1 or math.floor(items.createdAt) == os.time() + 1 or math.floor(items.createdAt) == os.time() + 2 and items.guild.id == member.guild.id and items.actionType == 10 then auditLog = items break end end
  if channel.type == 0 then
    if auditLog == nil then
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = "Channel Created", fields = { { name = "Channel", value = channel.mentionString, inline = true, }, { name = "Channel Location", value = (channel.category == nil and "Not Categorized" or channel.category.name), inline = true, }, }, color = 2067276, }}
    else
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = "Channel Created", fields = { { name = "Channel", value = channel.mentionString, inline = true, }, { name = "Channel Location", value = (channel.category == nil and "Not Categorized" or channel.category.name), inline = true, }, { name = "Responsible Member", value = auditLog:getMember().mentionString.." (`"..auditLog:getMember().id.."`)", inline = false, }, }, color = 2067276, }}
    end
  elseif channel.type == 4 then
    if auditLog == nil then
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = "Category Created", fields = { { name = "Category", value = channel.name, inline = true, }, { name = "Category Position", value = "#"..channel.position, inline = true, }, }, color = 2067276, }}
    else
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = "Category Created", fields = { { name = "Category", value = channel.name, inline = true, }, { name = "Category Position", value = "#"..channel.position, inline = true, }, { name = "Responsible Member", value = auditLog:getMember().mentionString.." (`"..auditLog:getMember().id.."`)", inline = false, }, }, color = 2067276, }}
    end
  elseif channel.type == 2 then
    if auditLog == nil then
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = "Voice Channel Created", fields = { { name = "Channel", value = channel.name, inline = true, }, { name = "Channel Location", value = (channel.category == nil and "Not Categorized" or channel.category.name), inline = true, }, }, color = 2067276, }}
    else
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = "Voice Channel Created", fields = { { name = "Channel", value = channel.name, inline = true, }, { name = "Channel Location", value = (channel.category == nil and "Not Categorized" or channel.category.name), inline = true, }, { name = "Responsible Member", value = auditLog:getMember().mentionString.." (`"..auditLog:getMember().id.."`)", inline = false, }, }, color = 2067276, }}
    end
  end
end)

client:on("channelDelete", function(channel)
  if channel.guild == nil then return end
  config[channel.guild.id] = configuration.getConfig(channel.guild.id)
  if config[channel.guild.id].auditlog == "nil" and channel.guild:getChannel(config[channel.guild.id].auditlog) == nil then return end
  local auditLog
  for a,items in pairs(channel.guild:getAuditLogs()) do if math.floor(items.createdAt) == os.time() or math.floor(items.createdAt) == os.time() - 1 or math.floor(items.createdAt) == os.time() + 1 or math.floor(items.createdAt) == os.time() + 2 and items.guild.id == member.guild.id and items.actionType == 12 then auditLog = items break end end
  if channel.type == 0 or channel.type == 2 then
    if auditLog == nil then
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = (channel.type == 2 and "Voice " or "").."Channel Deleted", fields = { { name = "Channel", value = channel.name.." (`"..channel.id.."`)", inline = true, }, { name = "Previous Location", value = (channel.category == nil and "Wasn't Categorized" or channel.category.name), inline = true, }, }, color = 10038562, }}
    else
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = (channel.type == 2 and "Voice " or "").."Channel Deleted", fields = { { name = "Channel", value = channel.name.." (`"..channel.id.."`)", inline = true, }, { name = "Previous Location", value = (channel.category == nil and "Wasn't Categorized" or channel.category.name), inline = true, }, { name = "Responsible Member", value = auditLog:getMember().mentionString.." (`"..auditLog:getMember().id.."`)", inline = false, }, }, color = 10038562, }}
    end
  elseif channel.type == 4 then
    if auditLog == nil then
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = "Category Deleted", fields = { { name = "Category", value = channel.name, inline = true, }, { name = "Previous Position", value = "#"..channel.position, inline = true, }, }, color = 10038562, }}
    else
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = "Category Deleted", fields = { { name = "Category", value = channel.name, inline = true, }, { name = "Previous Position", value = "#"..channel.position, inline = true, }, { name = "Responsible Member", value = auditLog:getMember().mentionString.." (`"..auditLog:getMember().id.."`)", inline = false, }, }, color = 10038562, }}
    end
  end
end)

client:on("messageUpdate", function(message)
  if message.guild == nil or message.author.bot then return end
	if config[message.guild.id] and config[message.guild.id].auditlog ~= "nil" and message.guild:getChannel(config[message.guild.id].auditlog) then
    if message.channel:getMessage(message.id) == nil or message.channel:getMessage(message.id).oldContent == nil then return end
    local oldMsg
    for a,items in pairs(message.channel:getMessage(message.id).oldContent) do oldMsg = items end
    message.guild:getChannel(config[message.guild.id].auditlog):send{embed ={ title = "Message Edited", fields = { { name = "Message Author", value = message.author.mentionString.." (`"..message.author.id.."`)", inline = true, }, { name = "Message Location", value = message.channel.mentionString, inline = true, }, { name = "Old Message Content", value = oldMsg, inline = false, }, { name = "New Message Content", value = message.content, inline = false, }, }, color = 15105570, }}
  end
end)

client:on('roleCreate', function(channel)
  if config[channel.guild.id] == nil then return end
  cache[channel.guild.id].roles[channel.id] = {name = channel.name, hoisted = channel.hoisted, mentionable = channel.mentionable, color = role.color, position = role.position}
  local auditLog
  for a,items in pairs(channel.guild:getAuditLogs()) do if math.floor(items.createdAt) == os.time() or math.floor(items.createdAt) == os.time() - 1 or math.floor(items.createdAt) == os.time() + 1 or math.floor(items.createdAt) == os.time() + 2 and items.guild.id == channel.guild.id then auditLog = items break end end
  if auditLog == nil or auditLog:getMember() == nil or auditLog.actionType ~= 30 then
    if config[channel.guild.id] and config[channel.guild.id].auditlog ~= "nil" and channel.guild:getChannel(config[channel.guild.id].auditlog) then
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = "Role Created", fields = { { name = "Role", value = channel.mentionString, inline = true,}, }, color = 2067276, }}
    end
  else
    if config[channel.guild.id] and config[channel.guild.id].auditlog ~= "nil" and channel.guild:getChannel(config[channel.guild.id].auditlog) then
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = "Role Created", fields = { { name = "Role", value = channel.mentionString, inline = true, }, { name = "Responsible Member", value = auditLog:getMember().mentionString.." (`"..auditLog:getMember().id.."`)", inline = true, }, }, color = 2067276, }}
    end
  end
end)

client:on('roleDelete', function(channel)
  timer.sleep(100)
  if channel.guild == nil then return end
  if client:getGuild(channel.guild.id) == nil then return end
  if config[channel.guild.id] == nil then return end
  local auditLog
  for a,items in pairs(channel.guild:getAuditLogs()) do if math.floor(items.createdAt) == os.time() or math.floor(items.createdAt) == os.time() - 1 or math.floor(items.createdAt) == os.time() + 1 or math.floor(items.createdAt) == os.time() + 2 and items.guild.id == channel.guild.id then auditLog = items break end end
  if auditLog == nil or auditLog:getMember() == nil or auditLog.actionType ~= 32 then
    if config[channel.guild.id] and config[channel.guild.id].auditlog ~= "nil" and channel.guild:getChannel(config[channel.guild.id].auditlog) then
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = "Role Deleted", fields = { { name = "Role", value = channel.name, inline = true,}, }, color = 10038562, }}
    end
  else
    if config[channel.guild.id] and config[channel.guild.id].auditlog ~= "nil" and channel.guild:getChannel(config[channel.guild.id].auditlog) then
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = "Role Deleted", fields = { { name = "Role", value = channel.name, inline = true, }, { name = "Responsible Member", value = auditLog:getMember().mentionString.." (`"..auditLog:getMember().id.."`)", inline = true, }, }, color = 10038562, }}
    end
  end
end)

client:on('roleUpdate', function(role)
  cache[role.guild.id].roles[role.id] = {name = role.name, hoisted = role.hoisted, mentionable = role.mentionable, color = role.color, position = role.position}
end)

client:run('Bot NDE0MDMwNDYzNzkyMDU0Mjgy.D1SnRg.p9ghEI5njoksY0UkFGHCAnV1glQ')

local module = {}

module.getCache = function(type,guild,id)
  if type == "role" then
    return cache[guild].roles[id]
  elseif type == "user" then
    return cache[guild].users[id]
  elseif type == "roleh" then
    local role,pos = "",-1
    for items,_ in pairs(cache[guild].users[id].roles) do if module.getCache("role",guild,items).position > pos then role = items pos = module.getCache("role",guild,items).position end end
    return (role == "" and client:getGuild(guild):getRole(guild) or module.getCache("role",guild,role))
  end
end

return module

--[[
{ name = "Responsible Member", value = auditLog:getMember().mentionString.." (`"..auditLog:getMember().id.."`)", inline = false, },

channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={
      title = "Channel Created",
      fields = {
        {
					name = "Channel",
					value = channel.mentionString,
					inline = true,
				},
        {
					name = "Channel Location",
					value = (channel.category == nil and "Not Categorized" or channel.category.name),
					inline = true,
				},
      },
      color = 16580705,
}}
--]]