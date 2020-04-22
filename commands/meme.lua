command = {}

local config = require("/app/config.lua")
local http = require('coro-http')
local json = require("json")

command.info = {
  Name = "Meme",
  Alias = {},
  Usage = "meme",
  Category = "Fun",
  Description = "Get a random meme.",
  PermLvl = 0,
  Cooldown = 3,
} 

command.execute = function(message,args,client)
  if config.getConfig(message.guild.id).general.funlock and message.channel.nsfw == false then return {success = false, msg = "You must be in a **NSFW Channel** to use this command. You can disable this by running **"..config.getConfig(message.guild.id).general.prefix.."config nolock**"} end
  message.channel:broadcastTyping()
  local result, body = http.request("GET","https://meme-api.herokuapp.com/gimme")
  if result.code ~= 200 then result, body = http.request("GET","https://some-random-api.ml/meme") end
  body = json.decode(body)
  local title = (body.title == nil and body.caption or body.title)
  local image = (body.image == nil and body.url or body.image)
  if result.code ~= 200 then return {success = false, msg = "I'm having trouble fetching a meme. Try again. (HTTP "..result.code..")"} end
  message:reply{embed = {
    title = title,
    image = {url = image},
    footer = {icon_url = message.author:getAvatarURL(), text = "By Reddit • Responding to "..message.author.tag},
    color = (message.member:getColor() == 0 and 3066993 or message.member:getColor().value),
  }}
  return {success = "stfu"}
end

return command