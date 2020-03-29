command = {}

local config = require("/app/config.lua")
local http = require('coro-http')
local json = require("json")

command.info = {
  Name = "Dog",
  Alias = {"woof"},
  Usage = "dog",
  Category = "Fun",
  Description = "Get a random picture of a dog.",
  PermLvl = 0,
} 

command.execute = function(message,args,client)
  if config.getConfig(message.guild.id).general.funlock and message.channel.nsfw == false then return {success = false, msg = "You must be in a **NSFW Channel** to use this command. You can disable this by running **"..config.getConfig(message.guild.id).general.prefix.."config nolock**"} end
  local result, body = http.request("GET","https://dog.ceo/api/breeds/image/random")
  body = json.decode(body)
  if result.code ~= 200 or body.status ~= "success" then return {success = false, msg = "I'm having trouble fetching a picture. Try again. (HTTP "..result.code..")"} end
  message:reply{embed = {
    title = "Woof!",
    description = "Having trouble viewing the image? [Click here]("..body.message..")",
    image = {url = body.message},
    footer = {icon_url = message.author:getAvatarURL(), text = "By dog.ceo • Responding to "..message.author.tag},
    color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
  }}
  return {success = "stfu"}
end

return command