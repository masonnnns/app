command = {}

local cache = require("/app/server.lua")
local config = require("/app/config.lua")

command.info = {
  Name = "Rps",
  Alias = {"RockPaperScissors"},
  Usage = "rps <rock/paper/scissors>",
  Category = "Fun",
  Description = "Play a game of rock paper scissors with AA-R0N.",
  PermLvl = 0,
}

local function getObj(num)
  if num == 1 then
  end
end

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if data.games.enabled == false then return {success = false, msg = "The **games** plugin is **disabled**."} end
  if args[2] == nil then
    return {success = false, msg = "You must provide **rock, paper or scissors** in argument 2."}
  elseif args[2]:lower() ~= "rock" and args[2]:lower() ~= "paper" and args[2]:lower() ~= "scissors" and args[2]:lower() ~= "r" and args[2]:lower() ~= "p" and args[2]:lower() ~= "s" then
    return {success = false, msg = "You must provide **rock, paper or scissors** in argument 2."}
  else
    local botNum, theirNum = math.random(1,3), 0
    args[2] = args[2]:lower()
    if args[2] == "rock" or args[2] == "r" then
      theirNum = 1
    elseif args[2] == "paper" or args[2] == "p" then
      theirNum = 2
    elseif args[2] == "scissors" or args[2] == "s" then
      theirNum = 3
    else
      return {success = false, msg = "Invalid arg 2."}
    end
    if botNum == theirNum then
      return {success = false, msg = "", emoji = ""}
    end
  end
end

return command