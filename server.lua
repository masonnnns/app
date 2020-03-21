local discordia = require('discordia')

local client = discordia.Client {
	logFile = 'mybot.log',
	cacheAllMembers = true,
	autoReconnect = false,
}

local config = require("/app/config.lua")
config.setupConfigs('xddd')

local function sepMsg(msg)
	local Args = {}
	local Command = msg
	for Match in Command:gmatch("[^%s]+") do
	table.insert(Args, Match)
	end;
	local Data = {
	["MessageData"] = Message;
	["Args"] = Args;
	}
	return Args
end

client:on("messageCreate",function(message)
  if message.guild == nil then return end
  if message.guild.id ~= "551017079797579795" then return end 
  if message.author.bot or message.guild.id == nil then return false end
  local data = config.getConfig(message.guild.id)
  if string.sub(message.content,1,string.len(data.general.prefix)) == data.general.prefix then
    local args = sepMsg(string.sub(message.content,string.len(data.general.prefix)+1))
    local found
    for file, _type in require("fs").scandirSync("./commands") do
      if _type ~= "directory" then
        local command = require("./commands/"..file)
        if string.lower(args[1]) == string.lower(command.info.Name) then
          found = file break
        elseif #command.info.Alias >= 1 then
          for _,items in pairs(command.info.Alias) do
            if string.lower(items) == string.lower(args[1]) then
              found = file break
            end
          end
        end
      end
    end
    local command
    if found ~= nil then command = require("/app/commands/"..found) end
    local permLvl = require("/app/utils.lua").Permlvl(message,client)
    if found ~= nil and command.info.Category == "Private" and message.author.id == client.owner.id then permLvl = 6 end
    if found == nil or permLvl == 0 and data.general.modonly == true or permLvl < command.info.PermLvl then
      if found ~= nil and data.general.modonly == false then 
          local m = message:reply("<:aforbidden:678187354242023434> You **don't have permissions** to use this command!")
          require("timer").sleep(5000)
          m:delete()
      end
    else
      if message and data.general.delcmd then message:delete() end
      local execute = command.execute(message,args,client)
      if execute == nil or type(execute) ~= "table" then
        message:reply("<:atickno:678186665616998400> An **unknown error** occured.")
      elseif execute.success == false then
        message:reply("<:atickno:678186665616998400> "..execute.msg)
      elseif tostring(execute.success):lower() == "stfu" then
        -- stfu literally
      else
        message:reply((execute.emote == nil and "<:atickyes:678186418937397249> " or execute.emote).." "..execute.msg)
      end
    end
  end
end)

-- [[ ON READY ]]

client:on("ready", function()
  client:setGame("?help")
  while true do
    for id,data in pairs(config.getConfig("*")) do
      if #data.moderation.actions >= 0 then
        for _,items in pairs(data.moderation.actions) do
          if items.duration <= os.time() then
            local guilds = client:getGuild(id)
            if guilds ~= nil then
              if items.type == "ban" then
                if guilds:getMember("414030463792054282"):getPermissions():has("banMembers") or guilds:getMember("414030463792054282"):getPermissions():has("administrator") then guilds:unbanUser(items.id, "Ban duration expired.") end
                data.moderation.cases[1+#data.moderation.cases] = {type = "unban", user = items.id, moderator = client.user.id, reason = "Ban duration expired. (Case "..items.case..")", modlog = "nil"}
                if data.general.modlog ~= "nil" and guilds:getChannel(data.general.modlog) ~= nil then
                  local modlog = guilds:getChannel(data.general.modlog):send{embed = {
                    title = "Automatic Unban - Case "..#data.moderation.cases,
                    fields = {
                      {name = "User", value = client:getUser(items.id).tag.." (`"..items.id.."`)", inline = false},
                      {name = "Moderator", value = client.user.tag.." (`"..client.user.id.."`)",inline = false},
                      {name = "Reason", value = "Ban duration expired. (Case "..items.case..")", inline = false},
                    },
                    color = 3066993,
                  }}
                  data.moderation.cases[#data.moderation.cases].modlog = modlog.id  
                end
              elseif items.type == "mute" then
                if guilds:getMember(items.id) and guilds:getMember("414030463792054282"):getPermissions():has("manageRoles") or guilds:getMember("414030463792054282"):getPermissions():has("administrator") then guilds:getMember(items.id):removeRole(data.general.mutedrole) end
                data.moderation.cases[1+#data.moderation.cases] = {type = "unmute", user = items.id, moderator = client.user.id, reason = "Mute duration expired. (Case "..items.case..")", modlog = "nil"}
                if data.general.modlog ~= "nil" and guilds:getChannel(data.general.modlog) ~= nil then
                  local modlog = guilds:getChannel(data.general.modlog):send{embed = {
                    title = "Automatic Unmute - Case "..#data.moderation.cases,
                    fields = {
                      {name = "User", value = client:getUser(items.id).tag.." (`"..items.id.."`)", inline = false},
                      {name = "Moderator", value = client.user.tag.." (`"..client.user.id.."`)",inline = false},
                      {name = "Reason", value = "Mute duration expired. (Case "..items.case..")", inline = false},
                    },
                    color = 3066993,
                  }}
                  data.moderation.cases[#data.moderation.cases].modlog = modlog.id  
                end
              end
              table.remove(data.moderation.actions,_)
            end
          end
        end
      end
    end
  require("timer").sleep(10000)
  end
end)

-- [[ EVENTS ]]

client:on("reactionAdd", function(reaction, userId) 
  local page = require("/app/pages.lua")
  page.processReaction(reaction,userId)
end)

client:on("messageDelete", function(message)
  if message.guild == nil then return end
  local data = require("/app/config.lua").getConfig(message.guild.id)
  for _,items in pairs(data.general.auditignore) do if items == message.channel.id then return end end
  local auditlog = message.guild:getAuditLogs({user = message.author.id, type = 72})
  print(auditlog)
end)

client:run("Bot NDYzODQ1ODQxMDM2MTE1OTc4.Xl4M2A.Nc_KemmsB_3HFVMLVnmIuMBjJLk")