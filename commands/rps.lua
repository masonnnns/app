command = {}

local cache = require("/app/server.lua")
local config = require("/app/config.lua")

command.info = {
  Name = "Rps",
  Alias = {"RockPaperScissors"},
  Usage = "rps <rock/paper/scissors>",
  Category = "Fun",
  Cooldown = 1,
  Description = "Play a game of rock paper scissors with AA-R0N.",
  PermLvl = 0,
}

local function getObj(num)
  if num == 1 then
    return "Rock"
  elseif num == 2 then
    return "Paper"
  elseif num == 3 then 
    return "Scissors"
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
    local botNum, theirNum = 0, 0
    local tickets = 0
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
      message:reply("We both selected **"..getObj(theirNum):lower().."**, it's a tie.")
    elseif botNum == 1 then
      if theirNum == 2 then
        message:reply("**Paper** beats **rock**, you win.\n:tickets: **+5 Tickets**")
        tickets = 5
      elseif theirNum == 3 then
        message:reply("**Rock** beats **scissors**, I win.")
      end
    elseif botNum == 2 then
      if theirNum == 3 then
        message:reply("**Scissors** beats **paper**, you win.\n:tickets: **+5 Tickets**")
        tickets = 5
      elseif theirNum == 1 then
        message:reply("**Paper** beats **rock**, I win.")
      end
    elseif botNum == 3 then
      if theirNum == 1 then
        message:reply("**Rock** beats **scissors**, you win.\n:tickets: **+5 Tickets**")
        tickets = 5
      elseif theirNum == 2 then
        message:reply("**Paper** beats **rock**, I win.")
      end
    end
    if tickets > 0 then
      -- add tickets
    end
    return {success = "stfu"}
  end
end

return command