
local config = {
	vector2_path = "mods/lmn_lukki/lmn_lukki/scripts/libs/vector2.lua"
}

------------------------------------------------------------------------------------
--[[--------------------------------------------------------------------------------
	-OBJECTIFY ENTITY-
	by Lemonymous
	
	helper library for objectifying entities and their components
	
	examples:
		local player = objectify_entity(player_entity)
		
		-- fetch component
		local chardata = player.CharacterDataComponent
		
		-- fetch field of component:
		GamePrint(chardata.fly_recharge_spd)
		
		-- modify component
		chardata.fly_recharge_spd = 100
		
		-- vectors (returns vector2 objects)
		GamePrint(tostring(chardata.vector.mVelocity))
		chardata.vector.mVelocity = vector2(0, 100)
		
		-- MetaCustom values:
		GamePrint(chardata.meta.velocity_max_x)
		chardata.meta.velocity_max_x = 100
		
		-- dealing with multicomponents:
		local components = player.AudioLoopComponent
		for _, comp in ipairs(components) do
			GamePrint(comp.event_name)
		end
		
]]----------------------------------------------------------------------------------
------------------------------------------------------------------------------------


-- in lua 5.2 these overrides could
-- be substituted for metatable
-- __ipairs and __pairs function.
if not objectify_init_done then
	dofile(config.vector2_path)
	-- we don't really need pairs or next
	--[[rawnext = next
	function next(t, k)
		local m = getmetatable(t)
		local n = m and m.__next or rawnext
		return n(t, k)
	end
	
	function pairs(t) return next, t, nil end]]
	
	-- alternate ipairs override without
	-- going through m.__ipairs
	--[[local function _ipairs(t, key)
		key = key + 1
		local value = t[key]
		if value == nil then return end
		return key, value
	end
	function ipairs(t) return _ipairs, t, 0 end]]
	
	rawipairs = ipairs
	function ipairs(t)
		local m = getmetatable(t)
		if m and m.__ipairs then
			return m.__ipairs, t, 0
		end
		return rawipairs(t)
	end
	
	objectify_init_done = true
end

------------------------------------------------------------------------------------

local function getValue(...)
	local result = ComponentGetValue(...)
	if result == "" then
		return nil
	end
	
	local number = tonumber(result)
	if number then
		return number
	end
	
	return result
end

local function setValue(...)
	ComponentSetValue(...)
end

local function getVector(...)
	local x, y = ComponentGetValueVector2(...)
	return vector2(x, y)
end

local function setVector(comp, key, vec)
	ComponentSetValueVector2(comp, key, tostring(vec.x), tostring(vec.y))
end

local function getMeta(...)
	-- the game will throw an error if meta custom is nil,
	-- so at the moment this function is probably redundant.
	local result = ComponentGetMetaCustom(...)
	
	if result == "" then
		return nil
	end
	
	local number = tonumber(result)
	if number then
		return number
	end
	
	return result
end
	
local function setMeta(...)
	ComponentSetMetaCustom(...)
end

------------------------------------------------------------------------------------

local mt_meta = {}

function mt_meta:__index(key)
	return getMeta(self.component, key)
end

function mt_meta:__newindex(key, value)
	setMeta(self.component, key, value)
end

------------------------------------------------------------------------------------

local mt_vector = {}

function mt_vector:__index(key)
	return getVector(self.component, key)
end

function mt_vector:__newindex(key, value)
	setVector(self.component, key, value)
end

------------------------------------------------------------------------------------

local mt_comp = {}

function mt_comp:__index(key)
	if key == 'meta' then
		local result = {}
		result.component = self.component
		setmetatable(result, mt_meta)
		
		return result
		
	elseif key == 'vector' then
		local result = {}
		result.component = self.component
		setmetatable(result, mt_vector)
		
		return result
	end
	
	return getValue(self.component, key)
end

function mt_comp:__newindex(key, value)
	setValue(self.component, key, value)
end

------------------------------------------------------------------------------------

local mt_comps = {}

function mt_comps:__index(key)
	if key == 'meta' then
		local result = {}
		result.component = self.component[1]
		setmetatable(result, mt_meta)
		
		return result
		
	elseif key == 'vector' then
		local result = {}
		result.component = self.component[1]
		setmetatable(result, mt_vector)
		
		return result
	end
	
	if type(key) == 'number' then
		if key > #self.component then
			return
		end
		
		local result = {}
		result.component = self.component[key]
		setmetatable(result, mt_comp)
		
		return result
	end
	
	return getValue(self.component[1], key)
end

function mt_comps:__newindex(key, value)
	setValue(self.component[1], key, value)
end

function mt_comps:__ipairs(key)
	key = key + 1
	local value = self[key]
	if value == nil then return end
	return key, value
end

------------------------------------------------------------------------------------

local mt_entity = {}

function mt_entity:__newindex() end
function mt_entity:__index(key)
	if type(key) == 'number' then
		local component = EntityGetAllComponents(self.component)
		
		if key > #component then
			return
		end
		
		local result = {}
		result.component = component[key]
		setmetatable(result, mt_comps)
		
		return result
	end
	
	local component = EntityGetComponent(self.component, key)
	
	if component then
		local result = {}
		result.component = component
		setmetatable(result, mt_comps)
		
		return result
	end
	
	return nil
end

function mt_entity:__ipairs(key)
	key = key + 1
	local value = self[key]
	if value == nil then return end
	return key, value
end

------------------------------------------------------------------------------------

-- get objectified table for entity.
function objectify_entity(entity)
	local t = {}
	t.component = entity
	setmetatable(t, mt_entity)
	return t
end
