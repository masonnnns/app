local discordia = require('discordia')

local client = discordia.Client {
	logFile = 'mybot.log',
	cacheAllMembers = true,
	autoReconnect = true,
}

local Utopia = require('utopia')
local app = Utopia:new()

app:listen(8080)

local startOS = os.time()

local http = require('coro-http')
client:on("ready", function()
  app:use(function (req, res)
    res:finish("Hi!")
  end)
end)

local config = require("/app/config.lua") --// Get the config you predefined in config.lua (Read the README.md)

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

local cooldown = {}
--userid..guildid = {time = os.time(), strike = num}

client:on("messageCreate",function(message)
  if message.content == nil then return end --// The message recieved was an embed, there's no command here.
  if message.guild == nil then return end --// The message was sent via DM, no need to verify in DMs.
  if message.author.bot or message.guild.id == nil then return end --// The message was by a bot, we won't allow that.
  if string.sub(message.content),1,string.len(config.prefix)) == config.prefix then --// Message contains prefix.
    local args = sepMsg(string.sub(message.content,string.len(data.general.prefix)+1)) --// Remove the prefix, seperate the string
    local command
    for file, _type in require("fs").scandirSync("app/commands") do
      if _type ~= "directory" then
        if string.lower(args[1]) == string.lower(require("/app/commands/"..file).info.Name) then
          command = require("/app/commands/"..file)
          break
        elseif require("/app/commands/"..file).info.Alias >= 1 then
          for _,alias in pairs(require("/app/commands/"..file).info.Alias) do
            if alias ~= "" and string.lower(alias) == string.lower(args[1]) then
              command = require("/app/commands/"..file)
              break
            end
          end
        end
      end  
    end
    local permLvl = 
  end
end)

if (config) then
  if config.token ~= nil then
    if config.token == "" or config.token == "YOUR_TOKEN_HERE" then
      print("Bot failed to start: No token provided.")
    else
      client:run("Bot "..config.token)
    end
  else
    print("Bot failed to start: config.token is nil.")
  end
else
  print("Bot failed to start: Config table is nil.")
end