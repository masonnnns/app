local module = {}
local pages = {}
-- [guildid..message.id] = {pages = {}, user = author.id}

module.processReaction(message,reaction)
  if pages[message.guild.id..message.id] ~= nil then
    if message.author.id = pages[message.guild.id..message.id].user then
      -- turn that page xoxo
    end
  end
end

return module