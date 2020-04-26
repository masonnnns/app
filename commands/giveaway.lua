command = {}

local durationTable = {
	["s"] = {1, "Second"},
  ["min"] = {60, "Minute"},
	["mi"] = {60, "Minute"},
	["m"] = {60, "Minute"},
	["h"] = {3600, "Hour"},
	["hr"] = {3600, "Hour"},
	["d"] = {86400, "Day"},
	["w"] = {604800, "Week"},
	["mo"] = {2592000, "Month"},
	["mon"] = {2592000, "Month"},
	["y"] = {31536000, "Year"},
}

local function getDuration(Args)
	local argData = {numb = {}, char = {}, num = 0, str = string.lower(Args)}
	repeat
		argData.num = argData.num+1
		if tonumber(string.sub(argData.str,argData.num,argData.num)) == nil then
			argData.char[#argData.char + 1] = string.sub(argData.str,argData.num,argData.num)
		else
			argData.numb[#argData.numb + 1] = string.sub(argData.str,argData.num,argData.num)
		end
	until
	argData.num == string.len(argData.str)
	return argData
end

local giveawayCache = {}
--[GID] = dataSaved

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")

command.info = {
  Name = "Giveaway",
  Alias = {},
  Usage = "giveaway <create/reroll/end> <time/giveaway ID> <product>",
  Category = "Fun",
  Description = "Host or manage giveaways in your server.",
  PermLvl = 2,
} 

command.execute = function(message,args,client)
  if config.getConfig(message.guild.id).vip == false then return {success = false, msg = "This command is VIP only. Join our support server to request VIP features."} end
  if args[2] == nil then return {success = false, msg = "You must specify create, reroll or end."} end
  args[2] = args[2]:lower()
  local data = config.getConfig(message.guild.id)
  if args[2] == "create" then
    if args[3] == nil then return {success = false, msg = "You must provide an expiration for the giveaway."} end
    local duration = getDuration(args[3])
    if durationTable[table.concat(duration.char,"")] == nil then return {success = false, msg = "Invalid duration."} end
    if tonumber(table.concat(duration.numb,"")) * durationTable[table.concat(duration.char,"")][1] <= 0 then return {success = false, msg = "Invalid duration."} end
    if tonumber(table.concat(duration.numb,"")) * durationTable[table.concat(duration.char,"")][1] > 1209600 then return {success = false, msg = "You cannot host giveaways for longer than 2 weeks."} end
    if args[4] == nil then return {success = false, msg = "You must provide a product to giveaway!"} end
    local activeGiveaways = 0
    for a,b in pairs(data.moderation.actions) do if b.type == "giveaway" then activeGiveaways = 1+activeGiveaways if activeGiveaways+1 > 10 then break end end end
    if activeGiveaways+1 > 10 then return {success = false, msg = "You can only have 10 active giveaways at a time."} end
    local durationString = table.concat(duration.numb,"").." "..durationTable[table.concat(duration.char,"")][2]..(tonumber(table.concat(duration.numb,"")) == 1 and "" or "s")
    local embed = {
      title = table.concat(args," ",4),
      description = "React with :tada: to enter to win!\nEnds in **"..durationString.."**.",
      footer = {text = "GID: "..message.id.." • Host: "..message.author.tag},
      color = 16580705,
    }
    local gmsg = message:reply{embed = embed}
    gmsg:addReaction("🎉")
    print("[GIVEAWAYS]: Started giveaway "..message.id)
    data.moderation.actions[1+#data.moderation.actions] = {type = "giveaway", duration = os.time() + tonumber(table.concat(duration.numb,"")) * durationTable[table.concat(duration.char,"")][1], host = message.author.id, channel = message.channel.id, id = gmsg.id, gid = message.id, product = table.concat(args," ",4)}
    return {success = "stfu"}
  elseif args[2] == "end" then
    if args[3] == nil then return {success = false, msg = "You must provide a giveaway ID to end."} end
    if tonumber(args[3]) == nil then return {success = false, msg = "The giveaway ID must be a number."} end
    local giveaway
    for a,b in pairs(data.moderation.actions) do
      if b.gid == args[3] then
        giveaway = b
        break
      end
    end
    if giveaway == nil then return {success = false, msg = "I couldn't find an active giveaway with that ID."} end
    print("[GIVEAWAYS]: Giveaway "..giveaway.gid.." is being forcefully ended.")
    command.finishGiveaway(message.guild,data,giveaway)
    if message.guild.textChannels:get(giveaway.channel) == nil then
      return {success = false, msg = "The channel this giveaway originiated in was deleted."}
    elseif giveaway.channel == message.channel.id then
      return {success = "stfu"}
    else
      return {success = true, msg = "Managing the giveaway in **"..message.guild.textChannels:get(giveaway.channel).name.."**!"}
    end
  elseif args[2] == "reroll" then
    if args[3] == nil then return {success = false, msg = "You must provide a giveaway ID to end."} end
    if tonumber(args[3]) == nil then return {success = false, msg = "The giveaway ID must be a number."} end
    local giveaway
    for a,b in pairs(giveawayCache) do
      if tostring(a) == args[3] and b.guild == message.guild.id then
        giveaway = b
        break
      end
    end
    if giveaway == nil then return {success = false, msg = "I couldn't find an ended giveaway with that ID."} end
    print("[GIVEAWAYS]: Giveaway "..giveaway.gid.." is being rerolled.")
    command.finishGiveaway(message.guild,data,giveaway)
    if message.guild.textChannels:get(giveaway.channel) == nil then
      return {success = false, msg = "The channel this giveaway originiated in was deleted."}
    elseif giveaway.channel == message.channel.id then
      return {success = "stfu"}
    else
      return {success = true, msg = "Rerolling the giveaway in **"..message.guild.textChannels:get(giveaway.channel).name.."**!"}
    end
  else
    return {success = false, msg = "You must specify create, reroll or end."}
  end  
end

command.finishGiveaway = function(guild,data,gdata)
  print("[GIVEAWAYS]: Giveaway "..gdata.gid.." is ending or being rerolled.")
  for a,b in pairs(data.moderation.actions) do
    if b.type == "giveaway" and b.id == gdata.id then
      giveawayCache[b.gid] = b
      table.remove(data.moderation.actions,a)
      break
    end
  end
  if guild.textChannels:get(gdata.channel) == nil then return end
  local channel = guild.textChannels:get(gdata.channel)
  if guild.textChannels:get(gdata.channel):getMessage(gdata.id) == nil then channel:send("<:atickno:678186665616998400>  **Failed to "..(giveawayCache[gdata.gid]["nowin"] == nil and "end giveaway" or "reroll").."!** The origional message couldn't be found.") return end
  local msg = guild.textChannels:get(gdata.channel):getMessage(gdata.id) 
  if #msg.reactions == 0 then channel:send("<:atickno:678186665616998400>  **Failed to "..(giveawayCache[gdata.gid]["nowin"] == nil and "end giveaway" or "reroll").."!** I couldn't find the giveaway reaction.") return end
  local reaction
  for a,b in pairs(msg.reactions) do
    if b.emojiName == "🎉" then
      reaction = b
      break
    end
  end
  if reaction == nil then channel:send("<:atickno:678186665616998400>  **Failed to "..(giveawayCache[gdata.gid]["nowin"] == nil and "end giveaway" or "reroll").."!** I couldn't find the giveaway reaction.") return end
  if #reaction:getUsers() <= 1 then channel:send("<:atickno:678186665616998400>  **Failed to "..(giveawayCache[gdata.gid]["nowin"] == nil and "end giveaway" or "reroll").."!** No one entered the giveaway.") return end
  local winner
  local tries = 0
  local reactants = {}
  for a,b in pairs(reaction:getUsers()) do
    if a == gdata.host or a == "414030463792054282" or giveawayCache[gdata.gid]["nowin"] ~= nil and giveawayCache[gdata.gid]["nowin"] == a then else
      reactants[1+#reactants] = b
    end
  end
  if #reactants == 0 then channel:send("<:atickno:678186665616998400>  **Failed to "..(giveawayCache[gdata.gid]["nowin"] == nil and "end giveaway" or "reroll").."!** "..(giveawayCache[gdata.gid]["nowin"] == nil and "No one entered the giveaway." or "There are no other possible winners.")) return end
  repeat
    winner = reactants[math.random(1,#reactants)]
    tries = tries + 1
    require("timer").sleep(500)
  until
  winner ~= nil or tries >= 10
  if winner == nil then channel:send("<:atickno:678186665616998400>  **Failed to "..(giveawayCache[gdata.gid]["nowin"] == nil and "end giveaway" or "reroll").."!** I couldn't determine a winner after "..tries.." attempts.") return end
  local embeds = msg.embed
  if giveawayCache[gdata.gid]["nowin"] == nil then
    embeds.title = "[ENDED]: "..embeds.title
  elseif string.sub(embeds.title,1,7) == "[ENDED]" then
    embeds.title = "[RE-ROLLED]: "..string.sub(embeds.title,8)
  end
  embeds.description = ":tada: **"..winner.tag.."** has won this giveaway!"
  embeds.color = 3066993
  msg:setEmbed(embeds)
  if giveawayCache[gdata.gid]["nowin"] == nil then
    channel:send(":tada: Congratulations "..winner.mentionString..", you've won **"..gdata.product.."**!")
  else
    channel:send(":tata: The new winner is "..winner.mentionString..". Congratulations!")
  end
  giveawayCache[gdata.gid]["nowin"] = winner.id
  giveawayCache[gdata.gid].guild = guild.id
  return
end

return command