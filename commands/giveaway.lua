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

local utils = require("/app/utils.lua")
local config = require("/app/config.lua")

command.info = {
  Name = "Giveaway",
  Alias = {""},
  Usage = "giveaway <create/reroll/list/end> <time/giveaway ID> <product>",
  Category = "Fun",
  Description = "Host or manage giveaways in your server.",
  PermLvl = 2,
} 

command.execute = function(message,args,client)
  if args[2] == nil then return {success = false, msg = "You must specify create, reroll, list or end."} end
  args[2] = args[2]:lower()
  local data = config.getConfig(message.guild.id)
  if args[2] == "create" then
    if args[3] == nil then return {success = false, msg = "You must provide an expiration for the giveaway."} end
    local duration = getDuration(args[3])
    if durationTable[table.concat(duration.char,"")] == nil then return {success = false, msg = "Invalid duration."} end
    if tonumber(table.concat(duration.numb,"")) * durationTable[table.concat(duration.char,"")][1] <= 0 then return {success = false, msg = "Invalid duration."} end
    if tonumber(table.concat(duration.numb,"")) * durationTable[table.concat(duration.char,"")][1] > 1209600 then return {success = false, msg = "You cannot host giveaways for longer than 2 weeks."} end
    if args[4] == nil then return {success = false, msg = "You must provide a product to giveaway!"} end
    local durationString = table.concat(duration.numb,"").." "..durationTable[table.concat(duration.char,"")][2]..(tonumber(table.concat(duration.numb,"")) == 1 and "" or "s")
    local embed = {
      title = table.concat(args," ",4),
      description = "React with :tada: to enter to win!\nEnds in **"..durationString.."**.",
      footer = {text = "GID: "..message.id.." • Host: "..message.author.tag},
      color = 16580705,
      timestamp = require("discordia").Date():toISO('T', 'Z'),
    }
    local gmsg = message:reply{embed = embed}
    gmsg:addReaction("🎉")
    data.moderation.actions[1+#data.moderation.actions] = {type = "giveaway", duration = os.time() + tonumber(table.concat(duration.numb,"")) * durationTable[table.concat(duration.char,"")][1], host = message.author.id, channel = message.channel.id, id = gmsg.id, gid = message.id, product = table.concat(args," ",4)}
    return {success = "stfu"}
  end
end

command.finishGiveaway = function(guild,data,gdata)
  for a,b in pairs(data.moderation.actions) do
    if b.type == "giveaway" and b.id == gdata.id then
      table.remove(data.moderation.actions,a)
    end
  end
  if guild.channels:get(gdata.channel) == nil then return end
  if guild.channels:get(gdata.channel):getMessage(gdata.id) == nil then message:reply("<:atickno:678186665616998400> **Failed to end giveaway!** The origional message couldn't be found.") return end
  local msg = guild.channels:get(gdata.channel):getMessage(gdata.id) 
  if #msg.reactions == 0 then message:reply(":atickno:678186665616998400> **Failed to end giveaway!** I couldn't find the \:tada: reaction.") return end
  local reaction
  for a,b in pairs(msg.reactions) do
    if b.emojiName == "🎉" then
      reaction = b
      break
    end
  end
  if reaction == nil then message:reply(":atickno:678186665616998400> **Failed to end giveaway!** I couldn't find the \:tada: reaction.") return end
  if #reaction:getUsers() <= 1 then message:reply(":atickno:678186665616998400> **Failed to end giveaway!** No one entered the giveaway.") return end
  local winner
  local tries = 0
  repeat
    winner = reaction:getUsers()[math.random(1,#reaction:getUsers())]
    tries = tries + 1
    require("timer").sleep(500)
  until
  winner.id ~= client.user.id and winner.id ~= gdata.host or tries >= 10
  if winner == nil then message:reply(":atickno:678186665616998400> **Failed to end giveaway!** I couldn't determine a winner after "..tries.." attempts.") return end
  
end

return command