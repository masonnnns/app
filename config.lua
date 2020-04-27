local config = {
  token = "NDYzODQ1ODQxMDM2MTE1OTc4.XqX_1Q.OARIWrPL6G1k10M_TTLa2u-FguM", -- The TOKEN of your Discord bot. (Keep this a secret.)
  prefix = "!", --// The command prefix for the bot.
  verifiedRole = "", -- Role ID in string form, one verified role allowed.
  perms = {
    adminRole = "", -- Role ID of the Bot Admin role.
    modRole = "", -- Role ID of the Bot Moderator role.
    users = {{"276294288529293312","admin"}}, -- User IDs of forced permissions and the type. ("admin" or "mod")
  },
  groupId = 0,
  bindings = {
    --[Rank ID] = "Role ID"
  }
}

return config