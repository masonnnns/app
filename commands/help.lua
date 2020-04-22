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
  if found ~= nil and require("/app/commands/"..found).info.PermLvl >= 4 and message.author.id ~= client.owner.id then found = nil end
  if found == nil then
    local embed = {
      title = "Commands List",
      description = "Say **"..data.general.prefix.."<command name>** to use a command.\nSay **"..data.general.prefix.."help <command name>** to view information about a command.\n**[Support Server](https://discordapp.com/invite/PjKaAXx) - [Bot Invite](https://discordapp.com/oauth2/authorize?client_id=414030463792054282&scope=bot&permissions=502787319)**",
      fields = {},
      footer = {icon_url = message.author:getAvatarURL(), text = "From "..message.guild.name},
      color = (message.member:getColor() == 0 and 3066993 or message.member:getColor().value),
    }
    for file, _type in fs.scandirSync("/app/commands") do
	    if _type ~= "directory" then
        local cmdInfo = require("/app/commands/"..file)
        local matching
        if cmdInfo.info.Category == nil then cmdInfo.info.Category = "Misc" end
        for _,items in pairs(embed.fields) do if items.name == cmdInfo.info.Category then matching = _ break end end
        if matching ~= nil then
          embed.fields[matching].value = embed.fields[matching].value..", `"..cmdInfo.info.Name:lower().."`"
        else
          embed.fields[1+#embed.fields] = {name = cmdInfo.info.Category, value = "`"..cmdInfo.info.Name:lower().."`", inline = false}
        end
      end
    end
    if message.author.id ~= client.owner.id then for _,items in pairs(embed.fields) do if items.name == "Private" then table.remove(embed.fields,_) end end end
    local result = message.author:getPrivateChannel():send{embed = embed}
    if result == nil or result == false then
      return {success = false, msg = "I couldn't **direct message** you."}
    else
      return {success = true, msg = "I sent you a **direct message** with the list of commands."}
    end
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
      color = (message.member:getColor() == 0 and 3066993 or message.member:getColor().value),
    }
    if #cmdFound.info.Alias ~= 0 then embed.fields[1+#embed.fields] = {name = "Alias"..(#cmdFound.info.Alias == 1 and "" or "es"), value = table.concat(cmdFound.info.Alias,", "), inline = false} end
    if cmdFound.info.PermLvl > utils.Permlvl(message,client) and cmdFound.info.PermLvl <= 3 then embed.description = "You don't have permissions to run this command." end
    if cmdFound.info.PermLvl == 1 then embed.fields[5].value = "Moderator" end
    if cmdFound.info.PermLvl == 2 then embed.fields[5].value = "Administrator" end
    if cmdFound.info.PermLvl == 3 then embed.fields[5].value = "Server Owner" end
    if cmdFound.info.PermLvl >= 4 then embed.fields[5].value = "Bot Developer" end
    message:reply{embed = embed}
    return {success = "stfu"}
  end
end

return command