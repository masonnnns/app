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
  local channel = utils.resolveChannel(message,(args[2] == nil and message.channel.id or args[2]))
  if channel == false then channel = message.channel end
  local webhook = channel:createWebhook("TeaCore")
  local headers = {
    {"Content-Type", "application/json"} 
  }
  local embed = {
    embeds = {
      {
        title = "title",
        description = "DOG",
        color = 0xff7662,
        timestamp = require("discordia").Date():toISO('T', 'Z'),
      }
    }
  }
  webhook:setAvatar(message.guild.iconURL)
  local response, body = require("coro-http").request("POST","https://canary.discordapp.com/api/webhooks/"..webhook.id.."/"..webhook.token,headers,require("json").encode(embed))
  return {success = true, msg = webhook.token.." - "..webhook.channelId.." - "..webhook.guildId}
end
return command