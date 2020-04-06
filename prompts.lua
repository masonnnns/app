module = {}
local prompts = {}
-- [guildid..channelid..userid] = {type = "type", stage = "stage"}
local botreplies = {}

botreplies["config"][1] = function(message,data)
  if data == nil then
    -- prompt msg
  else
    -- code for prompt reply
  end
end

local function reply(message,title,description,color)
  message:reply{embed = {
    title = title,
    description = description,
    footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
    color = (color == nil and 3066993 or color)
  }}
  end
end

module.isPrompted = function(id)
  if prompts[id] == nil then return false else return true end
end

module.newMsg = function(id,message,data)
  if message.content and message.content:lower() == "cancel" then 
    prompts[message.guild.id..message.channel.id..message.author.id] = nil
    reply(message,"Prompt Cancelled", "This prompt has been cancelled.")
  end
end

return module