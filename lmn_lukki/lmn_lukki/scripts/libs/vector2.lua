
local mt = {x = 0, y = 0}
mt.__index = mt

function mt:__add(other)
	return self(self.x + other.x, self.y + other.y)
end

function mt:__eq(other)
	return self.x == other.x and self.y == other.y
end

function mt:__sub(other)
	return self(self.x - other.x, self.y - other.y)
end

-- dot product
function mt:__mul(other)
	if type(other) == 'number' then
		return self(self.x * other, self.y * other)
	end
	
	return self.x * other.x + self.y * other.y
end

function mt:__div(divisor)
	return self(self.x / divisor, self.y / divisor)
end

function mt:__tostring()
	return "vector2(".. self.x ..", ".. self.y ..")"
end

function mt:__call(x, y)
	local result = {x = x, y = y}
	setmetatable(result, mt)
	
	return result
end

-- cross product
function mt:cross(other)
	return self.x * other.y - other.x * self.y
end

function mt:length()
	return math.sqrt(self.x * self.x + self.y * self.y)
end

function mt:unit()
	return self / self:length()
end

vector2 = {}
setmetatable(vector2, mt)

vector2.ZERO = vector2()
vector2.UP = vector2(0,-1)
vector2.DOWN = vector2(0,1)
vector2.LEFT = vector2(-1,0)
vector2.RIGHT = vector2(1,0)
