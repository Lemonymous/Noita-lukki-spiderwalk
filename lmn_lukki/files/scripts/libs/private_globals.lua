
local mt = {}

function mt:__index(key)
	local result = GlobalsGetValue(rawget(self, 'id') .. key)
	return result ~= "" and result or nil
end

function mt:__newindex(key, value)
	GlobalsSetValue(rawget(self, 'id') .. key, tostring(value))
end

local globals = {}
function globals:new(id)
	local t = {id = id}
	self.id = t
	setmetatable(t, mt)
	
	return t
end

function private_globals(id)
	return globals[id] or globals:new(id)
end