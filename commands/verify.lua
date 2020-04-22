command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")
local http = require('coro-http')
local json = require("json")

command.info = {
  Name = "verify",
  Alias = {},
  Usage = "verify",
  Category = "Private",
  Description = "Verify your Roblox account with Discord.",
  PermLvl = 0,
} 

command.execute = function(message,args,client)
  if message.guild.id ~= "467880413981966347" then return {success = "stfu"} end
  local result, body = http.request("GET","https://verify.eryn.io/api/user/"..message.author.id)
  body = json.decode(body)
  if body.status == "ok" then
    message.member:setNickname(body.robloxUsername)
    if message.member.roles
    return {success = true, msg = "You've been verified as **"..body.robloxUsername.."**."}
  else
    if body.errorCode ~= nil and body.errorCode == 404 then
      return {success = false, msg = "You're not verified with RoVer! Verify here: <https://verify.eryn.io/>"}
    else
      return {success = false, msg = "Verification Failed!```ERR: "..body.error:upper().."```"}
    end
  end
end

return command