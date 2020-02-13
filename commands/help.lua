command = {}

local fs = require('fs')
local cache = require("/app/server.lua")
local config = require("/app/config.lua")

local function getPermission(message,id)
	if id == nil then id = message.author.id end
	if message.guild:getMember(id) == nil then
		return 0
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
  Alias = {},
  Usage = "help <optional command>",
  Category = "Information",
  Description = "View a list of all commands, or view a specific command.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  data = config.getConfig(message.guild.id)
  if args[2] == nil then
    cmdList = {}
    local dataa = {embed = {
				--author = {name = user.tag, icon_url = user:getAvatarURL()},
        title = "AA-R0N Commands",
        description = "To use a command, say **"..data.prefix.."<command name>**\nTo view more information about a command say **"..data.prefix.."help <command name>**",
        fields = {},
        color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
			}}
    for file, _type in fs.scandirSync("/app/commands") do
	    if _type ~= "directory" then
      local cmd = require("/app/commands/" .. file)
        if cmd.info.PermLvl >= 5 and message.author.id ~= client.owner.id then else
          if cmd.info.Category == nil then cmd.info.Category = "Misc" end
          if cmdList[cmd.info.Category] == nil then cmdList[cmd.info.Category] = {} end
          cmdList[cmd.info.Category][1+#cmdList[cmd.info.Category]] = cmd.info.Name:lower()
          if cmd.info.Category == "Tickets" and data.tickets.enabled == false then cmdList[cmd.info.Category] = nil end
      end end
    end
    for a,b in pairs(cmdList) do
      local xd = "`"..table.concat(b,"`, `").."`"
      table.insert(dataa.embed.fields,#dataa.embed.fields+1, {name = a, value = xd, inline = false})
    end
    local result = message.author:getPrivateChannel():send(dataa)
    if result == nil or result == false then
      return {success = false, msg = "I couldn't **direct message** you."}
    else
      return {success = true, msg = "I sent you a **direct message** with the list of commands."}
    end
    return {success = "stfu"}
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
      local redoCmd = command.execute(message,{data.prefix.."help"},client)
      return redoCmd
    else
      if getPermission(message) < found.info.PermLvl then local reCmd = command.execute(message,{"xd"},client) return {success = reCmd.success, msg = reCmd.msg} end
      local txts = "**Command:** "..config.getConfig(message.guild.id).prefix..string.lower(found.info.Name).."\n**Description:** "..found.info.Description..(#found.info.Alias == 0 and "" or "\n**Alias:** "..config.getConfig(message.guild.id).prefix..table.concat(found.info.Alias,", "..config.getConfig(message.guild.id).prefix)).."\n**Category:** "..found.info.Category.."\n**Usage:** "..config.getConfig(message.guild.id).prefix..found.info.Usage.."\n**Permission Level:** "..(found.info.PermLvl == 0 and "Everyone" or (found.info.PermLvl == 1 and "Server Moderator" or (found.info.PermLvl == 2 and "Server Administrator" or (found.info.PermLvl == 3 and "Server Owner" or "Aaron Only!"))))
      message:reply{embed ={
        title = "**"..found.info.Name.." Command**",
        description = txts,
        color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
        footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
      }}
      return {success = "stfu"}
    end
  end
end

return command