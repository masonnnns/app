print('Loading...')

local discordia = require('discordia')
local client = discordia.Client()
local config = require('config')
local pp = config.prefix
local token = process.env["TOKEN"]
local Utopia = require('utopia')
local app = Utopia:new()

client:on('ready', function()
  client:setStatus('dnd')
  client:setGame("stuff as Lua Rocks!")
	p('Logged in as '.. client.user.username)
end)

client:on('messageCreate', function(message)
	if message.content == pp..'pingdev' then
		message.channel:send('Pong! The bot itself was created by Mobile Gaming, who was little to no coding skills though he is interested in understanding Lua and Python')
	end
end)

client:run('Bot '..token)
  app:use(function (req, res)
  res:finish('Check server.lua and remove the Utopia part (if you want)')
end)

app:listen(8080)
