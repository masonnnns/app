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


local function code(str)
    return string.format('```lua\n%s```', str)
end

local function printLine(...)
    local ret = {}
    for i = 1, select('#', ...) do
        local arg = tostring(select(i, ...))
        table.insert(ret, arg)
    end
    return table.concat(ret, '\t')
end

local sandbox = setmetatable({ }, { __index = _G })

local function exec(arg, msg)

    arg = arg:gsub('```\n?', '') -- strip markdown codeblocks

    local lines = {}

    sandbox.message = msg

    sandbox.print = function(...)
        table.insert(lines, printLine(...))
    end

    sandbox.p = function(...)
        table.insert(lines, prettyLine(...))
    end

    sandbox.command = function(cmd,type,...)
      local command = require("/app/commands/"..cmd..".lua")
      if type == "info" then
        table.insert(lines, tableToString(command.info))
      elseif type == "execute" then
        local execute = command.execute(...)
        table.insert(lines,tableToString(execute))
      else
        error("invalid option (execute, info)")
      end
    end

    local fn, syntaxError = load(arg, 'DiscordBot', 't', sandbox)
    if not fn then return {error = true, result = code(syntaxError)} end

    local success, runtimeError = pcall(fn)
    if not success then return {error = true, result = code(runtimeError)} end

    lines = table.concat(lines, '\n')

    if #lines == 0 then
      return {error = false, result = "```lua\non it sir/ma'am```"}
    end
    
    if #lines > 1990 then -- truncate long messages
        lines = lines:sub(1, 1990)
    end

    return {error = false, result = code(lines)}
        
end 

command.info = {
  Name = "Exec",
  Alias = {"eval","e"},
  Usage = "exec <code>",
  Category = "Private",
  Description = "run cool code right from discord isnt that neat",
  PermLvl = 5,
}

command.execute = function(message,args,client)
  if args[2] == nil then return {success = false, msg = "You must provide **code to execute**."} end
  sandbox.client = client
  sandbox.config = require("/app/config.lua")
  sandbox.date = require("discordia").Date
  local code = exec(table.concat(args," ",2),message)
  message:reply{embed = {
    title = "Exec Result",
    description = code.result,
    color = (code.error and 15158332 or 3066993),
    footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
  }}
  return {success = "stfu", msg = "PONG!!"}
end

return command