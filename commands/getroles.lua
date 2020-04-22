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
  [255] = "467891231087919115",
  [170] = "469392300536102922",
  [160] = "468847974462783509",
  [150] = "468831154787581955",
  [140] = "468831165122347038",
  [130] = "468831168804945921",
  [120] = "468831168804945921",
  [110] = "468108245714731028",
  [100] = "468833667578331157",
  [90] = "468108495833530408",
  [80] = "467888166574227486",
  [70] = "467887036250980352",
  [69] = "678494383682879492",
  [60] = "467886605118472202",
  [50] = "467886500294426644",
  [45] = "685329271786438706",
  [40] = "467885360630988810",
  [30] = "467887348978417703",
  [20] = "469034307294330891",
  [10] = "467886277749112832",
  [0] = "467886277749112832",
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
  local added, removed = {}, {}
  if message.member.roles:get(bindings[groupInfo.Rank]) == nil then added[1+#added] = groupInfo.Role message.member:addRole(bindings[groupInfo.Rank]) end
  for a,b in pairs(bindings) do
    if message.member.roles:get(b) ~= nil and a ~= groupInfo.Rank then
      removed[1+#removed] = message.member.roles:get(b).name
      message.member:removeRole(b)
      require("timer").sleep(500)
    end
  end
  if #added + #removed == 0 then return {success = false, msg = "No changes were made."} end
  local embed = {
    title = "Roles Changed",
    fields = {
      {name = "Added ["..#added.."]", value = (#added == 0 and "None!" or table.concat(added,", ")), inline = false},
      {name = "Removed ["..#removed.."]", value = (#removed == 0 and "None!" or table.concat(removed,", ")), inline = false},
    },
    footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
    color = (message.member:getColor() == 0 and 3066993 or message.member:getColor().value),
  }
  message:reply{embed = embed}
  return {success = "stfu"}
end

return command