command = {}

local config = require("/app/config.lua")
local utils = require("/app/utils.lua")

command.info = {
  Name = "Members",
  Alias = {},
  Usage = "members <optional role/name>",
  Category = "Utility",
  Description = "Get a list of members in a specified role or with a certain name.",
  PermLvl = 1,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if args[2] == nil then
    -- complete member overview
  else
    local role = utils.resolveRole(message,table.concat(args," ",2))
    local page = {}
    if role then
      local num = 1
      for _,items in pairs(role.members) do
        print(items.tag,items.id)
        page[num] = {
          title = "Members of "..role.name.." ["..#role.members.."]",
          description = (page[num] == nil and "**"..items.tag.."** (`"..items.id.."`)" or page[num].description.."\n**"..items.tag.."** (`"..items.id.."`)"),
          footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
          color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color), 
        }
        if string.len(page[num].description) >= 1000 then num = num + 1 end
      end
    end
    require("/app/pages.lua").addDictionary(message,page,message.author.id)
    return {success = "stfu", msg = "xd"}
  end
end

return command