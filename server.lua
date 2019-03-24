local discordia = require('discordia')
local client = discordia.Client()
local config = require('config')
local pp = config.prefix
local token = config.token
local Utopia = require('utopia')
local app = Utopia:new()

client:on('ready', client()
  client:setGame("Lua")
	p('Logged in as '.. client.user.username)
end)

client:on('messageCreateclientfunction(message)
	if message.content == pp..'ping' then
		message.channel:send('Pong!')
	end
end)

client:run('Bot '..tokenclientapp:use(function (req, res)
  res:finish('Check server.lua and remove the Utopia part (if you want)')
end)

app:listen(8080)
