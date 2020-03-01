module = {}

module.Permlvl = function(msg,client,id)
  if id == nil then id = msg.author.id end
  local data = require("/app/config.lua").getConfig(message.guild.id)
  local found
  for items,_ in pairs(msg.guild.members) do if items == id then found = true break end
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
    return 0
  end
end

return module