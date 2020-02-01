command = {}

local function code(str)
    return string.format('```\n%s```', str)
end

local sandbox = setmetatable({ }, { __index = _G })

local function exec(arg, msg)

    if not arg then return end
    if msg.author ~= msg.client.owner then return end

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
    if not fn then return msg:reply(code(syntaxError)) end

    local success, runtimeError = pcall(fn)
    if not success then return msg:reply(code(runtimeError)) end

    lines = table.concat(lines, '\n')

    if #lines > 1990 then -- truncate long messages
        lines = lines:sub(1, 1990)
    end

    return msg:reply(code(lines))
        
end 

command.info = {
  Name = "Exec",
  Alias = {"eval"},
  Usage = "exec code",
  Description = "emit an event to discord",
  PermLvl = 5,
}

command.execute = function(message,args,client)
  exec(string.sub(message.content,string.len(args[1]+1),))
  return {success = "emitted", msg = "PONG!!"}
end

return command