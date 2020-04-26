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

local function messageCreate(message)
  print('xd')
  if conifg == nil then return end --// The config table returned nil?
  print('1')
  if message.content == nil then return end --// The message recieved was an embed, there's no command here.
  print('2')
  if message.guild == nil then return end --// The message was sent via DM, no need to verify in DMs.
  print('3')
  if message.author.bot or message.guild.id == nil then return end --// The message was by a bot, we won't allow that.
  print(config.prefix)
end

if (config) then
  if config.token ~= nil then
    if config.token == "" or config.token == "YOUR_TOKEN_HERE" then
      print("Bot failed to start: No token provided.")
    else
      client:run("Bot "..config.token)
      client:on("messageCreate",function(message) messageCreate(message) end)
    end
  else
    print("Bot failed to start: config.token is nil.")
  end
else
  print("Bot failed to start: Config table is nil.")
end