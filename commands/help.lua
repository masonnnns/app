command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")
local fs = require('fs')


command.info = {
  Name = "Help",
  Alias = {},
  Usage = "help <command>",
  Category = "Information",
  Description = "View a list of commands or get information on a specific commmand.",
  PermLvl = 1,
} 

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  local search = (args[2] == nil and "NO_SEARCH_XD!?" or table.concat(args," ",2))
  local found
  if search ~= "NO_SEARCH_XD!?" then
    for file, _type in fs.scandirSync("/app/commands") do
	    if _type ~= "directory" then
        local cmd = require("/app/commands/"..file)
        if search:lower() == cmd.info.Name:lower() then
          found = file
          break
        elseif #cmd.info.Alias ~= 0 then
          for _,items in pairs(cmd.info.Alias) do
            if items:lower() == search:lower() then
              found = file
              break
            end
          end
        end
      end
    end
  end
  if found == nil then
  else
    local cmdFound = require("/app/commands/"..found)
    local embed = {
      title = data.general.prefix..cmdFound.info.Name.." Command",
      fields = {
          
      },
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
    }
    if cmdFound.info.PermLvl > utils.PermLvl(message,client) then embed.description = "You don't have permissions to run this command." end
    message:reply{embed = embed}
    return {success = "stfu"}
  end
end

return command