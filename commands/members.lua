command = {}

local cache = require("/app/server.lua")
local utils = require("/app/resolve-user.lua")
local page = require("/app/pageination.lua")

command.info = {
  Name = "Members",
  Alias = {},
  Usage = "members <optional role / highest role>",
  Category = "Administration",
  Description = "View a list of all the members in the server with the specified query.",
  PermLvl = 2,
}

command.execute = function(message,args,client)
  if args[2] == nil then
    local users = cache.getCache("users",message.guild.id)
    local pages = {}
    pages[1] = ""
    for a,items in pairs(users) do
      if string.len(pages[#].."\n**"..items.name.."#"..items.tag.." (`"..a.."`)") > 1000 then
        pages
      end
    end
    page.addDictionary(message,pages,message.author.id)
  end
  return {success = "stfu", msg = ""}
end

return command

--[[footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
      image = {url = user:getAvatarURL().."?size=256"},
      color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
]]--