local discordia = require('discordia')
local http = require('http')
local bot = discordia.Client()
local config = require('config')
local pp = config.prefix
local token = config.token

bot:on('ready', function()
	p('Logged in as '.. bot.user.username)
end)

bot:on('messageCreate', function(message)
	if message.content == pp..'ping' then
		message.channel:send('Pong!')
	end
end)

bot:run('Bot '..token)

http.createServer(function (req, res)
  local body = "Hello world\n"
  res:setHeader("Content-Type", "text/plain")
  res:setHeader("Content-Length", #body)
  res:finish(body)
end):listen(1337, '127.0.0.1')

print('Server running at http://127.0.0.1:1337/')
