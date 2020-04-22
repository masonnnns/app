command = {}

command = function(message,args,client,data)
  if args[3] ~= nil then args[3] = args[3]:lower() end
  if args[3] == "view" then
    if #data.tags.tags == 0 then return {success = false, msg = "There are no tags setup."} end
    local embed = {
      title = "Tags ["..#data.tags.tags.."]",
      description = "",
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = (message.member:getColor() == 0 and 3066993 or message.member:getColor().value),
    }
    local tble = {}
    for a,b in pairs(data.tags.tags) do
      tble[1+#tble] = b.name
    end
    embed.description = table.concat(tble,", ")
    message:reply{embed = embed}
    return {success = "stfu"}
  elseif args[3] == "delete" then
    if args[4] == nil then return {success = false, msg = "You must provide a tag to delete."} end
    for a,b in pairs(data.tags.tags) do
      if b.name:lower() == args[4]:lower() then
        table.remove(data.tags.tags,a)
        return {success = true, msg = "Deleted the **"..args[4]:lower().."** tag."}
      end
    end
    return {success = false, msg = "No tags by that name were found."}
  elseif args[3] == "create" then
    if args[4] == nil then return {success = false, msg = "You must provide a title for the tag."} end
    for a,b in pairs(data.tags.tags) do
      if b.name:lower() == args[4]:lower() then
        return {success = false, msg = "A tag with this name already exists."}
      end
    end
    if args[5] == nil then return {success = false, msg = "You must provide content for the tag."} end
    if not data.vip and #data.tags.tags + 1 > 100 then return {success = false, msg = "Non-VIP guilds have a limit of 100 tags."} end
    local content = string.sub(message.content,(string.len(args[1])+string.len(args[2])+string.len(args[3])+string.len(args[4])+5))
    if string.len(content) >= 1500 then return {success = false, msg = "Your tag content must be under 1,500 characters."} end
    data.tags.tags[1+#data.tags.tags] = {name = args[4]:lower(), content = content}
    return {success = true, msg = "Created the **"..args[4]:lower().."** tag."}
  elseif args[3] == "edit" then
    if args[4] == nil then return {success = false, msg = "You must provide a tag to edit."} end
    for a,b in pairs(data.tags.tags) do
      if b.name:lower() == args[4]:lower() then
        if args[5] == nil then return {success = false, msg = "You must provide new content for the tag."} end
        local content = string.sub(message.content,(string.len(args[1])+string.len(args[2])+string.len(args[3])+string.len(args[4])+5))
        if string.len(content) >= 1500 then return {success = false, msg = "Your tag content must be under 1,500 characters."} end
        b.content = content
        return {success = true, msg = "Edited the **"..b.name.."** tag."}
      end
    end
    return {success = false, msg = "No tags by that name were found."}
  elseif args[3] == "delcmd" then
    data.tags.delete = not data.tags.delete
    return {success = true, msg = "**"..(data.tags.delete and "Enabled" or "Disabled").."** deleting the tag invocation message."}
  elseif args[3] == "toggle" then
    data.tags.enabled = not data.tags.enabled
    return {success = true, msg = "**"..(data.tags.enabled and "Enabled" or "Disabled").."** the tags plugin."}
  else
    message:reply{embed = {
      title = "Tags Settings",
      description = "To edit a setting in the tag plugin, say **"..data.general.prefix..args[1].." "..args[2].." <setting name> <new value>**",
      fields = {
        {name = "Settings", value = "**View -** View all the existing tags.\n**Create -** Make a new tag.\n**Edit -** Edit an existing tag.\n**Delete -** Delete a tag.\n**DelCmd -** Delete the command invocation message.", inline = true},
      },
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      color = (message.member:getColor() == 0 and 3066993 or message.member:getColor().value),
    }}
    return {success = "stfu"}
  end
end

return command