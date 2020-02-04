command = {}

command.info = {
  Name = "Test",
  Alias = {},
  Usage = "test",
  Description = "test.",
  PermLvl = 5,
}

command.execute = function(message,args,client)
  lines = {"xd","hi","test"}
  message.channel:send {
		file = {"lines.txt", table.concat(lines, "\n")} -- concatenate and send the collected lines in a file
	}
  return {success = "stfu"}
end

return command