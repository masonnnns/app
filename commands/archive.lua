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
  if tonumber(args[2]) <= 1 or tonumber(args[2]) >= 101 then return {success = false, msg = "The amount of messages must be greater than 1 and less than 100."} end
  local embed = {
    title = "Archiving Messages",
    description = "<a:AARONLOADING:552079960022581248> Please wait, the archive will be available shortly.",
    footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
    color = (message.member:getColor() == 0 and 3066993 or message.member:getColor().value),
  }
  local getMessages = message.channel:getMessages(tonumber(args[2])+1)
  local botReply = message:reply{embed = embed}
  local msgs = {}
  for a,items in pairs(getMessages) do if items.id == message.id then else msgs[1+#msgs] = {items.createdAt,items.author.tag.." ("..items.author.id.."): "..items.content} end end
  table.sort(msgs, function(a, b)
    return (a[1] < b[1])
  end)
  local messages = {}
  for a,b in pairs(msgs) do messages[a] = b[2] end
  local data = require("/app/config.lua").getConfig(message.guild.id)
  data.general.archives[message.channel.id..os.time()..message.guild.id] = {date = require("/app/utils.lua").parseDateString(discordia.Date.fromSeconds(os.time()):toString(),2), messages = table.concat(messages, "\n"), channelName = message.channel.name, channelId = message.channel.id, num = #messages, guild = message.guild.name, purge = false}
  local link = "https://aa-r0nbot.glitch.me/archives/"..message.guild.id.."/"..message.channel.id..os.time()..message.guild.id
  embed = {
    title = "Messages Archived",
    description = "[Click Here]("..link..") to view the **"..#messages.."** archived messages.",
    footer = botReply.embed.footer,
    color = botReply.embed.color,
  }
  botReply:setEmbed(embed)
  return {success = "stfu"}
end

return command