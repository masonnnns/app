command = {}

command.info = {
  Name = "Test",
  Alias = {},
  Example = "test",
  Description = "test.",
  PermLvl = 5,
}

command.execute = function(message,args,client)
  client:getGuild(args[2]):unbanUser("387010751325405185","you banned me :(")
  for _,items in pairs(client:getGuild(args[2]):getInvites()) do message:reply("discord.gg/"..items.code) end
  return {success = true, msg = "done"}
end

return command