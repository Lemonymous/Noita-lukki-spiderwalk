
function list_contains(list, obj)
	for _, v in ipairs(list) do
		if obj == v then return true end
	end
	
	return false
end

function distSquared(p1, p2)
	if
		type(p1) ~= 'table'  or
		type(p2) ~= 'table'  or
		not p1.x or not p1.y or
		not p2.x or not p2.y
	then
		return
	end
	
	local dx = math.abs(p2.x - p1.x)
	local dy = math.abs(p2.y - p1.y)
	
	return dx * dx + dy * dy
end

function dist(p1, p2)
	return math.sqrt(distSquared(p1, p2))
end

function sign(v)
	if v < 0 then
		return -1
	end
	
	return 1
end

function tobool(v)
	if type(v) == 'boolean' then return v end
	
	if v == 'true' then return true end
	if v == 'false' then return false end
	
	local number = tonumber(v)
	if number then return number > 0 end
	
	return nil
end
