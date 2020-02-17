local json = require('json')
module = {}
local config = {}
local function addConfig(id)
	config[id] = {
		prefix = "?",
    raidmode = false,
    automod = {enabled = false, log = "nil", types = {invites = {false,0}, spam = {false,0}, mentions = {false,3}, spoilers = {false,2}, newline = {false,10}, filter = {false,0}}},
    tags = {enabled = false, tags = {}, delete = false},
    welcome = {enabled = false, joinmsg = "nil", joinchannel = "nil", leavechannel = "nil", leavemsg = "nil", joinchannel = "nil", autorole = "nil"},
    tickets = {enabled = false, category = "nil", channels = {}, ticket = 0, max = 1},
    economy = {enabled = false, users = {}}
    terms = {"fuck","ass","cunt","dick","penis","butt","kys","bitch","cock","sex","intercourse",":middle_finger:","discordgg.ga"},
    modlog = "nil",
		modrole = "nil",
    auditlog = "nil",
		modData = {cases = {}, actions = {}}, -- {type = "mute", reason = "", duration = os.time() / "perm", mod = userID, user = userID}
		deletecmd = false,
		modonly = false,
		mutedrole = "nil",
    auditignore = {},
    --memberCache = {},
    purgeignore = {["551794917584666625"] = 1000}
	}
end


module.setupConfigs = function()
  --if 1 == 1 then return end
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
  return config
end

module.getConfig = function(id)
  if config[id] == nil then addConfig(id) end
  local configForSaving = {
		guilds = {},
	}
	for a,b in pairs(config) do
		configForSaving.guilds[a] = b
	end
	file = io.open("./data.txt", "w+") 
  file:write(json.encode(configForSaving.guilds))
	file:close()
  return config[id]
end

module.updateConfig = function(id,newTable)
  config[id] = newTable
  local configForSaving = {
		guilds = {},
	}
	for a,b in pairs(config) do
		configForSaving.guilds[a] = b
	end
	file = io.open("./data.txt", "w+") 
  file:write(json.encode(configForSaving.guilds))
	file:close()
end

module.resetConfig = function(id)
  addConfig(id)
  return true
end

return module