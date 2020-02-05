command = {}

local config = require("/app/config.lua")
local utils = require("/app/utils.lua")
local cache = require("/app/server.lua")

command.info = {
  Name = "Moderations",
  Alias = {},
  Usage = "moderations",
  Description = "View all the active moderations in the server.",
  PermLvl = 2,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if #data.modData.actions == 0 then
    return {success = false, msg = "There are no **active moderations** to display."}
  else
    local txt = ""
    for _,items in pairs(data.modData.actions) do txt = txt.."\n**"..client:getUser(items.user).tag.." `["..items.type:upper().."]` - **"..(tostring(items.duration):lower() == "permanent" and "Permanent" or utils.getTimeString(items.duration - os.time())) end
    message:reply{embed = {
      title = "Moderations ["..#data.modData.actions.."]",
      description = txt,
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
      color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
    }}
    return {success = "stfu"}
  end
end

return command