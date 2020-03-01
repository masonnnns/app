module = {}

module.Permlvl = function(message,client,id)
  if id == nil then id = message.author.id end
  local data = require("/app/config.lua").getConfig(message.guild.id)
  local found
  for items,_ in pairs(message.guild.members) do if items == id then found = true break end end
  if found == nil then return 0 end
  if id == message.guild.ownerId then
		return 3
	elseif message.guild:getMember(id):hasPermission("administrator") == true then
		return 2
	elseif message.guild:getMember(id):hasPermission("manageGuild") == true then
		return 2
  elseif #data.general.modroles >= 1 then
    for _,items in pairs(data.general.modroles) do
      if message.guild:getMember(id):hasRole(items) then return 1 end
    end
  else
    return 5
  end
end

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

module.resolveCategory = function(message,user)
  if tonumber(user) ~= nil and message.guild:getChannel(user) ~= nil then
    return message.guild:getChannel(user)
  end
  for _,items in pairs(message.guild.categories) do
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

return module