command = {}

local config = require("/app/config.lua")
local utils = require("/app/resolve-user.lua")

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
    else
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
    end
  end
end

return command