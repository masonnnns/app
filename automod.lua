plugin = {}

local timer = require("timer")

local infractions = {}
-- infractions[GUILDID..USERID] = {1, 2, 3}

local function strike(message,data)
  local id = message.guild.id..message.author.id
  if infractions[id] == nil then infractions[id] = {} infractions[id][1] = os.time() return true end
  infractions[id][1+#infractions[id]] = os.time()
  local ten, thirty, hour = 0, 0, 0
  if #infractions[id] >= 3 then
    for _,items in pairs(infractions[id]) do
      if items + 600 >= os.time() then ten = ten + 1 end
      if items + 1800 >= os.time() then thirty = thirty + 1 end
      if items + 3600 >= os.time() then hour = hour + 1 end
      if items + 3600 < os.time() then table.remove(infractions[id],_) end
    end
  end
  if data.general.mutedrole ~= "nil" and message.guild:getRole(data.general.mutedrole) ~= nil then
    if hour >= 14 then --// we're just going to start kicking them
      return false
    elseif hour == 11 then
      return false
    elseif thirty == 6 then
      return false
    elseif ten == 4 then
      data.moderation.cases[1+#data.moderation.cases] = {type = "mute", user = message.author.id, moderator = "414030463792054282", reason = "Three automod violations in ten minutes.", duration = "5 Minutes", modlog = "nil"}
      data.moderation.actions[1+#data.moderation.actions] = {type = "mute", duration = os.time() + 300, moderator = "414030463792054282", case = #data.moderation.cases, id = message.author.id}
      message.guild:getMember(message.author.id):addRole(data.general.mutedrole)
      if data.general.modlog ~= "nil" and message.guild:getChannel(data.general.modlog) ~= nil then
          local modlog = message.guild:getChannel(data.general.modlog):send{embed = {
          title = "Automatic Mute - Case "..#data.moderation.cases,
          fields = {
            {name = "User", value = message.author.tag.." (`"..message.author.id.."`)", inline = false},
            {name = "Moderator", value = message.guild:getMember("414030463792054282").tag.." (`414030463792054282`)",inline = true},
            {name = "Duration", value = "5 Minutes", inline = true},
            {name = "Reason", value = "Three automod violations in ten minutes.", inline = false},
          },
          color = 15105570,
        }}
        data.moderation.cases[#data.moderation.cases].modlog = modlog.id    
      end
      return false
    else
      return true
    end
  else
    return true
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

plugin = function(message, data, client)
  local a, b = string.gsub(message.content,"\n","")
  local c, d = string.gsub(message.content,"||","")
  if data.automod.newline.enabled and b + 1 > data.automod.newline.limit then
    message:delete()
    if data.automod.log ~= "nil" and message.guild:getChannel(data.automod.log) ~= nil then
      message.guild:getChannel(data.automod.log):send{embed = {
        title = "Automod Violation",
        color = 15105570,
        timestamp = require("discordia").Date():toISO('T', 'Z'),
        fields = {
          {name = "Message Author", value = message.author.tag.." (`"..message.author.id.."`)", inline = true},
          {name = "Channel", value = message.channel.mentionString, inline = true},
          {name = "Reason", value = "Too many newlines. ("..(b+1)..")", inline = false},
          {name = "Message", value = message.content, inline = false},
        }
      }}
    end
    if strike(message,data) == true then
      local reply = message:reply(message.author.mentionString..", too many newlines.")
      timer.sleep(3000)
      reply:delete()
    end
  elseif data.automod.spoilers.enabled and d/2 > data.automod.spoilers.limit then
    message:delete()
    if data.automod.log ~= "nil" and message.guild:getChannel(data.automod.log) ~= nil then
      message.guild:getChannel(data.automod.log):send{embed = {
        title = "Automod Violation",
        color = 15105570,
        timestamp = require("discordia").Date():toISO('T', 'Z'),
        fields = {
          {name = "Message Author", value = message.author.tag.." (`"..message.author.id.."`)", inline = true},
          {name = "Channel", value = message.channel.mentionString, inline = true},
          {name = "Reason", value = "Too many spoilers. ("..(d/2)..")", inline = false},
          {name = "Message", value = message.content, inline = false},
        }
      }}
    end
    if strike(message,data) == true then
      local reply = message:reply(message.author.mentionString..", too many spoilers.")
      timer.sleep(3000)
      reply:delete()
    end
  elseif data.automod.mentions.enabled and #message.mentionedRoles + #message.mentionedUsers > data.automod.mentions.limit then
    message:delete()
    if data.automod.log ~= "nil" and message.guild:getChannel(data.automod.log) ~= nil then
      message.guild:getChannel(data.automod.log):send{embed = {
        title = "Automod Violation",
        color = 15105570,
        timestamp = require("discordia").Date():toISO('T', 'Z'),
        fields = {
          {name = "Message Author", value = message.author.tag.." (`"..message.author.id.."`)", inline = true},
          {name = "Channel", value = message.channel.mentionString, inline = true},
          {name = "Reason", value = "Mentioned "..(#message.mentionedRoles + #message.mentionedUsers).." different roles or members.", inline = false},
          {name = "Message", value = message.content, inline = false},
        }
      }}
    end
    if strike(message,data) == true then
      local reply = message:reply(message.author.mentionString..", no mass-mentioning.")
      timer.sleep(3000)
      reply:delete()
    end
  else
    local sep = sepMsg(message.content)
    if data.automod.invites.enabled then
      for _,items in pairs(sep) do
        if string.match(items:lower(),"discord.gg") or string.match(items:lower(),"discordapp.com/invite") then
          message:delete()
          if data.automod.log ~= "nil" and message.guild:getChannel(data.automod.log) ~= nil then
            message.guild:getChannel(data.automod.log):send{embed = {
              title = "Automod Violation",
              color = 15105570,
              timestamp = require("discordia").Date():toISO('T', 'Z'),
              fields = {
                {name = "Message Author", value = message.author.tag.." (`"..message.author.id.."`)", inline = true},
                {name = "Channel", value = message.channel.mentionString, inline = true},
                {name = "Reason", value = "Invite link.", inline = false},
                {name = "Message", value = message.content, inline = false},
              }
            }}
          end
          if strike(message,data) == true then
            local reply = message:reply(message.author.mentionString..", no invites.")
            timer.sleep(3000)
            reply:delete()
          end
          return
        end
      end
    end
    if data.automod.words.enabled then
      for _,items in pairs(sep) do
        for _,terms in pairs(data.automod.words.terms) do
          if string.match(items:lower(),terms:lower()) then
            message:delete()
            if data.automod.log ~= "nil" and message.guild:getChannel(data.automod.log) ~= nil then
              message.guild:getChannel(data.automod.log):send{embed = {
                title = "Automod Violation",
                color = 15105570,
                timestamp = require("discordia").Date():toISO('T', 'Z'),
                fields = {
                  {name = "Message Author", value = message.author.tag.." (`"..message.author.id.."`)", inline = true},
                  {name = "Channel", value = message.channel.mentionString, inline = true},
                  {name = "Reason", value = "Bad word usage.", inline = false},
                  {name = "Message", value = message.content, inline = false},
                }
              }}
            end
            if strike(message,data) == true then
              local reply = message:reply(message.author.mentionString..", watch your language.")
              timer.sleep(3000)
              reply:delete()
            end
            return
          end
        end
      end
    end
    local antispam = require("/app/antispam.lua")(message)
    if antispam.safe == false then
      message.channel:bulkDelete(antispam.messages)
      if data.automod.log ~= "nil" and message.guild:getChannel(data.automod.log) ~= nil then
        message.guild:getChannel(data.automod.log):send{embed = {
          title = "Automod Violation",
          color = 15105570,
          timestamp = require("discordia").Date():toISO('T', 'Z'),
          fields = {
            {name = "Message Author", value = message.author.tag.." (`"..message.author.id.."`)", inline = true},
            {name = "Channel", value = message.channel.mentionString, inline = true},
            {name = "Reason", value = antispam.reason, inline = false},
            {name = "Message", value = message.content, inline = false},
          }
        }}
      end
      if strike(message,data) == true then
        local reply = message.channel:send(message.author.mentionString..", no spamming.")
        timer.sleep(3000)
        reply:delete()
      end
      return
    end
  end
end

return plugin