local module = {}
local pages = {}
-- [guildid..message.id] = {pages = {}, user = author.id, page = 1}

module.processReaction = function(reaction,user)
  print(reaction.emojiName)
    if pages[reaction.message.guild.id..reaction.message.id] ~= nil then
      if reaction.message.author.id == pages[message.guild.id..message.id].user then
        print('lets turn it xoxo')
      end
    end
end

return module