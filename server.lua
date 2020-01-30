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

for file, _type in fs.scandirSync("./commands") do
	if _type ~= "directory" then
		print(file,type(file))
    local cmd = require("./commands/" .. file)
	end
end

client:on("messageCreate",function(message)
  if message.author.id == client.owner.id and string.lower(message.content) == "!!restart" then os.exit() os.exit() os.exit() end
end)

client:run('Bot NDYzODQ1ODQxMDM2MTE1OTc4.XjNGOg.nO_mTiCpbeGqyGnlhz5KGGHYn6I')