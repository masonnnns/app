command = {}

local utils = require("/app/utils.lua")
local cache = require("/app/server.lua")

command.info = {
  Name = "Info",
  Alias = {},
  Usage = "Info",
  Category = "Information",
  Description = "Shows information on the bot.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
    local users,guilds = 0,0
    local info = cache.getCache("getstats")
    for _,items in pairs(client.guilds) do guilds = guilds + 1 users = users + #items.members end
    message:reply{embed = {
      title = "AA-R0N",
      description = "View information on AA-R0N here.",
      fields = {
        {name = "Guilds", value = utils.addCommas(guilds), inline = true},
        {name = "Users", value = utils.addCommas(users), inline = true},
        {name = "Messages Seen", value = utils.addCommas(info.messages), inline = true},
        {name = "Commands Ran", value = utils.addCommas(info.commands), inline = true},
        {name = "Shards", value = utils.addCommas(client.shardCount), inline = true},
        {name = "Library", value = "Discordia", inline = false},
      },
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
      color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
    }}
  return {success = "stfu", msg = "PONG!!", emote = ":ping_pong:"}
end

return command