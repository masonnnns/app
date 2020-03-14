command = {}

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