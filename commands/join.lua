command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")
local music = require("/app/music.lua")

command.info = {
  Name = "Join",
  Alias = {},
  Usage = "join",
  Category = "Music",
  Description = "Make AA-R0N join the voice channel you're in.",
  PermLvl = 4,
} 

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if data.music.enabled == false then return {success = "stfu"} end
  if message.guild:getMember(message.author.id).voiceChannel == nil then return {success = false, msg = "You're not in a voice channel."} end
  local connection = message.guild:getMember(message.author.id).voiceChannel:join()
  if not connection then return {success = false, msg = "I couldn't join the **"..message.guild:getMember(message.author.id).voiceChannel.name.."** channel."} end
  music.addConnection(message.guild.id,connection)
end

return command