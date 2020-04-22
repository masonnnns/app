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

local bindings = {
  255 = "467891231087919115",
  170 = "469392300536102922",
  160 = "468847974462783509",
  150 = "468831154787581955",
  140 = "468831165122347038",
  130 = "468831168804945921",
  120 = "468831168804945921",
  110 = "468108245714731028",
  100 = "468833667578331157",
  90 = "468108495833530408",
  80 = "467888166574227486",
  70 = "467887036250980352",
  69 = "678494383682879492",
  60 = "467886605118472202",
  50 = "467886500294426644",
  45 = "685329271786438706",
  40 = "467885360630988810",
  30 = "467887348978417703",
  20 = "469034307294330891",
  10 = "467886277749112832",
  0 = "467886277749112832",
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
  end
  result, body = http.request("GET","https://api.roblox.com/users/"..userID.."/groups")
  if result.code ~= 200 then return {success = false, msg = "The Roblox API is down."} else body = json.decode(body) end
  local groupInfo
  for a,b in pairs(body) do
    if b.Id == 4294989 then
      groupInfo = b
      break
    end
  end
  if message.member.roles:get(bindings[])
  return {success = true, msg = groupInfo.Role}
end

return command