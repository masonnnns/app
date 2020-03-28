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
  PermLvl = 0,
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
    return {success = false, msg = "command still being developed, run the command on specific commands tho"}
  else
    local cmdFound = require("/app/commands/"..found)
    local embed = {
      title = cmdFound.info.Name.." Command",
      fields = {
        {name = "Description", value = cmdFound.info.Description, inline = false},
        {name = "Usage", value = cmdFound.info.Usage, inline = false},
        {name = "Category", value = cmdFound.info.Category, inline = true},
        {name = "Cooldown", value = (cmdFound.info.Cooldown == nil and "2" or cmdFound.info.Cooldown).." Second"..(cmdFound.info.Cooldown == 1 and "" or "s"), inline = true},
        {name = "Permission", value = "Member", inline = true},
      },
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
    }
    if #cmdFound.info.Alias ~= 0 then embed.fields[1+#embed.fields] = {name = "Alias"..(#cmdFound.info.Alias == 1 and "" or "es"), value = table.concat(cmdFound.info.Alias,", "), inline = false} end
    if cmdFound.info.PermLvl > utils.Permlvl(message,client) then embed.description = "You don't have permissions to run this command." end
    if cmdFound.info.PermLvl == 1 then embed.fields[5].value = "Moderator" end
    if cmdFound.info.PermLvl == 2 then embed.fields[5].value = "Administrator" end
    if cmdFound.info.PermLvl == 3 then embed.fields[5].value = "Server Owner" end
    if cmdFound.info.PermLvl >= 4 then embed.fields[5].value = "Bot Developer" end
    message:reply{embed = embed}
    return {success = "stfu"}
  end
end

return command