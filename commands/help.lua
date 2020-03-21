command = {}

local utils = require("/app/utils.lua")
local fs = require('fs')

command.info = {
  Name = "Help",
  Alias = {"cmds"},
  Usage = "help <optional command>",
  Category = "Information",
  Description = "View a list of all commands, or view a specific command.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  local data = require("/app/config.lua").getConfig(message.guild.id)
  local commandSearch = (args[2] == nil and "abcdefghijklmonop" or table.concat(args,2))
  local found = false
  for file, _type in fs.scandirSync("/app/commands") do
	  if _type ~= "directory" then
      local cmd = require("/app/commands/" .. file)
      if cmd.info.Name:lower() == commandSearch:lower() then found = file break end
      for _,items in pairs(cmd.info.Alias) do if items:lower() == commandSearch:lower() then found = file break end
    end
  end
  if found == false then
    local embed = {
      title = "Commands List",
      description = "To use a command, say **"..data.general.prefix.."<command name>**.\nTo view more info about a command say **"..data.general.prefix.."help <command name>**.\n**[Support Server](https://discordapp.com/invite/PjKaAXx) - [Bot Invite](https://discordapp.com/oauth2/authorize?client_id=414030463792054282&scope=bot&permissions=502787319)**",
      fields = {},
      color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
    }
    for file, _type in fs.scandirSync("/app/commands") do
      if _type ~= "directory" then
        local cmd = require("/app/commands/" .. file)
        if cmd.info.PermLvl == 5 and message.author.id ~= client.owner.id then else
          if cmd.info.Category == nil then cmd.info.Category = "Misc" end
          if #embed.fields == 0 then embed.fields[1] = {name = cmd.info.Category, value = "`"..cmd.info.Name.."`", inline = false} end
          for _,items in pairs(embed.fields) do if items.name == cmd.info.Category then items.value = items.value.." , `"..cmd.info.Name.."`" else embed.fields[1+#embed.fields] = {name = cmd.info.Category, value = "`"..cmd.info.Name.."`", inline = false} end end
        end
      end
    end
    message:reply{embed = embed}
  end
  end
end

return command