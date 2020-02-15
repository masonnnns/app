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
    if args[3] == nil or tonumber(args[3]) == nil then
      local blacklist = blacklists.getBlacklist("*")
      local txt, num = "",0
      for a,b in pairs(blacklist) do num = num + 1 txt = txt.."\n**"..client:getUser(a).tag.." (`"..a.."`) -** "..b.reason end
      message:reply{embed = {
        title = "Blacklisted Users ["..num.."]",
        description = txt,
        footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
        color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
      }}
    else
      if client:getUser(args[3]) == nil then return {success = false, msg = "Invalid ID."} end
      local userBlacklist = blacklists.getBlacklist(args[3])
      if userBlacklist == true then
        return {success = true, msg = "**"..client:getUser(args[3]).tag.."** isn't blacklisted!"}
      else
        message:reply{embed = {
          title = "User Blacklist",
          description = "**"..client:getUser(args[3]).tag.." (`"..args[3].."`)** is blacklisted.",
          fields = {
            {name = "Reason", value = userBlacklist.reason, inline = false}
          },
          footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
          color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
        }}
      end
    end
    return {success = "stfu"}
  else
    if client:getUser(args[2]) == nil then return {success = false, msg = "Invalid ID."} end
    local userBlacklist = blacklists.getBlacklist(args[2])
    if userBlacklist == true then
      blacklists.blacklist(args[2],(args[3] == nil and "No Reason Provided" or table.concat(args, " ",3)))
      return {success = true, msg = "Blacklisted **"..client:getUser(args[2]).name.."**."}
    else
      blacklists.unblacklist(args[2],(args[3] == nil and "No Reason Provided" or table.concat(args, " ",3)))
      return {success = true, msg = "Unblacklisted **"..client:getUser(args[2]).name.."**."}
    end
  end
end

return command