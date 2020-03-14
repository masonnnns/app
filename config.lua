local json = require('json')
module = {}
local config = {}
local function addConfig(id)
	config[id] = {
		general = {prefix = "?", modlog = "nil", auditlog = "nil", modroles = {}, mods = {}, modonly = false, mutedrole = "nil", auditignore = {}},
    moderation = {cases = {}, actions = {}}
	}
end


module.setupConfigs = function()
  --if 1 == 1 then return end
  print("[DB]: Starting Data Loading Process.")
  if io.open("./data.txt","r"):read() == nil or io.open("./data.txt","r"):read() == "" then return config end
  local decode = json.decode(io.open("./data.txt","r"):read())
  for a,b in pairs(decode) do
    addConfig(a)
	  for c,d in pairs(b) do
      print(c)
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

return module