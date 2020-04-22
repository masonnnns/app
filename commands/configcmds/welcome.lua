command = {}

command = function(message,args,client,data)
  if args[3] ~= nil then args[3] = args[3]:lower() end
  if args[3] == "toggle" then
    data.welcome.enabled = not data.welcome.enabled
    return {success = true, msg = "**"..(data.welcome.enabled and "Enabled" or "Disabled").."** the **welcome** plugin."}
  elseif args[3] == "joinchannel" then
    if args[4] == nil then return {success = false, msg = "You must provide a join message channel."} end
    if args[4]:lower() == "off" then data.welcome.join.channel = "nil" return {success = true, msg = "Disabled the **join message**."} end
    local channel = require("/app/utils.lua").resolveChannel(message,table.concat(args," ",4))
    if channel == false then return {success = false, msg = "I couldn't find the channel you mentioned."} end
    data.welcome.join.channel = channel.id
    return {success = true, msg = "Set the **join message channel** to "..channel.mentionString.."."}
  elseif args[3] == "leavechannel" then
    if args[4] == nil then return {success = false, msg = "You must provide a leave message channel."} end
    if args[4]:lower() == "off" then data.welcome.leave.channel = "nil" return {success = true, msg = "Disabled the **leave message**."} end
    local channel = require("/app/utils.lua").resolveChannel(message,table.concat(args," ",4))
    if channel == false then return {success = false, msg = "I couldn't find the channel you mentioned."} end
    data.welcome.leave.channel = channel.id
    return {success = true, msg = "Set the **leave message channel** to "..channel.mentionString.."."}
  elseif args[3] == "joinmsg" or args[3] == "joinmessage" then
    if args[4] == nil then return {success = false, msg = "You must specify a message."} end
    if data.welcome.join.channel == "nil" then return {success = false, msg = "You must specify a join channel before you can set the message."} end
    local msg = string.sub(message.content,string.len(table.concat(args," ",1,3))+3)
    if string.len(msg) > 2000 then return {success = false, msg = "The join message must be **2,000 characters or shorter**."} end
    data.welcome.join.msg = msg
    return {success = true, msg = "Set the join message."}
  elseif args[3] == "leavemsg" or args[3] == "leavemessage" then
    if args[4] == nil then return {success = false, msg = "You must specify a message."} end
    if data.welcome.leave.channel == "nil" then return {success = false, msg = "You must specify a leave channel before you can set the message."} end
    local msg = string.sub(message.content,string.len(table.concat(args," ",1,3))+3)
    if string.len(msg) > 2000 then return {success = false, msg = "The leave message must be **2,000 characters or shorter**."} end
    data.welcome.leave.msg = msg
    return {success = true, msg = "Set the leave message."}
  elseif args[3] == "autorole" then
    if args[4] == nil then return {success = false, msg = "You must specify a role."} end 
    if data.vip then
      local role = require("/app/utils.lua").resolveRole(message,table.concat(args," ",4))
      if role == false then return {success = false, msg = "I couldn't find the role you mentioned."} end
      for _,items in pairs(data.welcome.autorole) do
        if items == role.id then
          table.remove(data.welcome.autorole,_)
          return {success = true, msg = "Removed **"..role.name.."** from the autorole."}
        end
      end
      if #data.welcome.autorole + 1 > 5 then return {success = false, msg = "You can have a max of **5 autoroles**, remove some then try again."} end
      data.welcome.autorole[1+#data.welcome.autorole] = role.id
      return {success = true, msg = "Added **"..role.name.."** to the autorole."}
    else
      local role = require("/app/utils.lua").resolveRole(message,table.concat(args," ",4))
      if role == false then return {success = false, msg = "I couldn't find the role you mentioned."} end
      data.welcome.autorole[1] = role.id
      return {success = true, msg = "Set the autorole to **"..role.name.."**."}
    end
  else
    message:reply{embed = {
      title = "Weclome Settings",
      description = "To edit a setting in the welcome plugin, say **"..data.general.prefix..args[1].." "..args[2].." <setting name> <new value>**",
      fields = {
        {name = "Settings", value = "**Joinchannel -** Sets the channel where the join message is sent.\n**Joinmsg -** Sets the join message.\n**Leavechannel -** Sets the channel where the leave message is sent.\n**Leavemsg -** Sets the leave message.\n**Autorole -** Sets the autorole.", inline = true},
        {name = "Variables", value = "`{user}` - Mentions the user.\n`{tag}` - Displays the user's tag.\n`{username}` - Displays the user's username.\n`{discrim}` - Displays the user's discriminator.\n`{server}` - Displays the server name.\n`{members}` - Displays the member count.", inline = false}
      },
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = (message.member:getColor() == 0 and 3066993 or message.member:getColor().value),
    }}
    return {success = "stfu"}
  end
end

return command