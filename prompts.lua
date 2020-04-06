local function sepMsg(msg)
	local Args = {}
	local Command = msg
	for Match in Command:gmatch("[^%s]+") do
	table.insert(Args, Match)
	end;
	local Data = {
	["MessageData"] = Message;
	["Args"] = Args;
	}
	return Args
end

module = {}
local prompts = {}
-- [guildid..channelid..userid] = {type = "type", stage = "stage", expire = "NUM", substage = "substage", yn = false}
local botreplies = {}
botreplies["config"] = {}
botreplies["config"][1] = {}

botreplies["yn"] = function(message,data,type,stage,substage)
  if message.content:lower() == "yes" then
    local pdata = prompts[message.guild.id..message.channel.id..message.author.id]
    pdata.type = type
    pdata.stage = stage
    pdata.substage = substage
    pdata.yn = false
    botreplies[type][stage][substage](message)
  elseif message.content:lower() == "no" then
    message:reply{embed = {
      title = "Prompt",
      description = "Ended the prompt.",
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = 3066993,
    }}
    prompts[message.guild.id..message.channel.id..message.author.id] = nil
  else
    message:reply{embed = {
      title = "Prompt Error",
      description = "**Invalid response provided!** `Yes` or `No`?\n\nSay `cancel` to cancel this prompt.",
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = 15158332,
    }}
  end
end

botreplies["config"][1]["s"] = function(message,data)
  if data == nil then
    message:reply{embed = {
      title = "Prompt",
      description = "Which setting would you like to edit?\n\n**Prefix -** Edits the bot's prefix.\n\nSay `cancel` to cancel this prompt.",
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = 3066993,
    }}
  else
    local msg = message.content:lower()
    if msg == "prefix" then
      message:reply{embed = {
        title = "Prompt",
        description = "What would you like to set the command prefix to?\n\nSay `cancel` to cancel this prompt.",
        footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
        color = 3066993,
      }}
      prompts[message.guild.id..message.channel.id..message.author.id].substage = "prefix"
    else
      message:reply{embed = {
        title = "Prompt Error",
        description = "**Invalid response provided!** Aborting prompt.",
        footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
        color = 15158332,
      }}
      prompts[message.guild.id..message.channel.id..message.author.id] = nil
    end
  end
end

botreplies["config"][1]["prefix"] = function(message,data)
  local args = sepMsg(message.content)
  args = table.concat(args," ")
  if string.len(args) > 15 then
    message:reply{embed = {
      title = "Prompt Error",
      description = "Your prefix cannot exceed **15 characters**.\n\nSay `cancel` to cancel this prompt or `back` to go to the previous prompt.",
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = 15158332,
    }}
  elseif args:lower() == "back" then
    botreplies["config"][1]["s"](message,nil)
    prompts[message.guild.id..message.channel.id..message.author.id].substage = "s"
  else
    data.general.prefix = args
    message:reply{embed = {
      title = "Prompt",
      description = "Set the command prefix to `"..data.general.prefix.."`\n\nWould you like to continue? `Yes` or `No`?",
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = 3066993,
    }}
    local pdata = prompts[message.guild.id..message.channel.id..message.author.id]
    pdata.type = "config"
    pdata.stage = 1
    pdata.substage = "s"
    --botreplies["yn"](message,data,pdata.type,pdata.stage,pdata.substage)
    prompts[message.guild.id..message.channel.id..message.author.id].yn = true
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
  prompts[message.guild.id..message.channel.id..message.author.id] = {type = type, stage = 1, expire = os.time() + 240, substage = "s"}
  botreplies[type][1]["s"](message)
end

module.newMsg = function(id,message,data)
  if message.content and message.content:lower() == "cancel" then 
    prompts[message.guild.id..message.channel.id..message.author.id] = nil
    reply(message,"Prompt Cancelled", "This prompt has been cancelled.")
  elseif message.content == nil then
    reply(message,"Prompt Error", "**Invalid response provided!** Aborting prompt.",15158332)
    prompts[id] = nil
  else
    if prompts[message.guild.id..message.channel.id..message.author.id] == nil then return end
    local pdata = prompts[message.guild.id..message.channel.id..message.author.id]
    pdata.expire = os.time() + 240
    if botreplies[pdata.type][pdata.stage] == nil then return end
    if pdata.yn == true then
      botreplies["yn"](message,data,pdata.type,pdata.stage,pdata.substage)
    else  
      botreplies[pdata.type][pdata.stage][pdata.substage](message,data)
    end
  end
end

return module