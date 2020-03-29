command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")
local music = require("/app/music.lua")

local discordia = require('discordia')
local client = discordia.Client()
discordia.extensions()

command.info = {
  Name = "Join",
  Alias = {},
  Usage = "join",
  Category = "Music",
  Description = "Make AA-R0N join the voice channel you're in.",
  PermLvl = 0,
} 

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if data.music.enabled == false then return {success = "stfu"} end
  local channel = message.guild:getMember(message.author.id).voiceChannel
  if channel == nil then return {success = false, msg = "You're not in a voice channel."} end
  local connection = channel:join()
  if connection == nil or connection.channel == nil then return {success = false, msg = "I couldn't join the **"..channel.name.."** channel."} end
  music.addConnection(message.guild.id,connection)
  return {success = true, msg = "Joined **"..channel.name.."**."}
end

return command