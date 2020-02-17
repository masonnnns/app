command = {}

local config = require("/app/config.lua")
local utils = require("/app/resolve-user.lua")
local pages = require("/app/pageination.lua")
local cache = require("/app/server.lua")

command.info = {
  Name = "Modlogs",
  Alias = {"mlogs"},
  Usage = "modlog <user>",
  Category = "Moderation",
  Description = "View all the modlogs of a user.",
  PermLvl = 1,
}

-- message,pageTable,user

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  local page = {}
  if args[2] == nil then return {success = false, msg = "You must provide a **user to view** in argument 2."} end
  local user = utils.resolveUser(message,args[2])
  if user == false and tonumber(args[2]) ~= nil then if client:getUser(args[2]) ~= nil then user = client:getUser(args[2]) else user = false end end
  if user == false then
    return {success = false, msg = "I couldn't find the user you mentioned."}
  else
    local foundCases = {}
    for a,items in pairs(data.modData.cases) do if items.user == user.id then foundCases[1+#foundCases] = {user = items.user, moderator = items.moderator, type = items.type, case = a, reason = items.reason, duration = items.duration} end end
    if #foundCases == 0 then
      return {success = false, msg = "**"..user.username.."** has no modlogs."}
    else
      for _,items in pairs(foundCases) do
        items.type = string.sub(items.type,1,1):upper()..string.sub(items.type,2)
        print(string.sub(items.type,1,4))
        if items.moderator == client.user.id and string.sub(items.type,1,4) ~= "Auto" then items.type = "Auto "..items.type end
        page[1+#page] = {
          title = "Case "..items.case.." - "..items.type,
          fields = {
            {name = "Reason", value = items.reason, inline = false}
          },
          footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
          color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
        }
        --page[#page].fields[1] = {}
        if items.duration then  
          table.insert(page[#page].fields,#page[#page].fields+1, {name = "Duration", value = items.duration, inline = true})
        end
        table.insert(page[#page].fields,#page[#page].fields+1, {name = "Moderator", value = client:getUser(items.moderator).tag.." (`"..items.moderator.."`)", inline = true})
      end
      pages.addDictionary(message,page,message.author.id, "**"..user.tag.."'s modlogs:**")
      return {success = "stfu"}
    end
  end
  return {success = true, msg = "xd"}
end

return command