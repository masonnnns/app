command = {}

command.info = {
  Name = "Say",
  Alias = {},
  Usage = "say <text>",
  Category = "Fun",
  Description = "Have AA-R0N repeat text after you.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  if args[2] == nil then 
    return {success = false, msg = "You must provide a **message to repeat** in argument 2."}
  else
    local sayMsg = string.sub(message.content,string.len(args[1])+1)
    message:delete()
    message:reply(sayMsg)
    return {success = "stfu", msg = ""}
  end
end

return command