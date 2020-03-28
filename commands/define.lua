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

local function capsFirst(string)
  return string.sub(string,1,1):upper()..string.sub(string,2)
end

command.execute = function(message,args,client)
  local headers = {
    {"app_id", "050df1ed"},
    {"app_key", "dca7fd868c5eba269c58d493e4539a55"}
  }
  local result, body = http.request("GET","https://od-api.oxforddictionaries.com/api/v2/entries/en-us/"..args[2],headers)
  if result.code ~= 200 then return {success = false, msg = "I had trouble defining that word. Try again. (HTTP "..result.code..")"} end
  body = json.decode(body)
  local embed = {
    title = "Definition of "..capsFirst(args[2]),
    description = capsFirst(body.results[1].lexicalEntries[1].entries[1].senses[1].definitions[1])..".",
    fields = {
      {name = "Synonyms of "..capsFirst(args[2]), value = "None!", inline = false},   
    },
    footer = {icon_url = message.author:getAvatarURL(), text = "By Oxford Dictionary • Responding to "..message.author.tag},
    color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
  }
  local num = 0
  if #body.results[1].lexicalEntries[1].entries[1].senses[1].synonyms ~= 0 then embed.fields[1].value = "" end
  for _,items in pairs(body.results[1].lexicalEntries[1].entries[1].senses[1].synonyms) do num = num+1 if num - 1 == 5 then break end embed.fields[1].value = embed.fields[1].value..", "..capsFirst(items.text) end
  message:reply{embed = embed}
  return {success = 'stfu'}
end

return command