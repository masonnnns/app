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
  if channel == false then return {success = false, msg = "I couldn't find the channel you mentioned."} end
  local webhook = channel:createWebhook("TeaCore",message.guild.iconURL)
  local headers = {
    {"Content-Type", "application/json"} 
  }
  local text = string.sub(message.content,string.len(args[1])+string.len(args[2])+4)
  local embed = {
    embeds = {
      {
        description = text,
        color = 0xfdb14d,
        timestamp = require("discordia").Date():toISO('T', 'Z'),
      }
    }
  }
  webhook:setAvatar(message.guild.iconURL)
  if args[#args]:lower() == "here" or args[#args]:lower() == "everyone" then
    text = string.sub(text,1,string.len(text) - string.len(args[#args]))
    embed.embeds[1].description = text
    embed.content = "@"..args[#args]:lower()
  end
  local response, body = require("coro-http").request("POST","https://canary.discordapp.com/api/webhooks/"..webhook.id.."/"..webhook.token,headers,require("json").encode(embed))
  webhook:delete()
  return {success = true, msg = "Sent the message to **"..channel.name.."**!"}
end
return command