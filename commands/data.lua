command = {}

local function MakeTable( t, nice, indent, done )
	local str = ""
	local done = done or {}
	local indent = indent or 0
	local idt = ""
	if nice then idt = string.rep( "\t", indent ) end
	local nl, tab  = "", ""
	if ( nice ) then nl, tab = "\n", "\t" end

	local sequential = table.IsSequential( t )

	for key, value in pairs( t ) do

		str = str .. idt .. tab .. tab

		if not sequential then
			if ( isnumber( key ) or isbool( key ) ) then
				key = "[" .. tostring( key ) .. "]" .. tab .. "="
			else
				key = tostring( key ) .. tab .. "="
			end
		else
			key = ""
		end

		if ( istable( value ) && !done[ value ] ) then

			if ( IsColor( value ) ) then
				done[ value ] = true
				value = "Color(" .. value.r .. "," .. value.g .. "," .. value.b .. "," .. value.a .. ")"
				str = str .. key .. tab .. value .. "," .. nl
			else
				done[ value ] = true
				str = str .. key .. tab .. '{' .. nl .. MakeTable (value, nice, indent + 1, done)
				str = str .. idt .. tab .. tab ..tab .. tab .."},".. nl
			end

		else

			if ( isstring( value ) ) then
				value = '"' .. tostring( value ) .. '"'
			elseif ( isvector( value ) ) then
				value = "Vector(" .. value.x .. "," .. value.y .. "," .. value.z .. ")"
			elseif ( isangle( value ) ) then
				value = "Angle(" .. value.pitch .. "," .. value.yaw .. "," .. value.roll .. ")"
			else
				value = tostring( value )
			end

			str = str .. key .. tab .. value .. "," .. nl

		end

	end
	return str
end

function tToString( t, n, nice )
	local nl, tab  = "", ""
	if ( nice ) then nl, tab = "\n", "\t" end

	local str = ""
	if ( n ) then str = n .. tab .. "=" .. tab end
	return str .. "{" .. nl .. MakeTable( t, nice ) .. "}"
end

local config = require("/app/config.lua")
local cache = require("/app/server.lua")

command.info = {
  Name = "Data",
  Alias = {},
  Usage = "data <optional guild id>",
  Category = "Private",
  Description = "View a server's configuration settings.",
  PermLvl = 5,
}

command.execute = function(message,args,client)
  if args[2] == nil then args[2] = message.guild.id end
  if client:getGuild(args[2]) == nil then return {success = false, msg = "I am **not in that guild**."} end
  local guild = client:getGuild(args[2])
  local data = config.getConfig(args[2])
  message:reply{embed = {
    title = guild.name.." Config",
    description = "```\n"..tToString(data).."\n```",
    footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.name},
    color = (cache.getCache("roleh",message.guild.id,message.author.id).color == 0 and 3066993 or cache.getCache("roleh",message.guild.id,message.author.id).color),
  }}
  return {success = "stfu"}
end

return command