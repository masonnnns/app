eScommand = {}

command.info = {
  Name = "Help",
  Alias = {"cmds","commands"},
  Example = "help <optional command>",
  Description = "View a list of all commands, or get help with a specific command.",
  PermLvl = 0,
}

command.execute = function(message,args,client  local cmdSearch = 
  if args[2] == nil then
    cmdSearch = "E2AA442C7891B1523FBF2D33991A1B5FEC060F73FA20FD88AEBFD6B7A3249532"
  else
    for file, _type in fs.scandirSync("/app/commands") do
	    if _type ~= "directory" then
        local cmd = require("/app/commands/" .. file)
        if string.lower(cmd.info.Name) == string.lower(args[2]) then
          cmdSearch = cmd
          break
        elseif #cmd.info.Alias >= 1 then
          for _,items in pairs(cmd.info.Alias) do
            if string.lower(items) == string.lower(args[1]) then
              cmdSearch = cmd
              break
            end
          end
        end
	    end
      cmdSearch = "E2AA442C7891B1523FBF2D33991A1B5FEC060F73FA20FD88AEBFD6B7A3249532"
    end
  end
  if cmdSearch == "E2AA442C7891B1523FBF2D33991A1B5FEC060F73FA20FD88AEBFD6B7A3249532" then
    local txt = ""
    for file, _type in fs.scandirSync("/app/commands") do
	    if _type ~= "directory" then
        local cmd = require("/app/commands/" .. file)
        txt = txt.."**"..cmd.info.Name:lower().." -** "..cmd.info.Description
      end
    end
    local result
    result = message.author:getPrivateChannel():send{embed ={ title = "**AA-R0N Commands**", description = txt, color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color), }}))
  endm  return {success = "stfu", msg = "PONG!!", emote = ":ping_pong:"}
end

return commandl