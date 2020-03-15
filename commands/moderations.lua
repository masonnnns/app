command = {}

local config = require("/app/config.lua")
local utils = require("/app/utils.lua")

command.info = {
  Name = "Moderations",
  Alias = {},
  Usage = "moderations",
  Category = "Administration",
  Description = "View all the active moderations in the server.",
  PermLvl = 2,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if #data.moderation.actions == 0 then
    return {success = false, msg = "There are no **active moderations** to display."}
  else
    local txt = ""
    local page = {}
    for _,items in pairs(data.moderation.actions) do
      if tostring(items.duration):lower() == "permanent" then
        --txt = txt.."\n**"..client:getUser(items.id).tag.." `["..items.type:upper().."]` - **"..utils.getTimeString(items.duration - os.time())  
      elseif string.len(txt.."\n**"..client:getUser(items.id).tag.." `["..items.type:upper().."]` - **"..utils.getTimeString(items.duration - os.time())) >= 1500 then
        page[1+#page] = {
          title = "Moderations ["..#data.moderation.actions.."]",
          description = txt,
          footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
          color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
        }
        txt = ""
      else
        txt = txt.."\n**"..client:getUser(items.id).tag.." `["..items.type:upper().."]` - **"..utils.getTimeString(items.duration - os.time()) 
      end
    end
    if #page == 0 then page[1] = {
      title = "Moderations ["..#data.moderation.actions.."]",
      description = txt,
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
    }
    end
    require("/app/pages.lua").addDictionary(message,page,message.author.id)
    return {success = "stfu"}
  end
end

return command

--[[
 message:reply{embed = {
      title = "Moderations ["..#data.moderation.actions.."]",
      description = txt,
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
    }}
]]