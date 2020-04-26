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
  if conifg == nil then return end --// The config table returned nil?
  if message.content == nil then return end --// The message recieved was an embed, there's no command here.
  if message.guild == nil then return end --// The message was sent via DM, no need to verify in DMs.
  if message.author.bot or message.guild.id == nil then --// The message was by a bot, we won't allow that.
  print(config.verifiedrole)
end)

if (config) and config.token ~= nil and client.token ~= "" and client.token ~= "YOUR_TOKEN_HERE" --[[Don't edit that.]] then
  client:run("Bot "..config.token)
else
    print("")
end