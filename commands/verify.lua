command = {}

local utils = require("/app/utils.lua")

command.info = {
  Name = "Verify",
  Alias = {},
}

command.execute = function(message,args,client)
  return {success = true, msg = utils.getPerm(message)}
end

return command