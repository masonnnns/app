command = {}

local config = require("/app/config.lua")
local http = require('coro-http')
local json = require("json")

command.info = {
  Name = "Meme",
  Alias = {},
  Usage = "meme",
  Category = "Fun",
  Description = "Get a random picture of a dog.",
  PermLvl = 0,
} 

command.execute = function(message,args,client)
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