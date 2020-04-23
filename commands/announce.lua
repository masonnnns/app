command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")
local http = require('coro-http')
local json = require("json")

command.info = {
  Name = "Announce",
  Alias = {"ann"},
  Usage = "announce <channel> <content> <here/everyone>",
  Category = "Private",
  Description = "Post an announcement to a specified channel.",
  PermLvl = 1,
  Cooldown = 10,
} 

command.execute = function(message,args,client)
  if message.guild.id ~= "467880413981966347" then return {success = "stfu"} end
  local channel = utils.resolveChannel(message,args[2])
  if channel == false then return {success = false, msg = "I couldn't find the channel you mentioned."} end
  local webhook = channel:createWebhook()
end
return command