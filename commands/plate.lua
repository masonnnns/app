command = {}

command.info = {
  Name = "Plate",
  Alias = {"gp"},
  Usage = "gp [string]",
  Category = "Private",
  Description = "Translate a string into the phonetic alphabet.",
  PermLvl = 5,
}

local alphabet = {
  ["a"] = "Alpha",
  ["b"] = "Bravo",
  ["c"] = "Charlie",
  ["d"] = "Delta",
  ["e"] = "Echo",
  ["f"] = "Foxtrot"
  ["g"] = "Golf",
  ["h"] = "Hotel",
  ["i"] = "India",
  ["j"] = "Juliet",
  ["k"] = "Kilo",
  ["l"] = "Lima",
  ["m"] = "Mike",
  ["n"] = "November",
  ["o"] = "Oscar",
  ["p"] = "Papa",
  ["q"] = "Quebec",
  [""]
}

command.execute = function(message,args,client)
  local stringSep = {}
  repeat
    stringSep[1+#stringSep] = string.sub(table.concat(args," ",2),1+#stringSep,1+#stringSep)
    require("timer").sleep(100)
  until
  #stringSep == string.len(table.concat(args," ",2))
  for _,items in pairs(stringSep) do print(items) end
  return {success = "stfu", msg = ""}
end

return command