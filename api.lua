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

local module = {}

module.request = function(res, req)
  if res.req.url == "/" or res.req.url == "/favicon.ico" then return "Keepalive." end
  if res.req.headers[6][1] ~= "api-key" then return "403 - Forbidden" end
  if res.req.headers[6][2] ~= "0E73FC8D00EA076D94CDDD71629C63A52359CB45FFCC736701966FA3A032CC71" then return "403 - Forbidden" end
  --res.req.headers[7][1]
  8
  print(res.req.url)
  print(res.req.headers[6][1])
  --for a,b in pairs(res.req.headers) do print(a,b) for c,d in pairs(b) do print(c,d) end end
end

return module