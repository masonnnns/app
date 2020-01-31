command = {}

command.info = {
  Name = "Test",
  Alias = {},
  Example = "test",
  Description = "test.",
  PermLvl = 5,
}

command.execute = function(message,args,client)
 if args[2] == nil then return {success = false, msg = "ok arg 2"} else return {success = true, msg = "there we go"} end
end

return command