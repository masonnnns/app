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

client:on("ready", function()
  for _,guilds in pairs(client.guilds) do
    cache[guilds.id] = {users = {}, channels = {}, roles = {}}
    for _,users in pairs(guilds.members) do
       cache[guilds.id].users[users.id] = {roles = {}, nickname = (users.nickname == nil and "5FFA914BBF6B3D6149B228E8ED0AA2F1789C62227D4CEF4D9FE61D5E0F10597D" or users.nickname)}
       for _,items in pairs(users.roles) do cache[guilds.id].users[users.id].roles[items.id] = true end
       print("[USER CACHED]: "..users.name.." has been cached in "..guilds.name..".")
    end
    for _,channels in pairs(guilds.textChannels) do
      cache[guilds.id].channels[channels.id] = {name = channels.name, nsfw = channels.nsfw, ratelimit = channels.rateLimit, topic = (channels.topic ~= nil and channels.topic or "5FFA914BBF6B3D6149B228E8ED0AA2F1789C62227D4CEF4D9FE61D5E0F10597D"), permissions = channels.permissionOverwrites, position = channels.position, category = (channels.category == nil and "nil" or channels.category.id)}
      print("[CHANNEL CACHED]: "..channels.name.." has been cached in "..guilds.name..".")
    end
    for _,channels in pairs(guilds.categories) do
      cache[guilds.id].channels[channels.id] = {name = channels.name, permissions = channels.permissionOverwrites, position = channels.position}
      print('[CATEGORY CACHED]: '..channels.name.." has been cached in "..guilds.name..".")
    end
    for _,channels in pairs(guilds.voiceChannels) do
      cache[guilds.id].channels[channels.id] = {name = channels.name, userlimit = channels.userLimit, bitrate = channels.bitrate, permissions = channels.permissionOverwrites, category = (channels.category == nil and "nil" or channels.category.id)}
      print("[VOICE CHANNEL CACHED]: "..channels.name.." has been cached in "..guilds.name..".")
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
              if client:getGuild(id):getMember(action.user) ~= nil and configData.mutedrole ~= "nil" and client:getGuild(id):getRole(configData.mutedrole) ~= nil then
                client:getGuild(id):getMember(action.user):removeRole(configData.mutedrole)
              end
              configData.modData.cases[1+#configData.modData.cases] = {type = "Auto Unmute", user = action.user, moderator = client.user.id, reason = "Mute duration expired."}
              configuration.updateConfig(id,configData)
              if configData.modlog ~= "nil" and client:getGuild(id):getChannel(configData.modlog) then
                client:getGuild(id):getChannel(configData.modlog):send{embed = { title = "Auto Unmute - Case "..#configData.modData.cases, fields = { { name = "Member", value = client:getUser(action.user).tag.." (`"..action.user.."`)", inline = true, }, { name = "Reason", value = "Mute duration expired.", inline = false, }, { name = "Responsible Moderator", value = client.user.mentionString.." (`"..client.user.id.."`)", inline = false, }, }, color = 2067276, }} 
              end
              client:getGuild(id):getMember(action.user):removeRole(configData.mutedrole)
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
    -- automod / log message
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
      local m = message:reply(":no_entry: You **don't have permissions** to use this command!")
      timer.sleep(5000)
      m:delete()
    end
  end
end)

-- AUDIT LOGGING

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
  if member.guild == nil then return end
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
          member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "Roles Changed", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = false, }, { name = "Role"..(#roles.added == 1 and "" or "s").." Added", value = table.concat(lists.added,", "), inline = true, }, { name = "Role"..(#roles.removed == 1 and "" or "s").." Removed", value = table.concat(lists.removed,", "), inline = true, }, }, color = 11027200, }}
        else
          member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "Roles Changed", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = false, }, { name = "Role"..(#roles.added == 1 and "" or "s").." Added", value = table.concat(lists.added,", "), inline = true, }, { name = "Role"..(#roles.removed == 1 and "" or "s").." Removed", value = table.concat(lists.removed,", "), inline = true, }, { name = "Responsible Member", value = auditLog:getMember().mentionString.." (`"..auditLog:getMember().id.."`)", inline = false, }, }, color = 11027200, }}
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
          member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "Nickname Edited", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = false, }, { name = "New Nickname", value = member.nickname, inline = true, }, { name = "Old Nickname", value = cache[member.guild.id].users[member.id].nickname, inline = true, }, }, color = 11027200, }}
        else
          member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "Nickname Edited", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = false, }, { name = "New Nickname", value = member.nickname, inline = true, }, { name = "Old Nickname", value = cache[member.guild.id].users[member.id].nickname, inline = true, }, { name = "Responsible Member", value = auditLog:getMember().mentionString.." (`"..auditLog:getMember().id.."`)", inline = false, }, }, color = 11027200, }}
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
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = "Category Deleted", fields = { { name = "Category", value = channel.name, inline = true, }, { name = "Previous Position", value = "#"..channel.position, inline = true, }, }, color = 12745742, }}
    else
      channel.guild:getChannel(config[channel.guild.id].auditlog):send{embed ={ title = "Category Deleted", fields = { { name = "Category", value = channel.name, inline = true, }, { name = "Previous Position", value = "#"..channel.position, inline = true, }, { name = "Responsible Member", value = auditLog:getMember().mentionString.." (`"..auditLog:getMember().id.."`)", inline = false, }, }, color = 10038562, }}
    end
  end
end)

client:run('Bot NDYzODQ1ODQxMDM2MTE1OTc4.XjNGOg.nO_mTiCpbeGqyGnlhz5KGGHYn6I')

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