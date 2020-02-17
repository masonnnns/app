local module = {}
local pages = {}
-- [guildid..message.id] = {pages = {}, user = author.id, page = 1, message = message}

module.processReaction = function(reaction,user)
  local setup = pages[reaction.message.guild.id..reaction.message.id]
  print('do')
  if setup ~= nil then
    print('ok')
    if user == setup.user then
      print(reaction.emojiName == "⬅️")
      if reaction.emojiName == "⬅️" then
        if setup.page == 1 then return end
        setup.page = setup.page - 1
        setup.message:setEmbed(setup.pages[setup.page])
        setup.message:removeReaction("⬅️",setup.user)
      elseif reaction.emojiName == "➡️" then
        print('yeehaw')
        if setup.page + 1 > #setup.pages then return end
        print()
        setup.page = setup.page + 1
        setup.message:setEmbed(setup.pages[setup.page])
        setup.message:removeReaction("➡️",setup.user)
      end
    end
  end
end

module.addDictionary = function(message,pageTable,user)
  print(#pageTable)
  local guild = (message.guild == nil and 'dms' or message.guild.id)
  local msg = message:reply{embed = pageTable[1]}
  msg:addReaction("⬅️")
  msg:addReaction("➡️")
  pages[guild..msg.id] = {pages = pageTable, page = 1, user = user, message = msg}
end

return module