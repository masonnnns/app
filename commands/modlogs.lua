command = {}

local config = require("/app/config.lua")
local utils = require("/app/utils.lua")

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
    for a,items in pairs(data.moderation.cases) do print(items.user,items.id) if items.user == user.id or items.id == user.id then foundCases[a] = items end end
    if #foundCases == 0 then
      return {success = false, msg = "**"..user.tag.."** has no modlogs."}
    else
      for a,items in pairs(foundCases) do
        items.type = string.sub(items.type,1,1):upper()..string.sub(items.type,2)
        if items.moderator == client.user.id and string.sub(items.type,1,4) ~= "Auto" then items.type = "Auto "..items.type end
        page[1+#page] = {
          title = "Case "..a.." - "..items.type,
          fields = {},
          footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
          color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
        }
        local modTag = (message.guild:getMember(items.moderator) ~= nil and message.guild:getMember(items.moderator).tag or client:getUser(items.moderator).tag)
        page[#page].fields[1+#page[#page].fields] = {name = "Moderator", value = modTag.." (`"..items.moderator.."`)", inline = true}
        if items.duration then page[#page].fields[1+#page[#page].fields] = {name = "Duration", value = items.duration, inline = true} end
        page[#page].fields[1+#page[#page].fields] = {name = "Reason", value = items.reason, inline = false}
      end
      require("/app/pages.lua").addDictionary(message,page,message.author.id, "<:aaronwrench:678970116985061417> **"..user.tag.."'s modlog"..(#page == 1 and "" or "s")..":**")
      return {success = "stfu"}
    end
  end
end

return command