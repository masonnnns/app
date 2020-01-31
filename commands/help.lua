command = {}

local fs = require('fs')
local config = require("/app/config.lua")

command.info = {
  Name = "Help",
  Alias = {"cmds", "commands"},
  Example = "help <optional command>",
  Description = "View a list of all commands, or view a specific command.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  if args[2] == nil then
   -- local config = config.getConfig
    local txt = "To view more information about a command, say "..config.getConfig(message.guild.id).prefix.."help <command name>\n"
    for file, _type in fs.scandirSync("/app/commands") do
	    if _type ~= "directory" then
      local cmd = require("/app/commands/" .. file)
        if cmd.info.PermLvl >= 5 and message.author.id ~= client.owner.id then else
        txt = txt.."\n**"..cmd.info.Name.." -** "..cmd.info.Description
      end end
    end
    local result = message.author:getPrivateChannel():send{embed ={ title = "**AA-R0N Commands**", description = txt, color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color), }}
    if result ~= nil then
      return {success = true, msg = "I sent you a **direct message** with the list of commands."}
    else
      return {success = false, msg = "I **couldn't direct message** you, adjust your privacy settings and try again."}
    end
  end
end

return command