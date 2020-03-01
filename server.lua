local discordia = require('discordia')

local client = discordia.Client {
	logFile = 'mybot.log',
	cacheAllMembers = true,
	autoReconnect = true,
}

local config = require("/app/config.lua")
config.setupConfigs('xddd')

client:on("messageCreate",function(message)
  if message.author.bot or message.guild.id == nil then return false end
  local data = config.getConfig(message.guild.id)
end)

client:run("Bot NDYzODQ1ODQxMDM2MTE1OTc4.Xlvwig.pblOapFexh1F51CIbnqEi3XHWEA")