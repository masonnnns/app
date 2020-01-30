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

local function addConfig(id)
	config[id] = {
		prefix = "!!",
    automod = {enabled = false, types = {invites = {false,0}, mentions = {false,3}, spoilers = {false,2}, newline = {false,10}, filter = {false,0}}},
    tags = {enabled = false, tags = {}, delete = false},
    terms = {"fuck","ass","cunt","dick","penis","butt","kys","bitch","cock","sex","intercourse",":middle_finger:","discordgg.ga"},
    modlog = "nil",
		modrole = "nil",
    auditlog = "nil",
		modData = {cases = {}, actions = {}}, -- {type = "mute", reason = "", duration = os.time() / "perm", mod = userID, user = userID}
		deletecmd = true,
		modonly = false,
		mutedRole = "nil",
    auditignore = {},
    --memberCache = {},
    purgeignore = {["551794917584666625"] = 1000}
	}
	
end

print("[DB]: Starting Data Loading Process.")
  local decode = json.decode(io.open("./data.txt","r"):read())
  for a,b in pairs(decode) do
  	addConfig(a)
	  for c,d in pairs(b) do
	  	if config[a][c] ~= nil then
		  	config[a][c] = d
		  else
		  	print("[DB]: Guild "..a.." doesn't have the "..c.." value in it, so it is using defualt settings.")
	  	end
	  end
	  --config[a] = b
    config[a].purgeignore = {}
	  print("[DB]: Guild "..a.."'s data was successfully loaded.")
  end
  print("[DB]: All guilds have been successfully loaded.")

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
  if message.author.id == client.owner.id and string.lower(message.content) == "!!restart" then os.exit() os.exit() os.exit() return end
  local args = sepMsg(message.content)
  local found
  for file, _type in fs.scandirSync("./commands") do
	  if _type ~= "directory" then
      local cmd = require("./commands/" .. file)
      if string.lower(cmd.info.Name) == string.lower(config[message.guild.id].prefix..args[1]) then
        found = cmd
        break
      elseif #cmd.info.Alias >= 1 then
        for _,items in pairs(cmd.info.Alias) do
          if string.lower(items) == string.lower(config[message.guild.id].prefix..args[1]) then
            found = cmd
            break
          end
        end
      end
	  end
  end
  if found == nil then
    -- automod / log message
  else
    local execute = found.execute(message,config[message.guild.id])
    if execute == nil or type(execute) ~= "table" then
      message:reply(":no_entry: An **unknown error** occured.")
    elseif execute.success == false then
      message:reply(":no_entry: "..execute.msg)
    else
      message:reply((execute.emote == nil and ":ok_hand:" or execute.emote).." "..execute.msg)
    end
  end
end)

client:run('Bot NDYzODQ1ODQxMDM2MTE1OTc4.XjNGOg.nO_mTiCpbeGqyGnlhz5KGGHYn6I')