command = {}

command.info = {
  Name = "Test",
  Alias = {},
  Example = "test",
  Description = "test.",
  PermLvl = 5,
}

command.execute = function(message,args,client)
 
  return {success = true, msg = client:getGuild(args[2]).name}
end

return command