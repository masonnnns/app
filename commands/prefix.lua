command = {}

command.info = {
  Name = "Prefix",
  Alias = {},
  Example = "prefix <new prefix>",
  Description = "Change the server's prefix.",
  PermLvl = 2,
}

command.execute = function(message,config,args)
  if args[2] == nil then
    return {success = false, msg = "You must provide a **new prefix.**"}
  elseif string.len(args[2]) > 10 or string.len(args[2]) < 1 then
    return {success = false, msg = "The new prefix must be between **1 and 10 characters.**"}
  else
  end
end

return command