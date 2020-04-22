command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")
local http = require('coro-http')
local json = require("json")

command.info = {
  Name = "Verify",
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
    local name = body.robloxUsername
    local newNameR, newNameBody = http.request("GET","https://api.roblox.com/users/"..body.robloxId)
    if newNameR.code == 200 then name = json.decode(newNameBody).Username end
    message.member:setNickname(name)
    if message.member.roles:get("515647391676891138") then message.member:addRole("515647391676891138") end
    return {success = true, msg = "You've been verified as **"..name.."**."}
  else
    if body.errorCode ~= nil and body.errorCode == 404 then
      return {success = false, msg = "You're not verified with RoVer! Verify here: <https://verify.eryn.io/>"}
    else
      return {success = false, msg = "Verification Failed!```ERR: "..body.error:upper().."```"}
    end
  end
end

return command