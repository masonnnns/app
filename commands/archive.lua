command = {}

local utils = require("/app/utils.lua")
local discordia = require("discordia")

command.info = {
  Name = "Archive",
  Alias = {},
  Usage = "archive <# of messages>",
  Category = "Utility",
  Description = "Archive a number of messages in a channel.",
  PermLvl = 2,
}

command.execute = function(message,args,client)
  if args[2] == nil then return {success = false, msg = "You must specify a number of messages."} end
  if tonumber(args[2]) == nil then return {success = false, msg = "You must specify a number of messages."} end
  local messages = {}
  for a,items in pairs(message.channel:getMessages(tonumber(args[2]))) do messages[1+#messages] = items.author.tag.." ("..items.id.."): "..items.content end
  local data = require("/app/config.lua").getConfig(message.guild.id)
  data.general.archives[message.channel.id..os.time()..message.guild.id] = {date = require("/app/utils.lua").parseDateString(discordia.Date.fromSeconds(os.time()):toString(),2), messages = table.concat(messages, "\n"), channelName = message.channel.name, channelId = message.channel.id, num = #messages, guild = message.guild.name, purge = false}
  local link = "https://aa-r0nbot.glitch.me/archives/"..message.guild.id.."/"..message.channel.id..os.time()..message.guild.id
  local embed = {
    title = ""
  }
  message:reply{embed = embed}
  return {success = "stfu"}
end

return command