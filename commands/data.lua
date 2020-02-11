command = {}

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

local config = require("/app/config.lua")
local cache = require("/app/server.lua")

command.info = {
  Name = "Data",
  Alias = {},
  Usage = "data <optional guild id>",
  Category = "Private",
  Description = "View a server's configuration settings.",
  PermLvl = 5,
}

command.execute = function(message,args,client)
  if args[2] == nil then args[2] = message.guild.id end
  if client:getGuild(args[2]) == nil then return {success = false, msg = "I am **not in that guild**."} end
  local guild = client:getGuild(args[2])
  local data = config.getConfig(args[2])
  message:reply{embed = {
    title = guild.name.." Config",
    description = "```\n"..tableToString(data).."\n```",
    footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
    color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
  }}
  return {success = "stfu"}
end

return command