command = {}

local config = require("/app/config.lua")

command.info = {
  Name = "Tag",
  Alias = {},
  Usage = "tag <tag name>",
  Category = "Utility",
  Description = "Replies with the specified tag.",
  PermLvl = 1,
}


--//        data.tags.tags[1+#data.tags.tags] = {term = args[4], response = msg}
command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if data.tags.enabled == false then return {success = false, msg = "This command is **disabled**."} end
  if args[2] == nil then return {success = false, msg = "You must provide a **tag name** in argument 2."} end
  local found
  for _,items in pairs(data.tags.tags) do if string.lower(args[2]) == string.lower(items.term) then found = items.response end end
  if found == nil then
    return {success = false, msg = "There is **no tag** with that name."}
  else
    if data.tags.delete and message ~= nil then message:delete() end
    message:reply(found)
    return {success = "stfu", msg = found}
  end
end

return command