require("new_class")
require("defines")
require("util")

lc = {}

local lc_mt = new_class(lc)

function lc:new(entity,player)
	surface = entity.surface
	force = player.force
	position = entity.position
	
	new_lua_cominator = setmetatable({position=position,surface=surface,force=force,player=player,entity=entity,output_combinator=surface.create_entity{name="constant-combinator-trans_lua", position=position, text=text, color=color},entities={}}, lc_mt)
	new_lua_cominator.output_combinator.connect_neighbour{ wire=defines.circuitconnector.red, target_entity=new_lua_cominator.entity}
	new_lua_cominator.output_combinator.connect_neighbour{ wire=defines.circuitconnector.green, target_entity=new_lua_cominator.entity}
	return new_lua_cominator
end

function lc:set_item_count(type,name,count)
	if self.output_combinator then 
		local condition = self.output_combinator.get_circuit_condition(1)
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
		self.output_combinator.set_circuit_condition(1,condition)
	end
end

function lc:get_item_count(name)
	if self.output_combinator then
		local condition = self.output_combinator.get_circuit_condition(1)
		for _,value in pairs(condition.paramters) do
			if value.signal.name == nil or value.signal.name == nil then
				return 0
			elseif value.signal.name == name then
				return value.count
			end
		end
	end
	return 0
end

function lc:get_items()
	items = {}
	if self.output_combinator then
		local condition = self.output_combinator.get_circuit_condition(1)
		for _,value in pairs(condition.paramters) do
			if not (value.signal.name == nil or value.signal.name == nil) then
				table.insert(items,{type=value.signal.type,name=value.signal.name,value.signal.count})
			end
		end
	end
	return items
end

function lc:clear_items()
	if self.output_combinator then
		self.output_combinator.set_circuit_condition(1,{parameters={}})
	end
end

function lc:get_condition_value()
	if self.entity and self.entity.valid then 
		return self.entity.get_circuit_condition().fulfilled
	end
end

function lc:get_condition()
	if self.entity and self.entity.valid then 
		return self.entity.get_circuit_condition()
	end
end

function lc:set_condition(name,operator,count)
	if self.entity and self.entity.valid then 
		self.entity.set_circuit_condition{circuit=1,name=name,count=count,operator=operator}
	end
end

function lc:set_banner(text,colour)
	if self.banner then
		banner.destroy()
	end
	
	self.banner = self.surface.create_entity{name="flying-text-banner-forever_lua", position=self.position, text=text, color=color}
end

function lc:clear_banner()
	if self.banner then
		banner.destroy()
	end
end

function lc:print_team(text)
	for _,p in pairs(game.players) do
		if p and p.connected and p.force and p.force == self.force then
			p.print(text)
		end
	end
end

function lc:print_all(text)
	for _,p in pairs(game.players) do
		if p and p.connected then
			p.print(text)
		end
	end
end

function lc:print(text)
	if self.player and self.player.connected then
		self.player.print(text)
	end
end

function lc:set_map_text(text)
	if not self.map_text then
		self.map_text = self.surface.create_entity{name="train-stop-trans_lua", position=self.position,force = self.force}
	end
	self.map_text.backer_name = text
end

function lc:clean_map_text()
	if self.map_text then
		self.map_text.destroy()
		self.map_text = nil
	end
end