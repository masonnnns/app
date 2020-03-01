local discordia = require('discordia')

local client = discordia.Client {
	logFile = 'mybot.log',
	cacheAllMembers = true,
	autoReconnect = true,
}

local config = require("/app/config.lua")
config.setupConfigs('xddd')

local function sepMsg(msg)
	local Args = {}
	local Command = msg
	for Match in Command:gmatch("[^%s]+") do
	table.insert(Args, Match)
	end;
	local Data = {
	["MessageData"] = Message;
	["Args"] = Args;
	}
	return Args
end

client:on("messageCreate",function(message)
  if message.author.id ~= client.owner.id then return end 
  if message.author.bot or message.guild.id == nil then return false end
  local data = config.getConfig(message.guild.id)
  if string.sub(message.content,1,string.len(data.general.prefix)) == data.general.prefix then
    local args = sepMsg(string.sub(message.content,string.len(data.general.prefix)+1))
    local found
    for cmds, _type in require("fs").scandirSync("./commands") do
      if _type ~= "directory" then
        local command = require("./commands/"..file)
        if string.lower(args[1]) == string.lower(file) then
          found = cmd break
        elseif #command.info.Alias >= 1 then
          for _,items in pairs(command.info.Alias) do
            if string.lower(items) == string.lower(args[1]) then
              found = cmd break
            end
          end
        end
      end
    end
    if found ~= nil then
      
    end
  end
end)

client:run("Bot NDYzODQ1ODQxMDM2MTE1OTc4.Xlvwig.pblOapFexh1F51CIbnqEi3XHWEA")