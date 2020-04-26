local discordia = require('discordia')

local client = discordia.Client {
	logFile = 'mybot.log',
	cacheAllMembers = true,
	autoReconnect = true,
  largeThreshold = 500,
}

local config = require("/app/config.lua")
config.setupConfigs("xd")
local Utopia = require('utopia')
local app = Utopia:new()

local statistics = {messages = 0, cmds = 0, logged = 0}

--[[app:use(function (req, res)
  local api = require("/app/api.lua").request(res, req, client)
  res:finish(api)
end)--]]

app:listen(8080)

local startOS = os.time()

local http = require('coro-http')
client:on("ready", function()
  app:use(function (req, res)
    local api = require("/app/api.lua").request(res, req, client)
    res:finish(api)
  end)
  while true do
    if startOS - os.time() >= 39600 then os.exit() os.exit() os.exit() return end
    http.request("GET","https://aa-r0nbot.glitch.me/")
    http.request("GET","https://verify-bot-aaron.glitch.me/")
    http.request("GET","https://interroutes.glitch.me/")
    require("timer").sleep(60000)
  end
end)

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
  statistics.messages = statistics.messages + 1
  if message.content == nil then return end
  if message.guild == nil then return end
  if message.author.bot or message.guild.id == nil then return false end
  if string.sub(message.content,1,string.len(data.general.prefix)) == data.general.prefix and require("/app/blacklist.lua").getBlacklist("users_"..message.author.id) == false then
    local args = sepMsg(string.sub(message.content,string.len(data.general.prefix)+1))
    if args[1] == nil then return end
    local found
    for file, _type in require("fs").scandirSync("./commands") do
      if _type ~= "directory" then
        local command = require("./commands/"..file)
        if string.lower(args[1]) == string.lower(command.info.Name) then
          found = file break
        elseif #command.info.Alias >= 1 then
          for _,items in pairs(command.info.Alias) do
            if string.lower(items) == string.lower(args[1]) then
              found = file break
            end
          end
        end
      end
    end
    local command
    if found ~= nil then command = require("/app/commands/"..found) end
    local permLvl = require("/app/utils.lua").Permlvl(message,client)
    if found ~= nil and command.info.Category == "Private" and message.author.id == client.owner.id then permLvl = 6 end
    if found == nil or permLvl == 0 and data.general.modonly == true or permLvl < command.info.PermLvl then
      if data.automod.enabled and require("/app/utils.lua").Permlvl(message,client) == 0 then require("/app/automod.lua")(message,data,client) end
      if found ~= nil and permLvl >= 1 and command.info.Category ~= "Private" then 
        local m = message:reply("<:aforbidden:678187354242023434> You **don't have permissions** to use this command!")
        require("timer").sleep(5000)
        m:delete()
      end
    else
      if cooldown[message.author.id..message.guild.id] ~= nil and cooldown[message.author.id..message.guild.id].time > os.time() then
        cooldown[message.author.id..message.guild.id].strike = cooldown[message.author.id..message.guild.id].strike + 1
        if cooldown[message.author.id..message.guild.id].strike >= 3 then
          print("[CMD COOLDOWN]: "..message.author.tag.." ("..message.author.id..") has been put on cooldown in "..message.guild.name.." ("..message.guild.id.."). [STRIKES: "..cooldown[message.author.id..message.guild.id].strike.."]")
          if cooldown[message.author.id..message.guild.id].strike == 3 then
            local reply = message:reply("⚠️ **Slow down!** Try running another command in "..cooldown[message.author.id..message.guild.id].time-os.time().." seconds.")
            require("timer").sleep(5000)
            reply:delete()
          end
          return
        end
      else
          cooldown[message.author.id..message.guild.id] = {time = 0, strike = 0}
      end
      if message and data.general.delcmd then message:delete() end
      local execute
      cooldown[message.author.id..message.guild.id].time = os.time() + (command.info.Cooldown == nil and 2 or command.info.Cooldown)
      local cmdSuccess, cmdMsg = pcall(function() execute = command.execute(message,args,client) end)
      print("[CMD]: "..message.author.tag.." ("..message.author.id..") has ran the "..command.info.Name.." command in "..message.guild.name.." ("..message.guild.id..").\nMSG: "..message.content)
      statistics.cmds = statistics.cmds + 1
      if not (cmdSuccess) then
        message:reply(":rotating_light: **An error occured!**```lua\n"..cmdMsg.."\n```")
      elseif execute == nil or type(execute) ~= "table" then
        message:reply("<:atickno:678186665616998400>  An **unknown error** occured.")
      elseif execute.success == false then
        message:reply("<:atickno:678186665616998400>  "..execute.msg)
      elseif tostring(execute.success):lower() == "stfu" then
        -- stfu literally
      else
        message:reply((execute.emote == nil and "<:atickyes:678186418937397249> " or execute.emote).." "..execute.msg)
      end
    end
  end
end)

