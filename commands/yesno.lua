command = {}

local cache = require("/app/server.lua")

command.info = {
  Name = "YesNo",
  Alias = {"yn"},
  Usage = "yesno",
  Category = "Fun",
  Description = "Have AA-R0N make a yes/no decision for you.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  local num = math.random(1,2)
  if num == 1 then
    return {success = true, msg = "I choose **yes**."}
  else
    return {success = true, msg = "I choose **no**."}
  end
end

return command