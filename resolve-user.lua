module = {}

module.resolveUser = function(message,user)
  if #message.mentionedUsers >= 1 then
    if user == "<@"..message.mentionedUsers[1][1]..">" then
      return message.guild:getMember(message.mentionedUsers[1][1])
    elseif user == "<@!"..message.mentionedUsers[1][1]..">" then
      return message.guild:getMember(message.mentionedUsers[1][1])
    end
  end
  if message.guild:getMember(user) ~= nil then
    return message.guild:getMember(user)
  end
  for _items in pairs(message.guild.members) do
    if string.sub(items.name,1,string.len())
  end
  return false
end

return module