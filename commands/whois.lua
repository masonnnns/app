command = {}

local config = require("/app/config.lua")
local utils = require("/app/utils.lua")
local discordia = require("discordia")
local Date = discordia.Date

command.info = {
  Name = "Userinfo",
  Alias = {"w","whois","ui"},
  Usage = "userinfo <optional user>",
  Category = "Utility",
  Description = "Views information on a specified user.",
  PermLvl = 0,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if args[2] == nil then args[2] = message.author.id end
  local user = utils.resolveUser(message,table.concat(args," ",2))
  local inGuild = true
  if user == false and tonumber(args[2]) ~= nil then if client:getUser(args[2]) ~= nil then user = client:getUser(args[2]) inGuild = false else user = false end end
  if user == false then
    return {success = false, msg = "I couldn't find the user you mentioned."}
  else
    local embed = {}
    embed.title = user.tag
    embed.thumbnail = {url = (user.avatarURL == nil and "https://cdn.discordapp.com/embed/avatars/"..math.random(1,4)..".png" or user.avatarURL)}
    embed.footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag}
    embed.color = (message.member:getColor() == 0 and 3066993 or message.member:getColor().value)
    if inGuild == true then
      embed.fields = {
        {name = "Mention", value = user.mentionString, inline = true},
        {name = "ID", value = user.id, inline = true},
        {name = "Nickname", value = (user.nickname == nil and "None Set." or user.nickname), inline = true},
        {name = "Status", value = "loading...", inline = true},
        {name = "Activity", value = "Nothing!", inline = true},
        {name = "Server Permission", value = "Member", inline = true},
        {name = "Created At", value = utils.parseDateString(Date.fromSnowflake(user.id):toString(),1), inline = true},
        {name = "Joined At", value = (user.joinedAt and utils.parseDateString(Date(Date.parseISO(user.joinedAt)):toString(),1) or "ERROR"), inline = true},
        {name = "Roles [0]", value = "None!", inline = false},
        {name = "Permissions", value = "None!", inline = false},
      }
      if user.status == "online" then embed.fields[4].value = "Online" end
      if user.status == "idle" then embed.fields[4].value = "Idle" end
      if user.status == "dnd" then embed.fields[4].value = "Do Not Disturb" end
      if user.status == "offline" then embed.fields[4].value = "Offline" end
      if user.activity then
        if user.activity.type == 4 then --// Custom Status
          embed.fields[5].value = user.activity.state
        elseif user.activity.type == 2 then
          embed.fields[5].value = "Listening to "..user.activity.name
        elseif user.activity.type == 1 then
          embed.fields[5].value = "Streaming "..user.activity.name
        else
          embed.fields[5].value = "Playing "..user.activity.name
        end
      end
      local roles = {}
      for _,items in pairs(user.roles) do roles[1+#roles] = items.mentionString end
      embed.fields[9].name = "Role"..(#roles == 1 and "" or "s").." ["..#roles.."]"
      if #roles ~= 0 then embed.fields[9].value = table.concat(roles," ") end
      local permLvl = utils.Permlvl(message,client,user.id)
      if permLvl == 1 then
        embed.fields[6].value = "Moderator"
      elseif permLvl == 2 then
        embed.fields[6].value = "Administrator"
      elseif permLvl == 3 then
        embed.fields[6].value = "Owner"
      else
        embed.fields[6].value = "Member"
      end
      roles = {}
      for a,items in pairs(user:getPermissions():toTable()) do if items == true then roles[1+#roles] = string.sub(a,1,1):upper()..string.sub(a,2) end end
      embed.fields[10].value = string.sub(table.concat(roles,", "),1,1000)
    else
      embed.fields = {
        {name = "Mention", value = user.mentionString, inline = true},
        {name = "ID", value = user.id, inline = true},
        {name = "Created At", value = utils.parseDateString(Date.fromSnowflake(user.id):toString(),1), inline = true},
      }
      embed.description = "This user isn't in the guild."
      if #user.mutualGuilds:toArray() ~= 0 then
        user = user.mutualGuilds:toArray()[1]:getMember(user.id)
        embed.fields[1+#embed.fields] = {name = "Status", value = "Nothing", inline = true}
        embed.fields[1+#embed.fields] = {name = "Activity", value = "Nothing", inline = true}
        if user.status == "online" then embed.fields[4].value = "Online" end
        if user.status == "idle" then embed.fields[4].value = "Idle" end
        if user.status == "dnd" then embed.fields[4].value = "Do Not Disturb" end
        if user.status == "offline" then embed.fields[4].value = "Offline" end
        if user.activity then
          if user.activity.type == 4 then --// Custom Status
            embed.fields[5].value = user.activity.state
          elseif user.activity.type == 2 then
            embed.fields[5].value = "Listening to "..user.activity.name
          elseif user.activity.type == 1 then
            embed.fields[5].value = "Streaming "..user.activity.name
          else
            embed.fields[5].value = "Playing "..user.activity.name
          end
        end
      end
    end
    if user.id == "276294288529293312" then
      embed.fields[1+#embed.fields] = {name = "Notes", value = "AA-R0N Owner and Developer", inline = false}
    elseif user.id == "414030463792054282" then
      embed.fields[1+#embed.fields] = {name = "Notes", value = "Official AA-R0N Bot.", inline = false}
    elseif user.id == "463845841036115978" then
      embed.fields[1+#embed.fields] = {name = "Notes", value = "Official AA-R0N Development Bot.", inline = false}
    end
    message:reply{embed = embed}
    return {success = "stfu"}
  end
end

return command