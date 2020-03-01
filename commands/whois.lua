command = {}

local config = require("/app/config.lua")
local utils = require("/app/utils.lua")
local discordia = require("discordia")
local Date = discordia.Date

command.info = {
  Name = "Userinfo",
  Alias = {"w","whois"},
  Usage = "userinfo <optional user>",
  Category = "Utility",
  Description = "Views information on a specified user.",
  PermLvl = 0,
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
      local perm = utils.Permlvl(message,client,user.id)
      if perm == 1 then
        perm = "Server Moderator"
      elseif perm == 2 then
        perm = "Server Administrator"
      elseif perm == 3 then
        perm = "Server Owner"
      else
        perm = "Member"
      end
      local roles = {}
      local perms = {}
      for a,items in pairs(user:getPermissions():toTable()) do
        if items == true then
          perms[1+#perms] = string.sub(a,1,1):upper()..string.sub(a,2)
        end
      end
      pcall(function() for items,_ in pairs(user.roles) do roles[1+#roles] = message.guild:getRole(items).mentionString end end)
      local data = {embed = {
				--author = {name = user.tag, icon_url = user:getAvatarURL()},
        title = user.tag,
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
            value = string.sub(user.status,1,1):upper()..string.sub(user.status,2),
            inline = true
          },
          {
            name = "Activity",
            value = (user.activity == nil and "Nothing" or (user.activity.type == 2 and "Listening to "..user.activity.name or (user.activity.type == 1 and "Streaming "..user.activity.name or user.activity.name))),
            inline = true,
          },
          {
            name = "Server Permission",
            value = perm,
            inline = true
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
          {
            name = "Role"..(#roles == 1 and "" or "s").." ["..#roles.."]",
            value = (#roles == 0 and "No Roles!" or table.concat(roles, " ")),
            inline = false
          },
          {
            name = "Permissions",
            value = (#perms == 0 and "No Permissions!" or table.concat(perms,", ")),
            inline = false,
          },
        },
				thumbnail = {
					url = user:getAvatarURL()
				},
				footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
        color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
			}}
      if user.id == client.owner.id then
        table.insert(data.embed.fields,#data.embed.fields+1, {name = "Notes", value = "AA-R0N Owner & Developer", inline = false})
      end
      message:reply(data)
      return {success = "stfu", msg = ""}
    else
      local data = {embed = {
        title = user.tag,
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
        color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
			}}
      local useGuild
      for a,b in pairs(client.guilds) do if b:getMember(user.id) ~= nil then useGuild = b:getMember(user.id)break end end
      if useGuild == nil then
        message:reply(data)
      else
        table.insert(data.embed.fields,#data.embed.fields+1, {name = "Activity", value = (useGuild.activity == nil and "Nothing" or (useGuild.activity.type == 2 and "Listening to "..useGuild.activity.name or (useGuild.activity.type == 1 and "Streaming "..useGuild.activity.name or useGuild.activity.name))), inline = true})
        table.insert(data.embed.fields,#data.embed.fields+1, {name = "Status", value = string.sub(useGuild.status,1,1):upper()..string.sub(useGuild.status,2), inline = true})
        message:reply(data)
      end
      return {success = "stfu",msg = ""}
    end
  end
end

return command