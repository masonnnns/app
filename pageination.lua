local module = {}
local pages = {}
-- [guildid..message.id] = {pages = {}, user = author.id, page = 1, message = message}

module.processReaction = function(reaction,user)
  local setup = pages[reaction.message.guild.id..user]
  if setup ~= nil then
    if user == setup.user then
      if reaction.emojiName == "⬅️" then
        if setup.page == 1 then setup.message:removeReaction("⬅️",setup.user) return end
        setup.page = setup.page - 1
        setup.message:setEmbed(setup.pages[setup.page])
        setup.message:removeReaction("⬅️",setup.user)
      elseif reaction.emojiName == "➡️" then
        if setup.page + 1 > #setup.pages then setup.message:removeReaction("➡️",setup.user) return end
        setup.page = setup.page + 1
        if string.sub(setup.pages[setup.page].footer.text,1,1) ~= "P" then setup.pages[setup.page].footer.text = "Page "..setup.page.."/"..#setup.pages.." | "..setup.pages[setup.page].footer.text end
        setup.message:setEmbed(setup.pages[setup.page])
        setup.message:removeReaction("➡️",setup.user)
      end
    end
  end
end

module.addDictionary = function(message,pageTable,user,txt)
  if txt == nil then txt = "" end
  if #pageTable == 1 then
    message:reply{content = txt, embed = pageTable[1]}
  else
    local guild = (message.guild == nil and 'dms' or message.guild.id)
    pageTable[1].footer.text = "Page 1/"..#pageTable.." | "..pageTable[1].footer.text
    local msg = message:reply{content = txt, embed = pageTable[1]}
    msg:addReaction("⬅️")
    msg:addReaction("➡️")
    pages[guild..user] = {pages = pageTable, page = 1, user = user, message = msg}
  end
end

return module