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
local config = {}
local cache = {} -- ["1"] = {users = {}, textchannels = {}, voicechannels = {}, }

local configuration = require("/app/config.lua")
local configSetup = configuration.setupConfigs('xddd')
for a,b in pairs(configSetup) do config[a] = b end
for a,b in pairs(client.guilds) do config[b.id] = configuration.getConfig(b.id) end 


local function getPermission(message,id)
	if id == nil then id = message.author.id end
	if message.guild:getMember(id) == nil then
		return 0
	elseif id == client.owner.id then
		--print('owner')
		return 5
	elseif id == message.guild.owner.id then
		--print('guild owner')
		return 3
	elseif message.guild:getMember(id):hasPermission("administrator") == true then
		--print('admin')
		return 2
	elseif message.guild:getMember(id):hasPermission("manageGuild") == true then
		--print('admin')
		return 2
	elseif config[message.guild.id].modrole ~= nil and message.guild:getMember(id):hasRole(config[message.guild.id].modrole) == true then
		--print('modrole')
		return 1
	else 
		return 0
 	end
end	

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
  if message.guild == nil then return end
  config[message.guild.id] = configuration.getConfig(message.guild.id)
  local args = sepMsg(message.content)
  if args[1] == nil then return end
  if string.lower(args[1]) == "!!prefix?" then message:reply("The prefix for **"..message.guild.name.."** is **"..config[message.guild.id].prefix.."**") return end
  if args[1] == "<@!"..client.user.id..">" or args[1] == "<@"..client.user.id..">" then
    table.remove(args,1)
    args[1] = config[message.guild.id].prefix..args[1]
  end
  local found
  for file, _type in fs.scandirSync("./commands") do
	  if _type ~= "directory" then
      local cmd = require("./commands/" .. file)
      if string.lower(config[message.guild.id].prefix..cmd.info.Name) == string.lower(args[1]) or args[1] == client.user.mentionString then
        found = cmd
        break
      elseif #cmd.info.Alias >= 1 then
        for _,items in pairs(cmd.info.Alias) do
          if string.lower(config[message.guild.id].prefix..items) == string.lower(args[1]) then
            found = cmd
            break
          end
        end
      end
	  end
  end
  if found == nil or getPermission(message) < 1 and config[message.guild.id].modonly then
    -- automod / log message
  else
    if config[message.guild.id].modonly and getPermission(message) < 1 then return end
    if config[message.guild.id].deletecmd then message:delete() end
    if found.info.PermLvl <= getPermission(message) then
      local execute = found.execute(message,args,client)
      if execute == nil or type(execute) ~= "table" then
        message:reply(":no_entry: An **unknown error** occured.")
      elseif execute.success == false then
        message:reply(":no_entry: "..execute.msg)
      elseif tostring(execute.success):lower() == "stfu" then
        -- stfu literally
      else
        message:reply((execute.emote == nil and ":ok_hand:" or execute.emote).." "..execute.msg)
      end
    else
      local m = message:reply(":no_entry: You **don't have permissions** to use this command!")
      timer.sleep(5000)
      m:delete()
    end
  end
end)

-- AUDIT LOGGING

client:on("memberJoin", function(member)
  config[member.guild.id] = configuration.getConfig(member.guild.id)
  if config[member.guild.id].auditlog ~= "nil" and member.guild:getChannel(config[member.guild.id].auditlog) ~= nil then
    member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "**Member Joined**", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = true, }, { name = "Created At", value = Date.fromSnowflake(member.id):toISO(' ', ''), inline = true, }, }, color = 3066993, }}
  end
  if config[member.guild.id].welcome.enabled and config[member.guild.id].welcome.joinchannel ~= "nil" and config[member.guild.id].welcome.joinmsg ~= "nil" then
    local msg = config[member.guild.id].welcome.joinmsg
    msg = string.gsub(msg, "{user}", member.mentionString)
    msg = string.gsub(msg, "{tag}", member.tag)
    msg = string.gsub(msg, "{username}", member.username)
    msg = string.gsub(msg, "{discrim}", member.discriminator)
    msg = string.gsub(msg, "{server}", member.guild.name)
    msg = string.gsub(msg, "{members}", #member.guild.members)
    if config[member.guild.id].welcome.joinchannel == "dm" then
      member:getPrivateChannel():send(msg)
    elseif member.guild:getChannel(config[member.guild.id].welcome.joinchannel) ~= nil then
      member.guild:getChannel(config[member.guild.id].welcome.joinchannel):send(msg)
    end
  end
  if config[member.guild.id].welcome.enabled and config[member.guild.id].welcome.autorole ~= "nil" then
    if member.guild:getRole(config[member.guild.id].welcome.autorole) ~= nil then
      if member.guild:getRole(config[member.guild.id].welcome.autorole).position < member.guild:getMember(client.user.id).highestRole.position then
        member:addRole(config[member.guild.id].welcome.autorole)
      end
    end
  end
end)

client:on("memberLeave", function(member)
  config[member.guild.id] = configuration.getConfig(member.guild.id)
  if config[member.guild.id].auditlog ~= "nil" and member.guild:getChannel(config[member.guild.id].auditlog) ~= nil then
    local roles = {}
    for _,items in pairs(member.roles) do roles[1+#roles] = items.mentionString end
    member.guild:getChannel(config[member.guild.id].auditlog):send{embed ={ title = "**Member Left**", fields = { { name = "Member", value = member.mentionString.." (`"..member.id.."`)", inline = true, }, { name = "Roles", value = (#roles == 0 and "No Roles!" or table.concat(roles,", ")), inline = true, }, }, color = 15158332, }}
  end
  if config[member.guild.id].welcome.enabled and config[member.guild.id].welcome.leavechannel ~= "nil" and config[member.guild.id].welcome.leavemsg ~= "nil" then
    local msg = config[member.guild.id].welcome.leavemsg
    msg = string.gsub(msg, "{user}", member.mentionString)
    msg = string.gsub(msg, "{tag}", member.tag)
    msg = string.gsub(msg, "{username}", member.username)
    msg = string.gsub(msg, "{discrim}", member.discriminator)
    msg = string.gsub(msg, "{server}", member.guild.name)
    msg = string.gsub(msg, "{members}", #member.guild.members)
    if config[member.guild.id].welcome.leavechannel == "dm" then
      member:getPrivateChannel():send(msg)
    elseif member.guild:getChannel(config[member.guild.id].welcome.leavechannel) ~= nil then
      member.guild:getChannel(config[member.guild.id].welcome.leavechannel):send(msg)
    end
  end
end)

client:run('Bot NDYzODQ1ODQxMDM2MTE1OTc4.XjNGOg.nO_mTiCpbeGqyGnlhz5KGGHYn6I')