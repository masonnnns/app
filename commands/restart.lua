command = {}

command.info = {
  Name = "Restart",
  Alias = {},
  Example = "restart",
  Description = "restart the bot.",
  PermLvl = 5,
}

command.execute = function(message,config)
  message:reply(":ok_hand: Restarting bot.")
  os.exit()
  os.exit()
  os.exit()
  return {success = "stfu", msg = "console", emote = ":ping_pong:"}
end

return command