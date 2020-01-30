local discordia = require('discordia')

local client = discordia.Client {
	logFile = 'mybot.log',
	cacheAllMembers = false,
	autoReconnect = true,
}

local uptimeOS 
local timer = require('timer')
local json = require('json')
local http = require("coro-http")
local fs = require("fs")
local Date = discordia.Date
local statusEnum = {online = 1, idle = 2, dnd = 3, offline = 4}
local statusText = {'Online', 'Idle', 'Do Not Disturb', 'Offline'}
local data = {config = {}, cache = {}}
data.config = require("./config.lua").AddConfigs
print(#data.config)

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
  if message.author.id == client.owner.id and string.lower(message.content) == "!!restart" then os.exit() os.exit() os.exit() return end
  local args = sepMsg(message.content)
--[[for file, _type in fs.scandirSync("./commands") do
	if _type ~= "directory" then
    local cmd = require("./commands/" .. file)
    print(cmd.info.Description,'xd')
	end
end]]
end)

client:run('Bot NDYzODQ1ODQxMDM2MTE1OTc4.XjNGOg.nO_mTiCpbeGqyGnlhz5KGGHYn6I')