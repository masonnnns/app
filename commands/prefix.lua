command = {}

command.info = {
  Name = "Prefix",
  Alias = {},
  Example = "prefix <new prefix>"
  Description = "Change the server's prefix.",
  PermLvl = 2,
}

command.execute = function(message,config,args)
  if args[2] == nil then
    return {success = false, msg = "You must provide a **new prefix.**"}
  elseif string.len(args)
  end
end

return command