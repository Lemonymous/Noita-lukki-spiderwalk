
local truestates = {
	"true",
	true,
}

local falsestates = {
	"false",
	false,
}

function tobool(v)
	if truestates[v] then return true end
	if falsestates[v] then return false end
	
	local number = tonumber(v)
	if number then return number > 0 end
	
	return nil
end
