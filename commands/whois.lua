command = {}

local config = require("/app/config.lua")
local utils = require("/app/resolve-user.lua")
local cache = require("/app/server.lua")
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
  local user = utils.resolveUser(message,table.concat(args," ",2))
  local inGuild = true
  if user == false and tonumber(args[2]) ~= nil then if client:getUser(args[2]) ~= nil then user = client:getUser(args[2]) inGuild = false else user = false end end
  if user == false then
    return {success = false, msg = "I couldn't find the user you mentioned."}
  else
    if inGuild then
      local perm = utils.getPermission(message,false,user.id)
      local roles = {}
      for items,_ in pairs(cache.getCache("user",message.guild.id,user.id).roles) do roles[1+#roles] = message.guild:getRole(items).mentionString end
      local data = {embed = {
				author = {name = user.tag, icon_url = user:getAvatarURL()},
        --title = "**Whois Lookup Results**",
        fields = {
          {
            name = "Mention",
            value = user.mentionString,
            inline = true
          },
          {
            name = "ID",
            value = user.id,
            inline = true
          },
          {
            name = "Nickname",
            value = (user.nickname == nil and "None Set." or user.nickname),
            inline = true,
          },
          {
            name = "Status",
            value = user.status,
            inline = true
          },
          {
            name = "Activity",
            value = (user.activity == nil and "Nothing" or (user.activity.type == 2 and "Listening to "..user.activity.name or (user.activity.type == 1 and "Streaming "..user.activity.name or user.activity.name))),
            inline = true,
          },
          {
            name = "Server Permission",
            value = (perm == 1 and "Server Moderator" or (perm == 2 and "Server Administrator" or (perm == 3 and "Server Owner" or "User"))),
            inline = true
          },
          {
            name = "Role"..(#roles == 1 and "" or "s").." ["..#roles.."]",
            value = (#roles == 0 and "No Roles!" or table.concat(roles, " ")),
            inline = false
          },
          {
            name = "Created At",
            value = Date.fromSnowflake(user.id):toISO(' ', ''),
            inline = true,
          },
          {
            name = "Joined At",
            value = (message.guild:getMember(user.id).joinedAt and message.guild:getMember(user.id).joinedAt:gsub('%..*', ''):gsub('T', ' ') or "ERROR"),
            inline = true,
          },
        },
				thumbnail = {
					url = user:getAvatarURL()
				},
				footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
        color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
			}}
      if user.id == client.owner.id then
        table.insert(data.embed.fields,#data.embed.fields+1, {name = "Notes", value = "AA-R0N Owner & Developer", inline = false})
      end
      message:reply(data)
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
        color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
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