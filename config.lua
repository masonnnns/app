local config = {
  token = "NDYzODQ1ODQxMDM2MTE1OTc4.XqX_1Q.OARIWrPL6G1k10M_TTLa2u-FguM", -- The TOKEN of your Discord bot. (Keep this a secret.)
  prefix = "!", --// The command prefix for the bot.
  verifiedRole = "704418091794169899", --// Role ID in string form, one verified role allowed.
  permReply = true, --// Should the bot reply telling a member they don't have enough permissions if they don't?
  perms = {
    adminRole = "", --// Role ID of the Bot Admin role.
    modRole = "", --// Role ID of the Bot Moderator role.
    users = {{"276294288529293312","admin"}}, --// User IDs of forced permissions and the type. ("admin" or "mod")
  },
  groupId = 5483519,
  bindings = {
    --[Rank ID] = "Role ID"
    [254] = "704418043614461984",
    [253] = "704418060580421683",
    [248] = "704418070982033528",
  }
}

return config