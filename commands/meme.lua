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
  message.channel:broadcastTyping()
  local result, body = http.request("GET","https://meme-api.herokuapp.com/gimme")
  body = json.decode(body)
  if result.code ~= 200 then return {success = false, msg = "I'm having trouble fetching a meme. Try again. (HTTP "..result.code..")"} end
  message:reply{embed = {
    title = body.title,
    image = {url = body.url},
    footer = {icon_url = message.author:getAvatarURL(), text = "By Reddit • Responding to "..message.author.tag},
    color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
  }}
  return {success = "stfu"}
end

return command