command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")

command.info = {
  Name = "Whois",
  Alias = {"w","userinfo","lookup"},
}

command.execute = function(message,args,client)
  if utils.getPerm(message) < 1 then return {success = (config.permReply and false or "no"), msg = "You don't have permissions to use this command."} end
  local member
  if args[2] == nil then member = message.member else member = utils.resolveUser(message,table.concat(args," ",2)) end
  if member == nil then return {success = false, msg = "I couldn't find the member you mentioned."} end
  local res, body = require("coro-http").request("GET","https://verify.eryn.io/api/user/"..member.id)
  if res.code == 404 then return {success = false, msg = (member.id == message.author.id and "You're not verified with RoVer. Verify here: <https://verify.eryn.io" or "**"..member.tag.."** isn't verified with RoVer.")} end
  if res.code ~= 200 then return {success = false, msg = "There was a problem checking the verification registry. Try again."} end
  local embed = {
    title = require("json").decode(body).robloxUsername,
    url = "https://www.roblox.com/users/"..require("json").decode(body).robloxId.."/profile",
  }
  res, body = require("coro-http").request("GET","https://users.roblox.com/v1/users/"..require("json").decode(body).robloxId)
  if res.code ~= 200 then return {success = false, msg = "There was a problem with the Roblox API. Try again."} end
  body = require('json').decode(body)
  embed.description = string.sub(body.description,1,1500)..(string.len(body.description) > 1500 and "..." or "")
  embed.thumbnail = {url = "https://assetgame.roblox.com/Thumbs/Avatar.ashx?username="..embed.title}
  message:reply{embed = embed}
  return {success = "stfu"}
end

return command