module = {}

local config = require("/app/config.lua")

module.resolveUser = function(message,user)
  if #message.mentionedUsers >= 1 then
    if user == "<@"..message.mentionedUsers[1][1]..">" then
      return message.guild:getMember(message.mentionedUsers[1][1])
    elseif user == "<@!"..message.mentionedUsers[1][1]..">" then
      return message.guild:getMember(message.mentionedUsers[1][1])
    end
  end
  if tonumber(user) ~= nil and message.guild:getMember(user) ~= nil then
    return message.guild:getMember(user)
  end
  for _,items in pairs(message.guild.members) do
    if string.sub(items.name,1,string.len(user)):lower() == user:lower() then
      return items
    end
  end
  for _,items in pairs(message.guild.members) do
    if string.sub(items.username,1,string.len(user)):lower() == user:lower() then
      return items
    end
  end
  return false
end

module.resolveChannel = function(message,user)
  if #message.mentionedChannels >= 1 then
    if user == "<#"..message.mentionedChannels[1][1]..">" then
      return message.guild:getChannel(message.mentionedChannels[1][1])
    end
  end
  if tonumber(user) ~= nil and message.guild:getChannel(user) ~= nil then
    return message.guild:getChannel(user)
  end
  for _,items in pairs(message.guild.textChannels) do
    if string.sub(items.name,1,string.len(user)):lower() == user:lower() then
      return items
    end
  end
  return false
end

module.resolveRole = function(message,user)
  if #message.mentionedRoles >= 1 then
    if user == "<@&"..message.mentionedRoles[1][1]..">" then
      return message.guild:getRole(message.mentionedRoles[1][1])
    end
  end
  if tonumber(user) ~= nil and message.guild:getRole(user) ~= nil then
    return message.guild:getRole(user)
  end
  for _,items in pairs(message.guild.roles) do
    if string.sub(items.name,1,string.len(user)):lower() == user:lower() then
      return items
    end
  end
  return false
end

module.getPermission = function(message,client,id)
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
	elseif config.getConfig(message.guild.id).modrole ~= "nil" and message.guild:getMember(id):hasRole(config.getConfig(message.guild.id).modrole) == true then
		--print('modrole')
		return 1
	else 
		return 0
 	end
end	

return module