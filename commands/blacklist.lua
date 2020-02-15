command = {}

local blacklists = require("/app/blacklist.lua")
local cache = require("/app/server.lua")

command.info = {
  Name = "Blacklist",
  Alias = {},
  Usage = "blacklist <id / view> <id>",
  Category = "Private",
  Description = "Blacklist the specified user.",
  PermLvl = 5,
}

command.execute = function(message,args,client)
  if args[2] == nil then
   return {success = false, msg = "Invalid arguments."}
  elseif args[2]:lower() == "view" then
    local blacklist = blacklists.getBlacklist("*")
    local txt = ""
    for a,b in pairs(blacklist) do txt = txt.."\n**"..client:getUser(a).tag.." -** "..b.reason end
    message:reply{embed = {
      title = "Blacklisted Users ["..#blacklist.."]",
      description = txt,
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
      color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
    }}
    return {success = "stfu"}
  end
end

return command