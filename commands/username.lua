command = {}

command.info = {
  Name = "Username",
  Alias = {},
  Usage = "username <new username>",
  Category = "Private",
  Description = "Change AA-R0N's username.",
  PermLvl = 5,
}

command.execute = function(message,args,client)
  if args[2] == nil then
    return {success = false, msg = "You must provide a **new username** in argument 2."}
  else
    client:setUsername(table.concat(args," ",2))
    return {success = true, msg = "Changed my username to **"..table.concat(args," ",2).."**."}
  end
end

return command