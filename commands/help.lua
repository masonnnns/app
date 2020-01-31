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
  else
    local found
    for file, _type in fs.scandirSync("/app/commands") do
      if _type ~= "directory" then
      local cmd = require("/app/commands/" .. file)
        if string.lower(cmd.info.Name) == string.lower(args[2]) then
          found = cmd
          break
        elseif #cmd.info.Alias >= 1 then
          for _,items in pairs(cmd.info.Alias) do
            if string.lower(items) == string.lower(args[2]) then
              found = cmd
              break
            end
          end
        end
	    end
    end
  if found == nil then
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
  else
    local txt = "**Command:** "
    message:reply{{embed ={ title = "**"..found.info.Name.." Command **", description = txt, color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color), }}
    return {success = "stfu"}
  end
  end
end

return command