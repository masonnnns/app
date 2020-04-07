command = {}

command = function(message,args,client,data)
  if args[3] ~= nil then args[3] = args[3]:lower() end
  if args[3] == "joinchannel" then
    if args[4] == nil then return {success = false, msg = "You must provide a join message channel."} end
    if args[4]:lower() == "off" then data.welcome.join.channel = "nil" return {success = false, msg = "Disabled the **join message**."} end
    local channel = require("/app/utils.lua").resolveChannel(message,table.concat(args," ",4))
    if channel == false then return {success = false, msg = "I couldn't find the channel you mentioned."} end
    data.welcome.join.channel = channel.id
    return {success = true, msg = "Set the **join message channel** to "..channel.mentionString.."."}
  elseif args[3] == "leavechannel" then
    if args[4] == nil then return {success = false, msg = "You must provide a leave message channel."} end
    if args[4]:lower() == "off" then data.welcome.leave.channel = "nil" return {success = false, msg = "Disabled the **leave message**."} end
    local channel = require("/app/utils.lua").resolveChannel(message,table.concat(args," ",4))
    if channel == false then return {success = false, msg = "I couldn't find the channel you mentioned."} end
    data.welcome.leave.channel = channel.id
    return {success = true, msg = "Set the **leave message channel** to "..channel.mentionString.."."}
  elseif args[3] == "joinmsg" or args[3] == "joinmessage" then
    if data.welcome.join.channel == "nil" then return {success = false, msg = "You must specify a join channel before you can set the message."} end
    local msg = string.sub(message.content,string.len(table.concat(args," ",1,3))+3)
    if string.len(msg) > 2000 then return {success = false, msg = "The join message must be **2,000 characters or shorter**."} end
    data.welcome.join.msg = msg
    return {success = true, msg = "Set the join message."}
  elseif args[3] == "leavemsg" or args[3] == "leavemessage" then
    if data.welcome.leave.channel == "nil" then return {success = false, msg = "You must specify a leave channel before you can set the message."} end
    local msg = string.sub(message.content,string.len(table.concat(args," ",1,3))+3)
    if string.len(msg) > 2000 then return {success = false, msg = "The leave message must be **2,000 characters or shorter**."} end
    data.welcome.leave.msg = msg
    return {success = true, msg = "Set the leave message."}
  elseif args[3] == "autorole" then
    if data.vip then
    else
      local role = require("/app/utils.lua").resolveRole(message,table.concat(args," ",4))
      if role == false then return {success = false, msg = "I couldn't find the role you mentioned."} end
      data.welcome.autorole[1] = role.id
      return {success = true, msg = "Set the autorole to **"..role.name.."**."}
    end
  else
    message:reply{embed = {
      title = "General Settings",
      description = "To edit a setting in the general plugin, say **?"..args[1].." "..args[2].." <setting name> <new value>**",
      fields = {
        {name = "Settings", value = "**Prefix -** Changes the prefix of the server.\n**Delcmd -** Toggles on or off AA-R0N deleting the command invocation message.\n**Auditlog -** Sets the auditlog channel.\n**Ignore -** Adds channel to the audit log's ignored channels.", inline = true},
      },
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = (message.guild:getMember(message.author.id).highestRole.color == 0 and 3066993 or message.guild:getMember(message.author.id).highestRole.color),
    }}
    return {success = "stfu"}
  end
end

return command