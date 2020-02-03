command = {}

local config = require("/app/config.lua")
local utils = require("/app/resolve-user.lua")
local discordia = require("discordia")
local Date = discordia.Date

command.info = {
  Name = "Whois",
  Alias = {"w","userinfo"},
  Usage = "whois <optional user>",
  Description = "Views information on a specified user.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if args[2] == nil then args[2] = message.author.id end
  local user = utils.resolveUser(message,args[2])
  local inGuild = true
  if user == false and tonumber(args[2]) ~= nil then if client:getUser(args[2]) ~= nil then user = client:getUser(args[2]) inGuild = false else user = false end end
  if user == false then
    return {success = false, msg = "I couldn't find the user you mentioned."}
  else
    if inGuild then
      message:reply{embed = {
				author = {name = user.tag, icon_url = user:getAvatarURL()},
        --title = "**Whois Lookup Results**",
        fields = {
          {
            name = "Mention",
            value = user.mentionString,
            inline = true
          },
          {
            name = "Tag",
            value = user.tag,
            inline = true
          },
          {
            name = "ID",
            value = user.id,
            inline = true
          },
          {
            name = "Created At",
            value = Date.fromSnowflake(user.id):toISO(' ', ''),
            inline = true
          },
          {
            name = "Activity",
            value = (user.activity == nil and "Nothing" or (user.activity.type == 2 and "Listening to "..user.activity.name or (user.activity.type == 1 and "Streaming "..user.activity.name or user.activity.name))),
            inline = true,
          },
        },
				thumbnail = {
					url = user:getAvatarURL()
				},
				footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
				color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
			}}
      return {success = "stfu", msg = ""}
    else
      local data = {embed = {
				author = {name = user.tag, icon_url = user:getAvatarURL()},
        --title = "**Whois Lookup Results**",
        description = "**This user isn't in the guild.**",
        fields = {
          {
            name = "Mention",
            value = user.mentionString,
            inline = true
          },
          {
            name = "Tag",
            value = user.tag,
            inline = true
          },
          {
            name = "ID",
            value = user.id,
            inline = true
          },
          {
            name = "Created At",
            value = Date.fromSnowflake(user.id):toISO(' ', ''),
            inline = true
          },
        },
				thumbnail = {
					url = user:getAvatarURL()
				},
				footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
				color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
			}}
      local useGuild
      for a,b in pairs(client.guilds) do if b:getMember(user.id) ~= nil then print('xd',b.id) useGuild = b:getMember(user.id)break end end
      if useGuild == nil then
        message:reply(data)
      else
        table.insert(data.embed.fields,#data.embed.fields+1, {name = "Activity", value = (useGuild.activity == nil and "Nothing" or (useGuild.activity.type == 2 and "Listening to "..useGuild.activity.name or (useGuild.activity.type == 1 and "Streaming "..useGuild.activity.name or useGuild.activity.name))), inline = true})
        table.insert(data.embed.fields,#data.embed.fields+1, {name = "Status", value = useGuild.status, inline = true})
        message:reply(data)
      end
      return {success = "stfu",msg = ""}
    end
  end
end

return command