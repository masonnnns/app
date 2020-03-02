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
    for a,items in pairs(data.moderation.cases) do if items.user == user.id then foundCases[1+#foundCases] = items end
    if #foundCases == 0 then
      return {success = false, msg = "**"..user.tag.."** has no modlogs."}
    else
      
    end
   end
end

return command