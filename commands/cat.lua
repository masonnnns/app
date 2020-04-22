command = {}

local config = require("/app/config.lua")
local http = require('coro-http')
local json = require("json")

command.info = {
  Name = "Cat",
  Alias = {"meow"},
  Usage = "cat",
  Category = "Fun",
  Description = "Get a random picture of a cat.",
  PermLvl = 0,
} 

command.execute = function(message,args,client)
  if config.getConfig(message.guild.id).general.funlock and message.channel.nsfw == false then return {success = false, msg = "You must be in a **NSFW Channel** to use this command. You can disable this by running **"..config.getConfig(message.guild.id).general.prefix.."config nolock**"} end
  local result, body = http.request("GET","https://api.thecatapi.com/v1/images/search")
  body = json.decode(body)
  if result.code ~= 200 then return {success = false, msg = "I'm having trouble fetching a picture. Try again. (HTTP "..result.code..")"} end
  message:reply{embed = {
    title = "Meow!",
    description = "Having trouble viewing the image? [Click here]("..body[1].url..")",
    image = {url = body[1].url},
    footer = {icon_url = message.author:getAvatarURL(), text = "By thecatapi • Responding to "..message.author.tag},
    color = (message.member:getColor() == 0 and 3066993 or message.member:getColor().value),
  }}
  return {success = "stfu"}
end

return command