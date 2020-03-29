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
  local result, body = http.request("GET","https://api.thecatapi.com/v1/images/search")
  body = json.decode(body)
  if result.code ~= 200 then return {success = false, msg = "I'm having trouble fetching a picture. Try again. (HTTP "..result.code..")"} end
  message:reply{embed = {
    title = "Meow!",
    description = "Having trouble viewing the image? [Click here]("..body[1].url..")",
    image = {url = body[1].url},
    footer = {icon_url = message.author:getAvatarURL(), text = "By thecatapi • Responding to "..message.author.tag},
    color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
  }}
  return {success = "stfu"}
end

return command