command = {}

local utils = require("/app/utils.lua")

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
      if cmd.Name:lower() == commandSearch:lower() then found = file break end
      for _,items in pairs(cmd.Alias) do if items:lower() == commandSearch:lower() then found = file break end
    end
  end
  if found == false then
    local embed = {
      title = "Commands List",
      description = "To use a command, say **"..data.general.prefix.."
    }
  end
end

return command