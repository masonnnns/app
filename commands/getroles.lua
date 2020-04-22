command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")
local http = require('coro-http')
local json = require("json")

command.info = {
  Name = "getroles",
  Alias = {},
  Usage = "getroles",
  Category = "Private",
  Description = "Get the roles that corrospond with your rank.",
  PermLvl = 0,
} 

command.execute = function(message,args,client)
  if message.guild.id ~= "467880413981966347" then return {success = "stfu"} end
  local result, body = http.request("GET","https://verify.eryn.io/api/user/"..message.author.id)
  body = json.decode(body)
  local userID = 0
  if body.status == "ok" then
    userID = body.robloxId
  else
    if body.errorCode ~= nil and body.errorCode == 404 then
      return {success = false, msg = "You're not verified with RoVer! Verify here: <https://verify.eryn.io/>"}
    else
      return {success = false, msg = "Verification Failed!```ERR: "..body.error:upper().."```"}
    end
  elseif userID == 0 then
    return {success = false, msg = "Internal Error."}
  end
  result, body = http.request("GET","https://api.roblox.com/users/"..userID.."/groups")
  if result.code ~= 200 then return {success = false, msg = "The Roblox API is down."} else body = json.decode(body) end
  
end

return command