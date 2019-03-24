local discordia = require('discordia')
local bot = discordia.Client()
local config = require('config')
local pp = config.prefix
local token = config.token
local Utopia = require('utopia')
local app = Utopia:new()

bot:on('ready', function()
  bot:setStatus(idle)
	p('Logged in as '.. bot.user.username)
end)

bot:on('messageCreate', function(message)
	if message.content == pp..'ping' then
		message.channel:send('Pong!')
	end
end)

bot:run('Bot '..token)

app:use(function (req, res)
  res:finish('Check server.lua and remove the Utopia part (if you want)')
end)

app:listen(8080)
