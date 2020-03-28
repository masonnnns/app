command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")
local http = require("coro-http")
local json = require('json')

local function getNames(tab,name,res,lev)
	res = res or {[tab]="ROOT"}
	local pls = {} lev = lev or 0
	for k,v in pairs(tab) do
		if type(v) == "table" and not res[v] then
			local n = name.."."..tostring(k)
			res[v] = n pls[v] = n
		end
	end
	for k,v in pairs(pls) do
		getNames(k,v,res)
		pls[k] = lev
	end return res,pls
end

local function tableToString(tab,a,b,c,d)
	a,b = a or 0, b or {[tab]=true}
	local name = b[tab]
	local white = ("\t"):rep(a+1)
	if not c then
		c,d = getNames(tab,"ROOT")
	end local res = {"{"}
	for k,v in pairs(tab) do
		local value
		if type(v) == "table" then
			if d[v] == a and not b[v] then
				b[v] = true
				value = tableToString(v,a+1,b,c,d)
			else
				value = c[v]
			end
		elseif type(v) == "string" then
			value = '"'..v:gsub("\n","\\n"):gsub("\t","\\t")..'"'
		else
			value = tostring(v)
		end
		table.insert(res,white..tostring(k).." = "..value)
	end white = white:sub(2)
	table.insert(res,white.."}")
	return table.concat(res,"\n")
end

command.info = {
  Name = "Define",
  Alias = {},
  Usage = "addmod <member>",
  Category = "Private",
  Description = "Give a member moderator permissions.",
  PermLvl = 4,
}

command.execute = function(message,args,client)
  local result, body = http.request("GET","https://od-api.oxforddictionaries.com/api/v2/entries/en-us/"..args[2],"{\"app_id\" = \"050df1ed\"}")
  print('done')
  print(result,body)
  print(tableToString(result))
  print("--")
  print(body)
end

return command