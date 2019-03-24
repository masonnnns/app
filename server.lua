local discordia = require('discordia')
local client = discordia.Client()
local config = require('config')
local pp = config.prefix --process.env["TOKEN"]
local token = config.token --process.env[]
local Utopia = require('utopia')
local app = Utopia:new()

client:on('ready', function()
  client:setGame("Lua")
	p('Logged in as '.. client.user.username)
end)

client:on('messageCreate', function(message)
	if message.content == pp..'ping' then
		message.channel:send('Pong!')
	end
end)

client:run('Bot '..token)
  app:use(function (req, res)
  res:finish('Check server.lua and remove the Utopia part (if you want)')
end)

app:listen(8080)
