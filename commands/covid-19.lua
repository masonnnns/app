command = {}

local config = require("/app/config.lua")
local utils = require("/app/utils.lua")
local http = require('coro-http')
local json = require("json")

command.info = {
  Name = "COVID-19",
  Alias = {"corona", "coronavirus"},
  Usage = "COVID-19",
  Category = "Information",
  Description = "Get statistics about the COVID-19 pandemic.",
  PermLvl = 0,
  Cooldown = 3,
} 

command.execute = function(message,args,client)
  local result, body = http.request("GET","https://coronavirus-19-api.herokuapp.com/all")
  body = json.decode(body)
  if result.code ~= 200 then return {success = false, msg = "I'm having trouble fetching the latest global COVID-19 statistics. Try again. (HTTP "..result.code..")"} end
  message:reply{embed = {
    title = "COVID-19 Statistics",
    description = "For the most up-to-date information and other information consult the [World Health Organization](https://www.who.int/emergencies/diseases/novel-coronavirus-2019) and your local health organization's website.",
    fields = {
      {name = "Cases", value = utils.addCommas(body.cases), inline = true},
      {name = "Deaths", value = utils.addCommas(body.deaths), inline = true},
      {name = "Recoveries", value = utils.addCommas(body.recovered), inline = true},    
    },
    footer = {icon_url = message.author:getAvatarURL(), text = "By Worldometers • Responding to "..message.author.tag},
    color = (message.member:getColor() == 0 and 3066993 or message.member:getColor().value),
  }}
  return {success = "stfu"}
end

return command