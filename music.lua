local module = {}
local connections = {}

module.addConnection = function(id,connection)
  connections[id] = connection
end

return module