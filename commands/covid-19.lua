command = {}

local config = require("/app/config.lua")
local http = require('coro-http')
local json = require("json")

command.info = {
  Name = "covid-19",
  Alias = {"corona", "coronavirus"},
  Usage = "covid-19 <optional country>",
  Category = "Information",
  Description = "Get statistics about the COVID-19 pandemic.",
  PermLvl = 0,
  Cooldown = 3,
} 

command.execute = function(message,args,client)
  if args[2] == nil then
    local result, body = http.request("GET","https://coronavirus-19-api.herokuapp.com/all")
    body = json.decode(body)
    if result.code ~= 200 then return {success = false, msg = "I'm having trouble fetching the latest global COVID-19 statistics. Try again. (HTTP "..result.code..")"} end
    message:reply{embed = {
      title = "COVID-19 Statistics",
    }}
  end
  return {success = "stfu"}
end

return command