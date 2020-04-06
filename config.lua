local json = require('json')
module = {}
local config = {}
local function addConfig(id)
	config[id] = {
		general = {archives = {}, funlock = true, prefix = "?", modlog = "nil", auditlog = "nil", modroles = {}, mods = {}, modonly = false, delcmd = false,  mutedrole = "nil", auditignore = {}},
    moderation = {cases = {}, actions = {}},
    automod = {enabled = false, log = "nil", spam = {enabled = false}, newline = {enabled = false, limit = 10}, spoilers = {enabled = false, limit = 5}, mentions = {enabled = false, limit = 10}, invites = {enabled = false}, words = {enabled = false, terms = {"fuck","ass","cunt","dick","penis","butt","kys","bitch","cock","sex","intercourse",":middle_finger:","discordgg.ga"}}},
    flags = {enabled = false, log = "nil", threshold = 5, autoflag = false},
    starboard = {enabled = false, channel = "nil", threshold = 5, self = false, blacklist = {roles = {}, messages = {}}, messages = {}},
	}
end

module.isLoaded = function()
  if #config == 0 then return false else return true end
end

module.setupConfigs = function()
  --if 1 == 1 then return config end
  print("[DB]: Starting Data Loading Process.")
  if io.open("./data.txt","r"):read() == nil or io.open("./data.txt","r"):read() == "" then return config end
  local decode = json.decode(io.open("./data.txt","r"):read())
  for a,b in pairs(decode) do
    addConfig(a)
	  for c,d in pairs(b) do
	  	if type(config[a][c]) == "table" then
        for e,f in pairs(d) do
          config[a][c][e] = f
        end
      else
        config[a][c] = d
      end
	  end
	  --config[a] = b
	  print("[DB]: Guild "..a.."'s data was successfully loaded.")
  end
  print("[DB]: All guilds have been successfully loaded.")
  return config
end

module.getConfig = function(id)
  if id == "*" then return config end
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

module.delConfig = function(id)
  if config[id] ~= nil then config[id] = nil end
  local configForSaving = {
		guilds = {},
	}
	for a,b in pairs(config) do
		configForSaving.guilds[a] = b
	end
	file = io.open("./data.txt", "w+") 
  file:write(json.encode(configForSaving.guilds))
	file:close()
  return true
end

return module