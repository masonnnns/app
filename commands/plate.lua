command = {}

command.info = {
  Name = "Plate",
  Alias = {"gp"},
  Usage = "gp [string]",
  Category = "Private",
  Description = "Translate a string into the phonetic alphabet.",
  PermLvl = 5,
  Cooldown = 0,
}

local alphabet = {
  ["a"] = "Alpha",
  ["b"] = "Bravo",
  ["c"] = "Charlie",
  ["d"] = "Delta",
  ["e"] = "Echo",
  ["f"] = "Foxtrot",
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
  ["r"] = "Romeo",
  ["s"] = "Sierra",
  ["t"] = "Tango",
  ["u"] = "Uniform",
  ["v"] = "Victor",
  ["w"] = "Whiskey",
  ["x"] = "X-Ray",
  ["y"] = "Yankee",
  ["z"] = "Zulu",
}

command.execute = function(message,args,client)
  local stringSep = {}
  repeat
    stringSep[1+#stringSep] = string.sub(table.concat(args," ",2),1+#stringSep,1+#stringSep):lower()
    require("timer").sleep(100)
  until
  #stringSep == string.len(table.concat(args," ",2))
  local newString = {}
  for _,items in pairs(stringSep) do
    if alphabet[items] ~= nil then
      newString[_] = alphabet[items]
    elseif items == " " then
      newString[_] = "**|**"
    else
      newString[_] = items
    end
  end
  return {success = true, msg = table.concat(newString," ")}
end

return command