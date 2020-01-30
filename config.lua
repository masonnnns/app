local config = {}
local configModule = {}

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

configModule.AddConfigs = function()
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

return configModule