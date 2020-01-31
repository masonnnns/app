command = {}

local fs = require('fs')
local config = require("/app/config.lua")

local function getPermission(message,id)
	if id == nil then id = message.author.id end
	if message.guild:getMember(id) == nil then
		return 0
	elseif id == "276294288529293312" then
		--print('owner')
		return 5
	elseif id == message.guild.owner.id then
		--print('guild owner')
		return 3
	elseif message.guild:getMember(id):hasPermission("administrator") == true then
		--print('admin')
		return 2
	elseif message.guild:getMember(id):hasPermission("manageGuild") == true then
		--print('admin')
		return 2
	elseif config.getConfig(message.guild.id).modrole ~= nil and message.guild:getMember(id):hasRole(config.getConfig(message.guild.id).modrole) == true then
		--print('modrole')
		return 1
	else 
		return 0
 	end
end	

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
        if getPermission(message) < cmd.info.PermLvl then else
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
    if getPermission(message) < found.info.PermLvl then local reCmd = command.execute(message,{"xd"},client) return {success = reCmd.success, msg = reCmd.msg} end
    local txts = "**Command:** "..config.getConfig(message.guild.id).prefix..string.lower(found.info.Name).."\n**Description:** "..found.info.Description..(#found.info.Alias == 0 and "" or "\n**Alias:** "..config.getConfig(message.guild.id).prefix..table.concat(found.info.Alias,", "..config.getConfig(message.guild.id).prefix)).."\n**Usage:** "..config.getConfig(message.guild.id).prefix..found.info.Example.."\n**Permission Level:** "..(found.info.PermLvl == 0 and "Everyone" or (found.info.PermLvl == 1 and "Server Moderator" or (found.info.PermLvl == 2 and "Server Administrator" or (found.info.PermLvl == 3 and "Server Owner" or "Aaron Only!"))))
    message:reply{embed ={
      title = "**"..found.info.Name.." Command**",
      description = txts,
      color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
      footer = {text = "Responding to "..message.author.name},
    }}
    return {success = "stfu"}
  end
  end
end

return command