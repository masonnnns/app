module = {}
local prompts = {}
-- [guildid..channelid..userid] = {type = "type", stage = "stage", expire = "NUM"}
local botreplies = {}
botreplies["config"] = {}

botreplies["config"][1] = function(message,data)
  if data == nil then
    message:reply{embed = {
      title = "Prompt",
      description = "Which setting would you like to edit?\n\n**Prefix -** Edits the bot's prefix.",
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = 3066993,
    }}
  else
    local msg = message.content:lower()
    if msg == "prefix" then
      -- start the next prompt
    else
      message:reply{embed = {
        title = "Prompt Error",
        description = "**Invalid response provided!** Aborting prompt.",
        footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
        color = 15158332,
      }}
    end
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

module.isPrompted = function(id)
  if prompts[id] == nil then 
    return false 
  elseif os.time() >= prompts[id].expire then
    return false
  else
    return true
  end
end

module.startPrompt = function(message,type)
  prompts[message.guild.id..message.channel.id..message.author.id] = {type = type, stage = 1, expire = os.time() + 240}
  botreplies[type][1](message)
end

module.newMsg = function(id,message,data)
  if message.content and message.content:lower() == "cancel" then 
    prompts[message.guild.id..message.channel.id..message.author.id] = nil
    reply(message,"Prompt Cancelled", "This prompt has been cancelled.")
  else
    if prompts[message.guild.id..message.channel.id..message.author.id] == nil then return end
    local pdata = prompts[message.guild.id..message.channel.id..message.author.id]
    pdata.expire = os.time() + 240
    if botreplies[pdata.type][pdata.stage] == nil then return end
    botreplies[pdata.type][pdata.stage](message,data)
  end
end

return module