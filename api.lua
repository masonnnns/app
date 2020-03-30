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

local function parseURL(url)
  local num,paths,tnum = 0, {}, 0
  repeat
    num = num + 1
    local str = string.sub(url,num,num)
    if str ~= "/" then
      if paths[tnum] == nil then paths[tnum] = str else paths[tnum] = paths[tnum]..str end
    else
      tnum = tnum + 1
    end
  until num >= string.len(url)
  return paths
end

local config = require("/app/config.lua")
local json = require('json')

local module = {}

module.request = function(res, req, client)
  if res.req.url == "/" or res.req.url == "/favicon.ico" then return "403 - Forbidden" end
  if string.sub(res.req.url,1,9) == "/archives" then
    local path = parseURL(res.req.url)
    local data = require("/app/config.lua").getConfig("*")
    if data[path[2]] == nil then return "403 - Bad Request" end
    if data[path[2]].general.archives[path[3]] == nil then return "404 - Not Found" end
    return "=====\n\nArchive of "..data[path[2]].general.archives[path[3]].num.." deleted messages in "..data[path[2]].general.archives[path[3]].channelName.." ("..data[path[2]].general.archives[path[3]].channelId..")\nOccured on "..data[path[2]].general.archives[path[3]].date.."\n\n=====\n\n"..data[path[2]].general.archives[path[3]].messages
  end
  if res.req.headers[6][1] ~= "api-key" then return "403 - Forbidden" end
  if res.req.headers[6][2] ~= "0E73FC8D00EA076D94CDDD71629C63A52359CB45FFCC736701966FA3A032CC71" then return "403 - Forbidden" end
  --res.req.headers[7][1]
  if res.req.url == "/api/getConfig" then
    if res.req.headers[7][1] ~= "guild" then return "400 - Bad Request" end
    local data = require("/app/config.lua").getConfig("*")
    if data[res.req.headers[7][2]] == nil then return "404 - Not Found" end
    return json.encode(data[res.req.headers[7][2]])
  end
  return "404 - Not Found"
end

return module