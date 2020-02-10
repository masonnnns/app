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
  Name = "Helps",
  Alias = {},
  Usage = "help <optional command>",
  Category = "Information",
  Description = "View a list of all commands, or view a specific command.",
  PermLvl = 5,
}

command.execute = function(message,args,client)
  data = config.getConfig(message.guild.id)
  if args[2] == nil then
    cmdList = {}
    local dataa = {embed = {
      title = "AA-R0N Commands",
      description = "To use a command say **"..data.prefix.."<command name>**\nTo learn more about a command, say **"..data.prefix.."help <command name>**",
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
      end end
    end
    for a,b in pairs(cmdList) do
      
      table.insert(dataa.embed.fields,#dataa.embed.fields+1, {name = a, value = "`"..table.concat(b,"`, `").."`", inline = false})
    end
  end
  message:reply(dataa)
end

return command