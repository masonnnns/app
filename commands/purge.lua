command = {}

local config = require("/app/config.lua")

command.info = {
  Name = "Purge",
  Alias = {},
  Usage = "purge <amount of messages 1-100>",
  Description = "Bulk Delete messages from a channel.",
  PermLvl = 2,
}

command.execute = function(message,args,client)
  local data = config.getConfig(message.guild.id)
  if tonumber(args[2]) == nil then
    return {success = false, msg = "You must provide a **number of messages to delete** in argument 2."}
  elseif tonumber(args[2]) > 100 or tonumber(args[2]) < 1 then
    return {success = false, msg = "The number of messages must be between **1 and 100**."}
  else
    args[2] = tonumber(args[2])
    args[2] = args[2] + 1
    local num = 0
    local msgs = message.channel:getMessages(tonumber(args[2]))
    for a,items in pairs(msgs) do if math.floor(items.createdAt) + 1209600 >= os.time() then num = num + 1 else table.remove(msgs,a) end end
    if num == 0 then
      return {success = false, msg = "I couldn't delete **any messages**."} 
    else
      data.purgeignore[message.channel.id] = num
      config.updateConfig(message.guild.id,data)
      local purge = message.channel:bulkDelete(msgs)
      if purge then
        if message.channel then message:delete() end
        if data.auditlog ~= "nil" and message.guild:getChannel(data.auditlog) then
          local messages = {}
          for _,items in pairs(msgs) do messages[1+#messages] = "["..message.author.username.." ("..message.author.id..")]: "..message.content end
          message.guild:getChannel(data.auditlog):send{embed = {
            title = "Bulk Message Deletion",
            fields = {
              {
                name = "Channel",
                value = message.channel.mentionString,
                inline = true,
              },
              {
                name = "Number of Messages",
                value = tostring(num - 1),
                inline = true,
              },
              {
                name = "Responsible Member",
                value = message.author.mentionString.." (`"..message.author.id.."`)",
                inline = true,
              },
            },
            color = 3447003,
          },
            file = {"purgedMessages.txt", table.concat(messages, "\n")},
          }
        end
        return {success = true, msg = "Purged **"..(num - 1).."** message"..(num == 1 and "" or "s").."."}
      else
        return {success = false, msg = "Failed to purge."}
      end
    end
  end
end

return command