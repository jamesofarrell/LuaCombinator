require("new_class")
output = {}

local output_mt = new_class(output)

function output:new(entity)
	return setmetatable( {entity=entity}, output_mt)
end

function output:clear(output)
	if self.entity then
		self.entity.set_circuit_condition(1,{parameters={}})
	else 
		game.players[1].print("CANT CLEAR!")
	end
end

-- function output:insert_count(type,name,count)
	-- local condition = self.entity.get_circuit_condition(1)
	-- local old_count = self.get_count(name)
	-- self.set_count(type,name,count)
-- end


function output:get_count(name)
	if self.entity then
		local condition = self.entity.get_circuit_condition(1)
		for _,value in pairs(condition.paramters) do
			if value.signal.name == nil or value.signal.name == nil then
				return 0
			elseif value.signal.name == name then
				return value.count
			end
		end
	else 
		game.players[1].print("CANT GET COUNT!")
	end
	return 0
end

function output:set_count(type,name,count)
	if self.entity then 
		local condition = self.entity.get_circuit_condition(1)
		for _,value in pairs(condition.parameters) do
			if value.signal.name == nil or value.signal.name == nil then
				value.signal = {type=type,name=name}
				value.count = count
				break
			elseif value.signal.name == name then
				value.count = count
				break
			end
		end
		self.entity.set_circuit_condition(1,condition)
	else
		game.players[1].print("FUCK!!!!!")
	end
end

return output