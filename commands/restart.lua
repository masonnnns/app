command = {}

command.info = {
  Name = "Restart",
  Alias = {"r"},
  Usage = "restart",
  Category = "Private",
  Description = "Restart the bot from Discord.",
  PermLvl = 5,
}

command.execute = function(message,args,client)
  message:reply("Restarting...")
  os.exit()
  os.exit()
  os.exit()
  return {success = "stfu"}
end

return command