--[[
 message.guild:getChannel(configData.modlog):send{embed = {
            title = "Auto Unmute - Case "..#configData.modData.cases,
            fields = {
              {
                name = "Member",
                value = client:getUser(action.user).tag.." (`"..action.user.."`)",
                inline = true,
              },
              {
                name = "Reason",
                value = "Mute duration expired.",
                inline = false,
              },
              {
                name = "Responsible Moderator",
                value = client.user.mentionString.." (`"..client.user.id.."`)",
                inline = false,
              },
            },
            color = 2067276,
          }}

--]]