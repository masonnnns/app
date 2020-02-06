local module = {}
local pages = {}
-- [guildid..message.id] = {pages = {}, user = author.id, page = 1}

module.processReaction = function(reaction,user)
  print(reaction.emojiName)
  print(reaction.message.guild.id..reaction.message.id)
  if pages[reaction.message.guild.id..reaction.message.id] ~= nil then
    print('ok!!')
    if user.id == pages[reaction.message.guild.id..reaction.message.id].user then
      print('lets turn it xoxo')
    end
  end
end

module.addDictionary = function(message,pageTable,user)
  local guild = (message.guild == nil and 'dms' or message.guild.id)
  print(guild..message.id)
  pages[guild..message.id] = {pages = pageTable, page = 1, user = user}
end

return module