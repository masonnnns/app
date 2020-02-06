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
        setup.message:setContent(setup.pages[setup.page])
      elseif reaction.emojiName == "➡️" then
        if setup.page + 1 > #setup.pages then return end
        setup.page = setup.page + 1
        setup.message:setContent{content = "**Page "..setup.page.."/"..#setup.pages.."**",embed = (setup.pages[setup.page])}
      end
    end
  end
end

module.addDictionary = function(message,pageTable,user)
  local guild = (message.guild == nil and 'dms' or message.guild.id)
  print(guild..message.id)
  pages[guild..message.id] = {pages = pageTable, page = 1, user = user, message = message}
end

return module