command = {}

command.info = {
  Name = "Help",
  Alias = {"cmds", "commands"},
  Example = "help <optional command>",
  Description = "View a list of all commands, or view a specific command.",
  PermLvl = 5,
}

command.execute = function(message,args,client)
  if args[2] == nil then  
    local txt = ""
    for file, _type in fs.scandirSync("/app/commands") do
	    if _type ~= "directory" then
      local cmd = require("/app/commands/" .. file)
        txt = txt.."\n**"..cmd.info.Name.." -**"..cmd.info.Description
      end
    end
  end
end

return command