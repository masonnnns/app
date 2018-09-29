local discordia = require('discordia')
local bot = discord.Client()
local config = require('config')
local pp = config.prefix
local token = config.token

bot:on('ready', function()
  p('Logged in as '.. bot.user.username)
end)

bot:on('messageCreate', function()
  if message.content == pp..'hello' then
    message.channel:send('world!')    
  end
end)

bot:run('Bot '..token)
