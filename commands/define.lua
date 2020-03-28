command = {}

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")
local http = require("coro-http")
local json = require('json')

command.info = {
  Name = "Define",
  Alias = {},
  Usage = "define <word>",
  Category = "Fun",
  Description = "Get a definition for the specified word.",
  PermLvl = 0,
  Cooldown = 5,
}

local function capsFirst(str)
  if type(str) == "string" then
    return string.sub(str,1,1):upper()..string.sub(str,2)
  else
    local upper = {}
    for _,items in pairs(str) do
      if items ~= nil then
        items = items:lower()
        upper[1+#upper] = string.sub(items,1,1):upper()..string.sub(items,2)
      end
    end
    return table.concat(upper," ")
  end
end

command.execute = function(message,args,client)
  if args[2] == nil then return {success = false, msg = "You must provide a word for me to define!"} end
  table.remove(args,1)
  local headers = {
    {"app_id", "050df1ed"},
    {"app_key", "dca7fd868c5eba269c58d493e4539a55"}
  }
  local result, body = http.request("GET","https://od-api.oxforddictionaries.com/api/v2/entries/en-us/"..table.concat(args," "):lower(),headers)
  if result.code == 404 then return {success = false, msg = "I couldn't find a defionition for that word."} end
  if result.code ~= 200 then return {success = false, msg = "I had trouble defining that word. Try again. `(HTTP "..result.code..")`"} end
  body = json.decode(body)
  local meaning = body.results[1].lexicalEntries[1].entries[1].senses[1].definitions[1]
  local embed = {
    title = "Definition of "..capsFirst(args),
    description = capsFirst(meaning)..(string.sub(meaning,string.len(meaning),string.len(meaning)) == "." and "" or "."),
    fields = {
      {name = "Synonyms", value = "", inline = false},
      {name = "Examples", value = "", inline = false},
    },
    footer = {icon_url = message.author:getAvatarURL(), text = "By Oxford Dictionary • Responding to "..message.author.tag},
    color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
  }
  local num = 0
  if body.results[1].lexicalEntries[1].entries[1].senses[1].synonyms == nil or #body.results[1].lexicalEntries[1].entries[1].senses[1].synonyms == 0 then
    table.remove(embed.fields,1)
  else
    if #body.results[1].lexicalEntries[1].entries[1].senses[1].synonyms ~= 0 then embed.fields[1].value = "" end
    for _,items in pairs(body.results[1].lexicalEntries[1].entries[1].senses[1].synonyms) do num = num+1 if num - 1 == 5 then break end if embed.fields[1].value == "" then embed.fields[1].value = capsFirst(items.text) else embed.fields[1].value = embed.fields[1].value..", "..capsFirst(items.text) end end
  end
  num = 0
  if body.results[1].lexicalEntries[1].entries[1].senses[1].examples == nil or #body.results[1].lexicalEntries[1].entries[1].senses[1].examples == 0 then
    table.remove(embed.fields,#embed.fields)
  else
    for _,items in pairs(body.results[1].lexicalEntries[1].entries[1].senses[1].examples) do num = num + 1 if num - 1 == 2 then break end if embed.fields[#embed.fields].value == "" then embed.fields[#embed.fields].value = capsFirst(items.text).."." else embed.fields[#embed.fields].value = embed.fields[#embed.fields].value.."\n"..capsFirst(items.text).."." end end
  end
  if #embed.fields == 0 then embed.fields = nil end
  message:reply{embed = embed}
  return {success = 'stfu'}
end

return command