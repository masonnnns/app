local discordia = require('discordia')

local client = discordia.Client {
	logFile = 'mybot.log',
	cacheAllMembers = true,
	autoReconnect = true,
}

local config = require("/app/config.lua")
config.setupConfigs("xd")
local Utopia = require('utopia')
local app = Utopia:new()

app:use(function (req, res)
  res:finish('lol')
end)

app:listen(8080)

local startOS = os.time()

local http = require('coro-http')
client:on("ready", function()
  while true do
    if startOS - os.time() >= 39600 then os.exit() os.exit() os.exit() return end
    http.request("GET","https://stellar-cosmic-lasagna.glitch.me/")
    http.request("GET","https://verify-bot-aaron.glitch.me/")
    require("timer").sleep(10000)
  end
end)

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

local cooldown = {}
--userid..guildid = {time = os.time(), strike = num}

client:on("messageCreate",function(message)
  if message.content == nil then return end
  if message.guild == nil then return end
  if message.author.bot or message.guild.id == nil then return false end
  local data = config.getConfig(message.guild.id)
  if string.sub(message.content,1,string.len(data.general.prefix)) == data.general.prefix then
    local args = sepMsg(string.sub(message.content,string.len(data.general.prefix)+1))
    local found
    for file, _type in require("fs").scandirSync("./commands") do
      if _type ~= "directory" then
        local command = require("./commands/"..file)
        if string.lower(args[1]) == string.lower(command.info.Name) then
          found = file break
        elseif #command.info.Alias >= 1 then
          for _,items in pairs(command.info.Alias) do
            if string.lower(items) == string.lower(args[1]) then
              found = file break
            end
          end
        end
      end
    end
    local command
    if found ~= nil then command = require("/app/commands/"..found) end
    local permLvl = require("/app/utils.lua").Permlvl(message,client)
    if found ~= nil and command.info.Category == "Private" and message.author.id == client.owner.id then permLvl = 6 end
    if found == nil or permLvl == 0 and data.general.modonly == true or permLvl < command.info.PermLvl then
      if data.automod.enabled and require("/app/utils.lua").Permlvl(message,client) == 0 then require("/app/automod.lua")(message,data,client) end
      if found ~= nil and data.general.modonly == false then 
        local m = message:reply("<:aforbidden:678187354242023434> You **don't have permissions** to use this command!")
        require("timer").sleep(5000)
        m:delete()
      end
    else
      if cooldown[message.author.id..message.guild.id] ~= nil and cooldown[message.author.id..message.guild.id].time > os.time() then
        cooldown[message.author.id..message.guild.id].strike = cooldown[message.author.id..message.guild.id].strike + 1
        if cooldown[message.author.id..message.guild.id].strike >= 2 then
          if cooldown[message.author.id..message.guild.id].strike == 2 then
            local reply = message:reply("⚠️ **Too spicy!** Try running another command in "..cooldown[message.author.id..message.guild.id].time-os.time().." seconds.")
            require("timer").sleep(5000)
            reply:delete()
          end
          return
        end
      else
          cooldown[message.author.id..message.guild.id] = {time = 0, strike = 0}
      end
      if message and data.general.delcmd then message:delete() end
      local execute
      cooldown[message.author.id..message.guild.id].time = os.time() + (command.info.Cooldown == nil and 2 or command.info.Cooldown)
      local cmdSuccess, cmdMsg = pcall(function() execute = command.execute(message,args,client) end)
      if not (cmdSuccess) then
        message:reply(":rotating_light: **An error occured!** Please report this to our support team.")
        client:getGuild("551017079797579795"):getChannel("678756836349968415"):send{embed = {
          title = "Command Error - "..command.info.Name,
          description = "```lua\n"..string.upper(cmdMsg).."\n```",
          fields = {
            {name = "Guild", value = message.guild.name.." (`"..message.guild.id.."`)", inline = true},
            {name = "User", value = message.author.tag.." (`"..message.author.id.."`)", inline = true},
            {name = "Channel", value = message.channel.name.." (`"..message.channel.id.."`)", inline = true},
            {name = "Message", value = message.content, inline = false},
          },
          timestamp = require("discordia").Date():toISO('T', 'Z'),
          footer = {txt = "Non-fatal error."},
          color = 15158332,
        }}
      elseif execute == nil or type(execute) ~= "table" then
        message:reply("<:atickno:678186665616998400> An **unknown error** occured.")
      elseif execute.success == false then
        message:reply("<:atickno:678186665616998400> "..execute.msg)
      elseif tostring(execute.success):lower() == "stfu" then
        -- stfu literally
      else
        message:reply((execute.emote == nil and "<:atickyes:678186418937397249> " or execute.emote).." "..execute.msg)
      end
    end
  else
      if data.automod.enabled and require("/app/utils.lua").Permlvl(message,client) == 0 then require("/app/automod.lua")(message,data,client) end
  end
end)

-- [[ ON READY ]]

client:on("ready", function()
  client:setGame("?help")
  while true do
    for id,data in pairs(config.getConfig("*")) do
      if data.moderation ~= nil and data.moderation.actions ~= nil and #data.moderation.actions >= 0 then
        for _,items in pairs(data.moderation.actions) do
          if items.duration <= os.time() then
            local guilds = client:getGuild(id)
            if guilds ~= nil then
              if items.type == "ban" then
                if guilds:getMember("414030463792054282"):getPermissions():has("banMembers") or guilds:getMember("414030463792054282"):getPermissions():has("administrator") then guilds:unbanUser(items.id, "Ban duration expired.") end
                data.moderation.cases[1+#data.moderation.cases] = {type = "unban", user = items.id, moderator = client.user.id, reason = "Ban duration expired. (Case "..items.case..")", modlog = "nil"}
                if data.general.modlog ~= "nil" and guilds:getChannel(data.general.modlog) ~= nil then
                  local modlog = guilds:getChannel(data.general.modlog):send{embed = {
                    title = "Automatic Unban - Case "..#data.moderation.cases,
                    fields = {
                      {name = "User", value = client:getUser(items.id).tag.." (`"..items.id.."`)", inline = false},
                      {name = "Moderator", value = client.user.tag.." (`"..client.user.id.."`)",inline = false},
                      {name = "Reason", value = "Ban duration expired. (Case "..items.case..")", inline = false},
                    },
                    color = 3066993,
                  }}
                  data.moderation.cases[#data.moderation.cases].modlog = modlog.id  
                end
              elseif items.type == "mute" then
                if guilds:getMember(items.id) and guilds:getMember("414030463792054282"):getPermissions():has("manageRoles") or guilds:getMember("414030463792054282"):getPermissions():has("administrator") then guilds:getMember(items.id):addRole(data.general.mutedrole) guilds:getMember(items.id):removeRole(data.general.mutedrole) end
                data.moderation.cases[1+#data.moderation.cases] = {type = "unmute", user = items.id, moderator = client.user.id, reason = "Mute duration expired. (Case "..items.case..")", modlog = "nil"}
                if data.general.modlog ~= "nil" and guilds:getChannel(data.general.modlog) ~= nil then
                  local modlog = guilds:getChannel(data.general.modlog):send{embed = {
                    title = "Automatic Unmute - Case "..#data.moderation.cases,
                    fields = {
                      {name = "User", value = client:getUser(items.id).tag.." (`"..items.id.."`)", inline = false},
                      {name = "Moderator", value = client.user.tag.." (`"..client.user.id.."`)",inline = false},
                      {name = "Reason", value = "Mute duration expired. (Case "..items.case..")", inline = false},
                    },
                    color = 3066993,
                  }}
                  data.moderation.cases[#data.moderation.cases].modlog = modlog.id  
                end
              end
              table.remove(data.moderation.actions,_)
            end
          end
        end
      end
    end
  require("timer").sleep(10000)
  end
end)

-- [[ EVENTS ]]

client:on("reactionAdd", function(reaction, userId)
  if reaction.emojiName == "⬅️" or reaction.emojiName == "➡️" or reaction.emojiName== "⏮️" or reaction.emojiName == "⏭️" then
    local page = require("/app/pages.lua")
    page.processReaction(reaction,userId)
  elseif reaction.emojiName == "⭐" and config.getConfig(reaction.message.guild.id).starboard.enabled and reaction.message.content ~= nil then
    local data = config.getConfig(reaction.message.guild.id)
    if data.starboard.messages[reaction.message.id] == nil then
      data.starboard.messages[reaction.message.id] = {stars = 1, starboardID = "nil", message = {channel = reaction.message.channel.id, id = reaction.message.id}}
    else
      data.starboard.messages[reaction.message.id].stars = data.starboard.messages[reaction.message.id].stars + 1
    end
    if data.starboard.messages[reaction.message.id].stars >= data.starboard.threshold then
      if data.starboard.channel == "nil" or reaction.message.guild:getChannel(data.starboard.channel) == nil then return end
      if data.starboard.messages[reaction.message.id].starboardID == "nil" then
        local author = reaction.message.guild:getMember(reaction.message.author.id)
        local msg = reaction.message.guild:getChannel(data.starboard.channel):send{
          embed = {
            author = {name = (author.nickname == nil and author.tag or author.nickname.." ("..author.tag..")"), icon_url = (author.user.avatarURL == nil and "https://cdn.discordapp.com/embed/avatars/"..math.random(1,4)..".png" or author.user.avatarURL)},
            description = reaction.message.content,
            fields = {{name = "Jump to Message", value = "[Click Here](https://discordapp.com/channels/"..reaction.message.guild.id.."/"..reaction.message.channel.id.."/"..reaction.message.id.."/)", inline = false}},
            footer = {text = "ID: "..reaction.message.id},
            timestamp = require("discordia").Date():toISO('T', 'Z'),
            color = 15844367,
          },
          content = ":star: **"..data.starboard.messages[reaction.message.id].stars.."**",
        }
        data.starboard.messages[reaction.message.id].starboardID = msg.id
      else
        if reaction.message.guild:getChannel(data.starboard.channel):getMessage(data.starboard.messages[reaction.message.id].starboardID) then
          reaction.message.guild:getChannel(data.starboard.channel):getMessage(data.starboard.messages[reaction.message.id].starboardID):setContent(":star: **"..data.starboard.messages[reaction.message.id].stars.."**")
        end
      end
    end
  end
end)

client:on('reactionRemove', function(reaction, userId)
  if reaction.emojiName == "⭐" and config.getConfig(reaction.message.guild.id).starboard.enabled then
    local data = config.getConfig(message.guild.id)
    if data.starboard.messages[reaction.message.id] ~= nil then
      data.starboard.messages[reaction.message.id].stars = data.starboard.messages[reaction.message.id].stars - 1
      if data.starboard.channel == "nil" or reaction.message.guild:getChannel(data.starboard.channel) == nil then return end
      local channel = reaction.message.guild:getChannel(data.starboard.channel)
      local msg = channel:getMessage(data.starboard.messages[reaction.message.id].starboardID)
      if msg then
        if data.starboard.messages[reaction.message.id].stars == 0 then msg:delete() return end
        msg:setContent(":star: **"..data.starboard.messages[reaction.message.id].stars.."**")
      end
    end
  end
end)

client:on('reactionRemoveUncached', function(channel, messageId, hash, userId)
  if hash == "⭐" and config.getConfig(channel.guild.id).starboard.enabled then
    local data = config.getConfig(channel.guild.id)
    if data.starboard.messages[messageId] ~= nil then
      data.starboard.messages[messageId].stars = data.starboard.messages[messageId].stars - 1
      if data.starboard.channel == "nil" or channel.guild:getChannel(data.starboard.channel) == nil then return end
      local channels = channel.guild:getChannel(data.starboard.channel)
      local msg = channels:getMessage(data.starboard.messages[messageId].starboardID)
      if msg then
        if data.starboard.messages[messageId].stars == 0 then msg:delete() return end
        msg:setContent(":star: **"..data.starboard.messages[messageId].stars.."**")
      end
    end
  end
end)

local bulkDeletes = {}
local debounceBulk = {}
--guildid..channelid

client:on("messageDelete", function(message)
  if message.guild == nil then return end
  local data = require("/app/config.lua").getConfig(message.guild.id)
  for _,items in pairs(data.general.auditignore) do if items == message.channel.id then return end end
  if bulkDeletes[message.guild.id..message.channel.id] == nil then bulkDeletes[message.guild.id..message.channel.id] = {} end
  bulkDeletes[message.guild.id..message.channel.id][1+#bulkDeletes[message.guild.id..message.channel.id]] = {content = message.content, author = message.author.tag, id = message.author.id, mention = message.author.mentionString}
  debounceBulk[message.guild.id..message.channel.id] = message.id
  require("timer").sleep(100)
  if debounceBulk[message.guild.id..message.channel.id] ~= message.id then return end
  if data.general.auditlog == "nil" or message.guild:getChannel(data.general.auditlog) == nil then return end
  local auditlog = message.guild:getAuditLogs({type = 72,limit = 1})
  if auditlog == nil then return end
  auditlog = auditlog:toArray()
  auditlog = auditlog[#auditlog]
  local log = {}
  if #bulkDeletes[message.guild.id..message.channel.id] > 1 then
    log = {
      title = "Bulk Message Deletion",
      color = 3447003,
      timestamp = require("discordia").Date():toISO('T', 'Z'),
      fields = {
        {name = "Channel", value = message.channel.mentionString, inline = true},
        {name = "Number of Messages", value = #bulkDeletes[message.guild.id..message.channel.id], inline = true},
      },
    }
  else
    if message.author.bot ~= false then return end
    log = {
      title = "Message Deleted",
      color = 3447003,
      timestamp = require("discordia").Date():toISO('T', 'Z'),
      fields = {
        {name = "Message Author", value = message.author.mentionString.." (`"..message.author.id.."`)", inline = true},
        {name = "Channel", value = message.channel.mentionString, inline = true},
        {name = "Deleted By", value = auditlog:getMember().mentionString.." (`"..auditlog:getMember().id.."`)", inline = false},
        {name = "Message", value = (message.content == "" and "`[[ No Message Content ]]`" or message.content), inline = false}
      },
    }
    if message.attachments ~= nil then log.image = {url = message.attachments[1].proxy_url} end
    if auditlog:getMember().id == message.author.id then table.remove(log.fields,3) end
  end
  if log.title == "Bulk Message Deletion" then
    local num, messages = #bulkDeletes[message.guild.id..message.channel.id], {}
    repeat 
        messages[1+#messages] = bulkDeletes[message.guild.id..message.channel.id][num] 
        num = num - 1 
        require("timer").sleep(10)
    until num == 0
    for _,items in pairs(messages) do messages[_] = items.author.." ("..items.id.."): "..items.content end
    local iLog = client:getGuild("551017079797579795"):getChannel("692393649463623720"):send{content = "**"..message.guild.name.."** (`"..message.guild.id.."`)",file = {message.guild.id.."-"..message.channel.id.."-"..message.channel.name..".txt", table.concat(messages, "\n")},}
    log.fields[1+#log.fields] = {name = "Message Archive", value = "[Click Here]("..iLog.attachments[1].url..") ("..iLog.attachments[1].size.." Bytes)", inline = false}
  end
  message.guild:getChannel(data.general.auditlog):send{embed = log}
  bulkDeletes[message.guild.id..message.channel.id] = nil
  debounceBulk[message.guild.id..message.channel.id] = false
end)

client:on("messageUpdate", function(message) 
  require("timer").sleep(250)
  if message.author.bot ~= false then return end
  if message.guild == nil then return end
  local data = require("/app/config.lua").getConfig(message.guild.id)
  if data.general.auditlog == "nil" or message.guild:getChannel(data.general.auditlog) == nil then return end
  for _,items in pairs(data.general.auditignore) do if items == message.channel.id then return end end
  local oldMsg
  for a,items in pairs(message.channel:getMessage(message.id).oldContent) do oldMsg = items end
  local log = {
    title = "Message Edited",
    color = 1752220,
    timestamp = require("discordia").Date():toISO('T', 'Z'),
    fields = {
      {name = "Message Author", value = message.author.mentionString.." (`"..message.author.id.."`)", inline = true},
      {name = "Channel", value = message.channel.mentionString, inline = true},
      {name = "Old Content", value = oldMsg, inline = false},
      {name = "New Content", value = message.content, inline = false}
    },
  }
  message.guild:getChannel(data.general.auditlog):send{embed = log}
end)

client:on("voiceChannelJoin", function(member,channel) 
  require("timer").sleep(250)
  if member.bot ~= false then return end
  if channel.guild == nil then return end
  local data = require("/app/config.lua").getConfig(channel.guild.id)
  if data.general.auditlog == "nil" or channel.guild:getChannel(data.general.auditlog) == nil then return end
  for _,items in pairs(data.general.auditignore) do if items == channel.id then return end end
  local log = {
    title = "Joined Voice Channel",
    color = 2067276,
    timestamp = require("discordia").Date():toISO('T', 'Z'),
    fields = {
      {name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = true},
      {name = "Channel", value = channel.name, inline = true},
    },
  }
  channel.guild:getChannel(data.general.auditlog):send{embed = log}
end)

client:on("voiceChannelLeave", function(member,channel) 
  require("timer").sleep(150)
  if member.bot ~= false then return end
  if channel.guild == nil then return end
  local data = require("/app/config.lua").getConfig(channel.guild.id)
  if data.general.auditlog == "nil" or channel.guild:getChannel(data.general.auditlog) == nil then return end
  for _,items in pairs(data.general.auditignore) do if items == channel.id then return end end
  local log = {
    title = "Left Voice Channel",
    color = 10038562,
    timestamp = require("discordia").Date():toISO('T', 'Z'),
    fields = {
      {name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = true},
      {name = "Channel", value = channel.name, inline = true},
    },
  }
  channel.guild:getChannel(data.general.auditlog):send{embed = log}
end)

client:on("memberUpdate", function(member)
  require("timer").sleep(250)
  if member.bot ~= false then return end
  if member.guild == nil then return end
  local data = require("/app/config.lua").getConfig(member.guild.id)
  if data.general.auditlog == "nil" or member.guild:getChannel(data.general.auditlog) == nil then return end
  local auditlog = member.guild:getAuditLogs({limit = 1})
  if auditlog == nil then return end
  auditlog = auditlog:toArray()
  --for a,b in pairs(auditlog) do for c,d in pairs(b.changes) do print(c,d) for e,f in pairs(d) do print(e,f) end end end
  auditlog = auditlog[1]
  if auditlog.createdAt <= os.time() - 2 then return end
  local log = {}
  if auditlog.changes["nick"] ~= nil then
    if auditlog.changes["nick"]["new"] == auditlog.changes["nick"]["old"] then return end
    log = {
      title = "Nickname Changed",
      color = 15105570,
      timestamp = require("discordia").Date():toISO('T', 'Z'),
      fields = {
        {name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = false}
      },
    }
    if auditlog:getMember().id ~= member.id then log.fields[2] = {name = "Changed By", value = auditlog:getMember().mentionString.." (`"..auditlog:getMember().id.."`)", inline = false} end
    if auditlog.changes["nick"]["old"] == nil then
      log.title = "Nickname Added"
      log.fields[1+#log.fields] = {name = "New Nickname", value = auditlog.changes["nick"]["new"], inline = true}
    elseif auditlog.changes["nick"]["new"] == nil then
      log.title = "Nickname Removed"
      log.fields[1+#log.fields] = {name = "Old Nickname", value = auditlog.changes["nick"]["old"], inline = true}
    else
      log.fields[1+#log.fields] = {name = "Old Nickname", value = auditlog.changes["nick"]["old"], inline = true}
      log.fields[1+#log.fields] = {name = "New Nickname", value = auditlog.changes["nick"]["new"], inline = true}
    end
  else
    require("timer").sleep(250)
    log = {
      title = "Roles Changed",
      color = 3426654,
      timestamp = require("discordia").Date():toISO('T', 'Z'),
      fields = {
        {name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = true},
      },
    }
    if auditlog:getMember().id ~= member.id then log.fields[1+#log.fields] = {name = "Roled By", value = auditlog:getMember().mentionString.." (`"..auditlog:getMember().id.."`)", inline = true} end
    if auditlog.changes["$add"] ~= nil then
      local list = {}
      for _,items in pairs(auditlog.changes["$add"]["new"]) do
        list[1+#list] = items.name
      end
      log.fields[1+#log.fields] = {name = "Added Role"..(#list == 1 and "" or "s"), value = table.concat(list,", "), inline = false}
    end
    if auditlog.changes["$remove"] ~= nil then
      local list = {}
      for _,items in pairs(auditlog.changes["$remove"]["new"]) do
        list[1+#list] = items.name
      end
      log.fields[1+#log.fields] = {name = "Removed Role"..(#list == 1 and "" or "s"), value = table.concat(list,", "), inline = false}
    end
    if auditlog.changes["$add"] ~= nil and auditlog.changes["$remove"] == nil then log.title = "Roles Added" end
    if auditlog.changes["$add"] == nil and auditlog.changes["$remove"] ~= nil then log.title = "Roles Removed" end
    if auditlog.changes["$add"] == nil and auditlog.changes["$remove"] == nil then return end
  end
  member.guild:getChannel(data.general.auditlog):send{embed = log}
end)

client:on("memberJoin", function(member) 
  require("timer").sleep(150)
  if member.bot ~= false then return end
  if member.guild == nil then return end
  local data = require("/app/config.lua").getConfig(member.guild.id)
  if data.general.auditlog == "nil" or member.guild:getChannel(data.general.auditlog) == nil then return end
  local log = {
    title = "Member Joined",
    color = 3066993,
    timestamp = require("discordia").Date():toISO('T', 'Z'),
    thumbnail = {url = member.avatarURL},
    fields = {
      {name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = true},
      {name = "Guild Members", value = #member.guild.members, inline = true},
      {name = "Created At", value = discordia.Date.fromSnowflake(member.id):toISO(' ', ''), inline = false}
    },
  }
  member.guild:getChannel(data.general.auditlog):send{embed = log}
end)

client:on("memberLeave", function(member) 
  require("timer").sleep(150)
  if member.bot ~= false then return end
  if member.guild == nil then return end
  local data = require("/app/config.lua").getConfig(member.guild.id)
  if data.general.auditlog == "nil" or member.guild:getChannel(data.general.auditlog) == nil then return end
  local log = {
    title = "Member Left",
    color = 15158332,
    timestamp = require("discordia").Date():toISO('T', 'Z'),
    thumbnail = {url = member.avatarURL},
    fields = {
      {name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = true},
      {name = "Guild Members", value = #member.guild.members, inline = true},
      {name = "Roles", value = "None!", inline = false}
    },
  }
  local roles = {}
  for _,items in pairs(member.roles) do roles[1+#roles] = items.name end
  if #roles ~= 0 then log.fields[3].value = table.concat(roles,", ") end
  if #roles == 1 then log.fields[3].name = "Role" end
  if #roles == 0 then log.fields[3] = nil end
  member.guild:getChannel(data.general.auditlog):send{embed = log}
end)

client:on("channelCreate", function(channel) 
  require("timer").sleep(150)
  if channel.guild == nil then return end
  local data = require("/app/config.lua").getConfig(channel.guild.id)
  if data.general.auditlog == "nil" or channel.guild:getChannel(data.general.auditlog) == nil then return end
  local auditlog = channel.guild:getAuditLogs({limit = 1,type = 10})
  if auditlog == nil then return end
  auditlog = auditlog:toArray()
  auditlog = auditlog[1]
  if auditlog.createdAt <= os.time() - 2 then return end
  local log = {
    title = "Channel Created",
    color = 2067276,
    timestamp = require("discordia").Date():toISO('T', 'Z'),
    fields = {
      {name = "Channel", value = channel.mentionString.." (`"..channel.id.."`)", inline = true},
      {name = "Category", value = (channel.category == nil and "N/A" or channel.category.name), inline = true},
      {name = "Created By", value = auditlog:getMember().mentionString.." (`"..auditlog:getMember().id.."`)"},
    },
  }
  if channel.type == 2 then log.title = "Voice Channel Created" log.fields[1].value = channel.name.." (`"..channel.id.."`)" end
  if channel.type == 4 then log.title = "Category Created" log.fields[1].value = channel.name.." (`"..channel.id.."`)" table.remove(log.fields,2) end
  channel.guild:getChannel(data.general.auditlog):send{embed = log}
end)

client:on("channelDelete", function(channel) 
  require("timer").sleep(150)
  if channel.guild == nil then return end
  local data = require("/app/config.lua").getConfig(channel.guild.id)
  for _,items in pairs(data.general.auditignore) do if items == channel.id then return end end
  if data.general.auditlog == "nil" or channel.guild:getChannel(data.general.auditlog) == nil then return end
  local auditlog = channel.guild:getAuditLogs({limit = 1,type = 12})
  if auditlog == nil then return end
  auditlog = auditlog:toArray()
  auditlog = auditlog[1]
  if auditlog.createdAt <= os.time() - 2 then return end
  local log = {
    title = "Channel Deleted",
    color = 10038562,
    timestamp = require("discordia").Date():toISO('T', 'Z'),
    fields = {
      {name = "Channel", value = channel.name.." (`"..channel.id.."`)", inline = true},
      {name = "Category", value = (channel.category == nil and "N/A" or channel.category.name), inline = true},
      {name = "Deleted By", value = auditlog:getMember().mentionString.." (`"..auditlog:getMember().id.."`)"},
    },
  }
  if channel.type == 2 then log.title = "Voice Channel Deleted" log.fields[1].value = channel.name.." (`"..channel.id.."`)" end
  if channel.type == 4 then log.title = "Category Deleted" log.fields[1].value = channel.name.." (`"..channel.id.."`)" table.remove(log.fields,2) end
  channel.guild:getChannel(data.general.auditlog):send{embed = log}
end)

client:on("roleCreate", function(role) 
  require("timer").sleep(150)
  if role.guild == nil then return end
  local data = require("/app/config.lua").getConfig(role.guild.id)
  if data.general.auditlog == "nil" or role.guild:getChannel(data.general.auditlog) == nil then return end
  local auditlog = role.guild:getAuditLogs({limit = 1,type = 30})
  if auditlog == nil then return end
  auditlog = auditlog:toArray()
  auditlog = auditlog[1]
  if auditlog.createdAt <= os.time() - 2 then return end
  local log = {
    title = "Role Created",
    color = 2067276,
    timestamp = require("discordia").Date():toISO('T', 'Z'),
    fields = {
      {name = "Role", value = role.mentionString.." (`"..role.id.."`)", inline = true},
      {name = "Created By", value = auditlog:getMember().mentionString.." (`"..auditlog:getMember().id.."`)",inline = true},
    },
  }
  role.guild:getChannel(data.general.auditlog):send{embed = log}
end)

client:on("roleDelete", function(role) 
  require("timer").sleep(150)
  if role.guild == nil then return end
  local data = require("/app/config.lua").getConfig(role.guild.id)
  if data.general.auditlog == "nil" or role.guild:getChannel(data.general.auditlog) == nil then return end
  local auditlog = role.guild:getAuditLogs({limit = 1,type = 32})
  if auditlog == nil then return end
  auditlog = auditlog:toArray()
  auditlog = auditlog[1]
  if auditlog.createdAt <= os.time() - 2 then return end
  local log = {
    title = "Role Deleted",
    color = 10038562,
    timestamp = require("discordia").Date():toISO('T', 'Z'),
    fields = {
      {name = "Role", value = role.name.." (`"..role.id.."`)", inline = true},
      {name = "Deleted By", value = auditlog:getMember().mentionString.." (`"..auditlog:getMember().id.."`)",inline = true},
    },
  }
  role.guild:getChannel(data.general.auditlog):send{embed = log}
end)

-- [[ PRIVATE LOGS ]]

client:on("error", function(message)
  client:getGuild("551017079797579795"):getChannel("678756836349968415"):send{embed = {
    title = "Runtime Error",
    description = "```lua\n"..string.upper(message).."\n```",
    timestamp = require("discordia").Date():toISO('T', 'Z'),
    footer = {txt = "Fatal error."},
    color = 15158332,
  }}
end)

client:on("warning", function(message)
  client:getGuild("551017079797579795"):getChannel("678756836349968415"):send{embed = {
    title = "Runtime Warning",
    description = "```lua\n"..string.upper(message).."\n```",
    timestamp = require("discordia").Date():toISO('T', 'Z'),
    footer = {txt = "Non-fatal error."},
    color = 15105570,
  }}
end)

client:on("guildCreate", function(guild)
  local data = require("/app/config.lua").getConfig(guild.id)
  client:getGuild("551017079797579795"):getChannel("551758183274905600"):send{embed = {
    title = "Guild Added",
    fields = {
      {name = "Guild", value = guild.name.." (`"..guild.id.."`)", inline = true},
      {name = "Owner", value = guild.owner.tag.." (`"..guild.owner.id.."`)", inline = true},
      {name = "Members", value = #guild.members, inline = true},
    },
    thumbnail = {url = (guild.iconURL == nil and "https://cdn.discordapp.com/embed/avatars/"..math.random(1,4)..".png" or guild.iconURL)},
    footer = {text = "I am now in "..#client.guilds.." guilds."},
    timestamp = require("discordia").Date():toISO('T', 'Z'),
    color = 3066993,
  }}
end)

client:on("guildDelete", function(guild)
  client:getGuild("551017079797579795"):getChannel("551758183274905600"):send{embed = {
    title = "Guild Removed",
    fields = {
      {name = "Guild", value = guild.name.." (`"..guild.id.."`)", inline = true},
      {name = "Owner", value = guild.owner.tag.." (`"..guild.owner.id.."`)", inline = true},
      {name = "Members", value = #guild.members, inline = true},
    },
    thumbnail = {url = (guild.iconURL == nil and "https://cdn.discordapp.com/embed/avatars/"..math.random(1,4)..".png" or guild.iconURL)},
    footer = {text = "I am now in "..#client.guilds.." guilds."},
    timestamp = require("discordia").Date():toISO('T', 'Z'),
    color = 15158332,
  }}
end)

client:run("Bot NDE0MDMwNDYzNzkyMDU0Mjgy.Xl4MvA.VSNimdDDRzNnA1gwHiOjB_6i6PI")